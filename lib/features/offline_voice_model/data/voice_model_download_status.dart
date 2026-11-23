enum VoiceModelDownloadState {
  idle,
  queued,
  downloading,
  waitingForNetwork,
  installing,
  installed,
  failed,
}

class VoiceModelDownloadStatus {
  const VoiceModelDownloadStatus({
    required this.state,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.message,
    required this.modelDirectory,
  });

  const VoiceModelDownloadStatus.idle()
    : state = VoiceModelDownloadState.idle,
      downloadedBytes = 0,
      totalBytes = 0,
      message = '',
      modelDirectory = '';

  final VoiceModelDownloadState state;
  final int downloadedBytes;
  final int totalBytes;
  final String message;
  final String modelDirectory;

  bool get isInstalled => state == VoiceModelDownloadState.installed;

  bool get isDownloading =>
      state == VoiceModelDownloadState.queued ||
      state == VoiceModelDownloadState.downloading ||
      state == VoiceModelDownloadState.waitingForNetwork;

  bool get isBusy =>
      isDownloading || state == VoiceModelDownloadState.installing;

  double? get progress {
    if (totalBytes <= 0) return null;
    return (downloadedBytes / totalBytes).clamp(0.0, 1.0);
  }

  factory VoiceModelDownloadStatus.fromMap(Map<String, Object?> values) {
    final stateName = values['state'] as String? ?? 'idle';
    final state = VoiceModelDownloadState.values.firstWhere(
      (item) => item.name == stateName,
      orElse: () => VoiceModelDownloadState.idle,
    );

    return VoiceModelDownloadStatus(
      state: state,
      downloadedBytes: (values['downloadedBytes'] as num?)?.toInt() ?? 0,
      totalBytes: (values['totalBytes'] as num?)?.toInt() ?? 0,
      message: values['message'] as String? ?? '',
      modelDirectory: values['modelDirectory'] as String? ?? '',
    );
  }
}
