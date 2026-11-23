import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';

class VoiceEntryCard extends StatelessWidget {
  const VoiceEntryCard({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.darkGreen,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppPalette.gold,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: AppPalette.darkGreen,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سجّل بصوتك',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'احكِ الفاتورة وسنرتبها لك',
                      style: TextStyle(fontSize: 12, color: Color(0xFFD8E8DF)),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
