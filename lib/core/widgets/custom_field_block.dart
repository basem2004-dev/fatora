import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/widgets/custom_text.dart';

class CustomFieldBlock extends StatelessWidget {
  const CustomFieldBlock({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 2, bottom: 8),
          child: CustomText(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              color: AppSurfaces.forContext(context).muted,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
