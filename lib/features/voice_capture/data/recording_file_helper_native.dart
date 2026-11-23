import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> createTemporaryRecordingPath() async {
  final directory = await getTemporaryDirectory();
  final fileName = 'fatora-voice-${DateTime.now().microsecondsSinceEpoch}.wav';
  return '${directory.path}${Platform.pathSeparator}$fileName';
}

bool recordingFileExists(String path) => File(path).existsSync();

Future<void> deleteRecordingFile(String path) async {
  try {
    await File(path).delete();
  } on FileSystemException {
    // A missing temporary recording does not change the saved invoice.
  }
}
