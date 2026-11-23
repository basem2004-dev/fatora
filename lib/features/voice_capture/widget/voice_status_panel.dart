import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';

class VoiceStatusPanel extends StatelessWidget {
  const VoiceStatusPanel({
    super.key,
    required this.isListening,
    required this.isReady,
    this.isTranscribing = false,
    this.isSupported = true,
    required this.onPressed,
  });

  final bool isListening;
  final bool isReady;
  final bool isTranscribing;
  final bool isSupported;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = isListening ? AppPalette.error : AppPalette.darkGreen;
    return Column(
      children: [
        Container(
          width: 144,
          height: 144,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: .09),
            border: Border.all(color: color.withValues(alpha: .16), width: 1.5),
          ),
          child: Center(
            child: Material(
              color: color,
              shape: const CircleBorder(),
              elevation: 6,
              shadowColor: color.withValues(alpha: .28),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: isReady && !isTranscribing ? onPressed : null,
                child: SizedBox(
                  width: 91,
                  height: 91,
                  child: Icon(
                    isTranscribing
                        ? Icons.hourglass_top_rounded
                        : isListening
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                    size: 42,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          isTranscribing
              ? 'يجري تحويل التسجيل إلى نص على الجهاز…'
              : !isSupported
              ? 'التسجيل الصوتي دون إنترنت متاح في نسخة الهاتف.'
              : !isReady
              ? 'نزّل نموذج الصوت لتفعيل التسجيل دون إنترنت.'
              : isListening
              ? 'استمع إليك الآن، اضغط لإيقاف التسجيل'
              : 'اضغط وتحدث بجملة قصيرة مثل: أبو محمد اشترى خبز بـ 10 شيكل',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: AppSurfaces.forContext(context).muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
