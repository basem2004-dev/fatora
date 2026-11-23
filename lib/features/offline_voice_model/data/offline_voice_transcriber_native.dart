import 'dart:isolate';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

class OfflineVoiceTranscriber {
  const OfflineVoiceTranscriber();

  Future<String> transcribe({
    required String audioPath,
    required String modelDirectory,
  }) {
    return Isolate.run(() => _transcribeAudio(audioPath, modelDirectory));
  }
}

String _transcribeAudio(String audioPath, String modelDirectory) {
  sherpa.initBindings();

  final model = sherpa.OfflineModelConfig(
    qwen3Asr: sherpa.OfflineQwen3AsrModelConfig(
      convFrontend: '$modelDirectory/conv_frontend.onnx',
      encoder: '$modelDirectory/encoder.int8.onnx',
      decoder: '$modelDirectory/decoder.int8.onnx',
      tokenizer: '$modelDirectory/tokenizer',
      maxTotalLen: 512,
      maxNewTokens: 512,
    ),
    tokens: '',
    numThreads: 2,
    debug: false,
    provider: 'cpu',
  );
  final recognizer = sherpa.OfflineRecognizer(
    sherpa.OfflineRecognizerConfig(model: model),
  );
  final stream = recognizer.createStream();

  try {
    stream.setOption(key: 'language', value: 'Arabic');
    final audio = sherpa.readWave(audioPath);
    if (audio.samples.isEmpty || audio.sampleRate <= 0) {
      throw StateError('The recorded audio could not be read.');
    }
    stream.acceptWaveform(samples: audio.samples, sampleRate: audio.sampleRate);
    recognizer.decode(stream);
    return recognizer.getResult(stream).text.trim();
  } finally {
    stream.free();
    recognizer.free();
  }
}
