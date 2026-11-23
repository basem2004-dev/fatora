import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/widgets/custom_button.dart';
import 'package:fatora/core/widgets/custom_card.dart';
import 'package:fatora/features/offline_voice_model/data/voice_model_download_status.dart';

class VoiceModelDownloadCard extends StatelessWidget {
  const VoiceModelDownloadCard({
    super.key,
    required this.status,
    required this.isLoading,
    required this.onDownload,
  });

  final VoiceModelDownloadStatus status;
  final bool isLoading;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              const Icon(
                Icons.graphic_eq,
                color: AppPalette.primaryGreen,
                size: 21,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'نموذج الصوت بدون إنترنت',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              if (status.isInstalled)
                const Icon(
                  Icons.check_circle,
                  color: AppPalette.success,
                  size: 19,
                ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            _description,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppSurfaces.forContext(context).muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          if (!status.isInstalled && !status.isBusy) ...[
            const SizedBox(height: 7),
            Text(
              'حجم الملف حوالي 879MB، ويحتاج تجهيز النموذج مساحة إضافية تقارب 1.9GB.',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppSurfaces.forContext(context).muted,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
          if (status.isBusy) ...[
            const SizedBox(height: 13),
            LinearProgressIndicator(value: status.progress),
            const SizedBox(height: 6),
            Text(
              _progressText,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppSurfaces.forContext(context).muted,
                fontSize: 12,
              ),
            ),
          ],
          if (status.state == VoiceModelDownloadState.failed &&
              status.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              status.message,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppPalette.goldDark, fontSize: 12),
            ),
          ],
          if (!status.isInstalled && !status.isBusy) ...[
            const SizedBox(height: 13),
            CustomButton(
              label: isLoading
                  ? 'جارٍ تجهيز التنزيل…'
                  : status.state == VoiceModelDownloadState.failed
                  ? 'إعادة المحاولة'
                  : 'تنزيل النموذج — حوالي 879MB',
              icon: Icons.download_rounded,
              onPressed: isLoading ? null : onDownload,
            ),
          ],
        ],
      ),
    );
  }

  String get _description {
    if (status.isInstalled) {
      return 'النموذج جاهز. التعرف على الكلام يعمل محليًا ولا يحتاج إنترنت.';
    }
    if (status.state == VoiceModelDownloadState.installing) {
      return 'اكتمل التنزيل. يجري الآن تجهيز ملفات النموذج على الجهاز.';
    }
    if (status.state == VoiceModelDownloadState.waitingForNetwork) {
      return status.message.isNotEmpty
          ? status.message
          : 'بانتظار اتصال الإنترنت؛ سيكمل التنزيل تلقائيًا عند عودته.';
    }
    if (status.isDownloading) {
      return 'التنزيل مستمر بالخلفية. يمكنك إغلاق التطبيق، وسيستأنف تلقائيًا بعد انقطاع الشبكة.';
    }
    return 'النموذج غير مثبت بالكامل أو أن بعض ملفاته ناقصة. اضغط لتنزيل نسخة كاملة، وبعدها يعمل الصوت بلا إنترنت.';
  }

  String get _progressText {
    if (status.state == VoiceModelDownloadState.installing) {
      return 'جاري تجهيز النموذج…';
    }
    final downloaded = _formatSize(status.downloadedBytes);
    if (status.totalBytes <= 0) return 'تم تنزيل $downloaded';
    final total = _formatSize(status.totalBytes);
    final percent = ((status.progress ?? 0) * 100).round();
    return '$downloaded من $total — $percent٪';
  }

  String _formatSize(int bytes) {
    const megabyte = 1000 * 1000;
    const gigabyte = 1000 * megabyte;
    if (bytes >= gigabyte) return '${(bytes / gigabyte).toStringAsFixed(1)}GB';
    if (bytes >= megabyte) return '${(bytes / megabyte).toStringAsFixed(0)}MB';
    return '${(bytes / 1024).toStringAsFixed(0)}KB';
  }
}
