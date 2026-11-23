import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:record/record.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/widgets/custom_button.dart';
import 'package:fatora/core/widgets/custom_screen_header.dart';
import 'package:fatora/core/widgets/custom_card.dart';
import 'package:fatora/core/ledger/ledger_entry.dart';
import 'package:fatora/features/transaction_form/data/transaction_form_labels.dart';
import 'package:fatora/features/transaction_form/view/transaction_form_view.dart';
import 'package:fatora/features/offline_voice_model/data/offline_voice_transcriber.dart';
import 'package:fatora/features/offline_voice_model/data/voice_model_download_service.dart';
import 'package:fatora/features/offline_voice_model/data/voice_model_download_status.dart';
import 'package:fatora/features/offline_voice_model/view/offline_voice_model_view.dart';
import 'package:fatora/features/voice_capture/data/voice_transaction_parser.dart';
import 'package:fatora/features/voice_capture/data/recording_file_helper.dart';
import 'package:fatora/features/voice_capture/widget/voice_status_panel.dart';

class VoiceCaptureScreen extends StatefulWidget {
  const VoiceCaptureScreen({super.key});

  @override
  State<VoiceCaptureScreen> createState() => _VoiceCaptureScreenState();
}

class _VoiceCaptureScreenState extends State<VoiceCaptureScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final VoiceModelDownloadService _modelDownloadService =
      VoiceModelDownloadService();
  final OfflineVoiceTranscriber _transcriber = const OfflineVoiceTranscriber();
  VoiceModelDownloadStatus _modelStatus = const VoiceModelDownloadStatus.idle();
  bool _ready = false;
  bool _listening = false;
  bool _isTranscribing = false;
  String _transcript = '';
  String? _error;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _loadModelStatus();
  }

  Future<void> _loadModelStatus() async {
    if (kIsWeb) {
      if (!mounted) return;
      setState(() => _ready = false);
      return;
    }
    try {
      final status = await _modelDownloadService.getStatus();
      if (!mounted) return;
      setState(() {
        _modelStatus = status;
        _ready = status.isInstalled;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ready = false;
        _error = 'تعذر التحقق من نموذج الصوت. افتح الإعدادات وحاول مجددًا.';
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _finishRecording();
      return;
    }
    if (!_ready || _modelStatus.modelDirectory.isEmpty) return;
    setState(() {
      _error = null;
      _transcript = '';
    });
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw StateError('لم يتم السماح باستخدام الميكروفون.');
      }
      final recordingPath = await createTemporaryRecordingPath();
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: recordingPath,
      );
      if (!mounted) return;
      setState(() {
        _recordingPath = recordingPath;
        _listening = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _listening = false;
        _error = 'تعذر بدء التسجيل. تحقق من إذن الميكروفون ثم حاول مرة أخرى.';
      });
    }
  }

  Future<void> _finishRecording() async {
    String? path;
    try {
      path = await _recorder.stop() ?? _recordingPath;
      if (!mounted) return;
      setState(() {
        _listening = false;
        _isTranscribing = true;
        _error = null;
      });
      if (path == null || !recordingFileExists(path)) {
        throw StateError('لم يتم حفظ التسجيل الصوتي.');
      }
      final transcript = await _transcriber.transcribe(
        audioPath: path,
        modelDirectory: _modelStatus.modelDirectory,
      );
      if (!mounted) return;
      setState(() {
        _transcript = transcript;
        if (transcript.isEmpty) {
          _error = 'لم أسمع كلمات واضحة. اقترب من الهاتف وتحدث بجملة قصيرة.';
        }
      });
    } catch (error, stackTrace) {
      debugPrint('Voice transcription failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _listening = false;
        _error = 'تعذر تحويل الصوت إلى نص. أعد المحاولة بعد التأكد من جاهزية النموذج.';
      });
    } finally {
      if (path != null) {
        await deleteRecordingFile(path);
      }
      if (mounted) {
        setState(() {
          _isTranscribing = false;
          _recordingPath = null;
        });
      }
    }
  }

  Future<void> _reviewDraft() async {
    final draft = VoiceTransactionParser.makeDraftFromWords(_transcript);
    if (_listening) await _recorder.stop();
    if (!mounted) return;
    final entry = await Navigator.of(context).push<LedgerEntry>(
      MaterialPageRoute<LedgerEntry>(
        builder: (_) => TransactionFormScreen(
          type: draft.type,
          initialCustomerName: draft.customerName,
          initialProduct: draft.product,
          initialAmount: draft.amount,
          initialIsPaid: draft.isPaid,
          recognizedText: _transcript,
        ),
      ),
    );
    if (!mounted || entry == null) return;
    Navigator.of(context).pop(entry);
  }

  @override
  void dispose() {
    unawaited(_recorder.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = _transcript.isEmpty
        ? null
        : VoiceTransactionParser.makeDraftFromWords(_transcript);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(21, 14, 21, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomScreenHeader(
                title: 'التسجيل الصوتي',
                onBack: () => Navigator.maybePop(context),
              ),
              const SizedBox(height: 34),
              VoiceStatusPanel(
                isListening: _listening,
                isReady: _ready && !_isTranscribing,
                isTranscribing: _isTranscribing,
                isSupported: !kIsWeb,
                onPressed: _toggleListening,
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 26),
                CustomCard(
                  borderRadius: 20,
                  child: Text(
                    'التسجيل الصوتي دون إنترنت متاح في نسخة الهاتف. يمكنك تجربة تصميم التطبيق وإضافة الفواتير يدويًا هنا.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppSurfaces.forContext(context).muted,
                      height: 1.5,
                    ),
                  ),
                ),
              ] else if (!_modelStatus.isInstalled) ...[
                const SizedBox(height: 28),
                OfflineVoiceModelView(
                  onStatusChanged: (status) {
                    if (!mounted) return;
                    setState(() {
                      _modelStatus = status;
                      _ready = status.isInstalled;
                      if (_ready) _error = null;
                    });
                  },
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 18),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppPalette.goldDark,
                    fontSize: 12,
                  ),
                ),
              ],
              if (_transcript.isNotEmpty && draft != null) ...[
                const SizedBox(height: 32),
                CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'النص الذي سمعه التطبيق',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: AppSurfaces.forContext(context).muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _transcript,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                      Divider(
                        height: 24,
                        color: AppSurfaces.forContext(context).border,
                      ),
                      Text(
                        'المعلومات المستخرجة للمراجعة',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: AppSurfaces.forContext(context).muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'النوع: ${draft.type == LedgerEntryType.invoice
                            ? 'فاتورة'
                            : draft.type == LedgerEntryType.debt
                            ? 'دين'
                            : 'دفعة'}',
                        textAlign: TextAlign.right,
                      ),
                      if (draft.type == LedgerEntryType.invoice)
                        Text(
                          'الحالة: ${draft.isPaid ? 'مدفوعة الآن' : 'غير مدفوعة، على حساب العميل'}',
                          textAlign: TextAlign.right,
                        ),
                      Text(
                        'العميل: ${draft.customerName.isEmpty ? 'غير محدد' : draft.customerName}',
                        textAlign: TextAlign.right,
                      ),
                      if (draft.product.isNotEmpty)
                        Text(
                          'المنتج: ${draft.product}',
                          textAlign: TextAlign.right,
                        ),
                      Text(
                        'المبلغ: ${draft.amount == null ? 'غير محدد' : '${draft.amount} شيكل'}',
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: TransactionFormLabels.reviewLabel(draft.type),
                  onPressed: _reviewDraft,
                ),
              ],
              const SizedBox(height: 26),
              Text(
                'بعد المراجعة، أكّد بيانات العميل والمبلغ ليتم حفظ العملية في الدفتر.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppSurfaces.forContext(context).muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
