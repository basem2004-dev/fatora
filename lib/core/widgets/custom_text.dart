import 'package:material_ui/material_ui.dart';

/// نص يستخدم تنسيقًا واحدًا في أكثر من شاشة.
class CustomText extends StatelessWidget {
  const CustomText(
    this.value, {
    super.key,
    this.style,
    this.textAlign = TextAlign.right,
    this.maxLines,
    this.overflow,
  });

  final String value;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style,
    );
  }
}
