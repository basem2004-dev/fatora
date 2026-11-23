import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 14,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppSurfaces.forContext(context).surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppSurfaces.forContext(context).border),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: const Color(0xFF1C302A).withValues(alpha: .045),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [],
      ),
      child: child,
    );
  }
}
