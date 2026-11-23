import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';

class FatoraLogo extends StatelessWidget {
  const FatoraLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 185,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  LogoBar(height: 66),
                  SizedBox(width: 13),
                  LogoBar(height: 112),
                  SizedBox(width: 13),
                  LogoBar(height: 82),
                  SizedBox(width: 13),
                  LogoBar(height: 145),
                ],
              ),
              Positioned(
                top: 14,
                child: Icon(
                  Icons.trending_up,
                  size: 90,
                  color: AppPalette.success.withValues(alpha: .8),
                ),
              ),
              Positioned(
                bottom: 14,
                child: Text(
                  'Fatora',
                  style: TextStyle(
                    fontSize: 50,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.white,
                    shadows: [
                      Shadow(
                        color: AppPalette.goldDark.withValues(alpha: .9),
                        blurRadius: 5,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Text(
          'فاتورة',
          style: TextStyle(
            fontSize: 42,
            height: 1,
            fontWeight: FontWeight.w800,
            color: AppPalette.white,
          ),
        ),
      ],
    );
  }
}

class LogoBar extends StatelessWidget {
  const LogoBar({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: height,
      decoration: BoxDecoration(
        color: AppPalette.success.withValues(alpha: .6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

class IntroIllustration extends StatelessWidget {
  const IntroIllustration({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Center(
        child: Icon(
          icon,
          size: icon == Icons.mic_none_rounded ? 190 : 170,
          color: color,
        ),
      ),
    );
  }
}
