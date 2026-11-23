import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/widgets/custom_text.dart';

class CustomScreenHeader extends StatelessWidget {
  const CustomScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.leadingAction,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? leadingAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_forward_rounded, size: 19),
              tooltip: 'رجوع',
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: CustomText(
              title,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -.3,
              ),
            ),
          ),
          if (leadingAction != null) ...[
            const SizedBox(width: 10),
            leadingAction!,
          ],
        ],
      ),
    );
  }
}
