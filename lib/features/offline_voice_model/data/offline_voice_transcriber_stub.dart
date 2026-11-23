class OfflineVoiceTranscriber {
  const OfflineVoiceTranscriber();

  Future<String> transcribe({
    required String audioPath,
    required String modelDirectory,
  }) async {
    throw UnsupportedError('Offline voice recognition is available on mobile.');
  }
}
