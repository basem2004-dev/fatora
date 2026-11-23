import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fatora/features/offline_voice_model/data/voice_model_download_service.dart';
import 'package:fatora/features/offline_voice_model/data/voice_model_download_status.dart';
import 'package:fatora/features/offline_voice_model/widget/voice_model_download_card.dart';

class OfflineVoiceModelView extends StatefulWidget {
  const OfflineVoiceModelView({super.key, this.onStatusChanged});

  final ValueChanged<VoiceModelDownloadStatus>? onStatusChanged;

  @override
  State<OfflineVoiceModelView> createState() => _OfflineVoiceModelViewState();
}

class _OfflineVoiceModelViewState extends State<OfflineVoiceModelView> {
  final VoiceModelDownloadService _service = VoiceModelDownloadService();
  VoiceModelDownloadStatus _status = const VoiceModelDownloadStatus.idle();
  Timer? _statusTimer;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
    _statusTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _refreshStatus(),
    );
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      final status = await _service.getStatus();
      if (!mounted) return;
      setState(() {
        _status = status;
        _isLoading = false;
      });
      widget.onStatusChanged?.call(status);
    } on PlatformException catch (error) {
      _showError(error.message ?? 'تعذر قراءة حالة التنزيل.');
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _startDownload() async {
    setState(() => _isLoading = true);
    try {
      final status = await _service.startDownload();
      if (!mounted) return;
      setState(() {
        _status = status;
        _isLoading = false;
      });
      widget.onStatusChanged?.call(status);
    } on PlatformException catch (error) {
      _showError(error.message ?? 'تعذر بدء تنزيل النموذج.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _status = VoiceModelDownloadStatus(
        state: VoiceModelDownloadState.failed,
        downloadedBytes: 0,
        totalBytes: 0,
        message: message,
        modelDirectory: '',
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VoiceModelDownloadCard(
      status: _status,
      isLoading: _isLoading,
      onDownload: _startDownload,
    );
  }
}
