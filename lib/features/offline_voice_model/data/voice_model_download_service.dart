import 'package:flutter/services.dart';

import 'package:fatora/features/offline_voice_model/data/voice_model_download_status.dart';

class VoiceModelDownloadService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.fatora/voice_model',
  );

  Future<VoiceModelDownloadStatus> getStatus() async {
    final values = await _channel.invokeMapMethod<String, Object?>('getStatus');
    return VoiceModelDownloadStatus.fromMap(values ?? const {});
  }

  Future<VoiceModelDownloadStatus> startDownload() async {
    final values = await _channel.invokeMapMethod<String, Object?>(
      'startDownload',
    );
    return VoiceModelDownloadStatus.fromMap(values ?? const {});
  }
}
