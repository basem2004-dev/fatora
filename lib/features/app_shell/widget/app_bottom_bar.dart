import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';

class _BottomBarItem {
  const _BottomBarItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const _items = <_BottomBarItem>[
    _BottomBarItem(label: 'الرئيسية', icon: Icons.home_rounded),
    _BottomBarItem(label: 'الفواتير', icon: Icons.receipt_long_outlined),
    _BottomBarItem(label: 'العملاء', icon: Icons.groups_2_outlined),
    _BottomBarItem(label: 'الإعدادات', icon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
        decoration: BoxDecoration(
          color: AppSurfaces.forContext(context).bottomBar,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppSurfaces.forContext(context).border),
          boxShadow: Theme.of(context).brightness == Brightness.light
              ? [
                  BoxShadow(
                    color: AppPalette.ink.withValues(alpha: .08),
                    blurRadius: 22,
                    offset: const Offset(0, 7),
                  ),
                ]
              : const [],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = selectedIndex == index;
            return Expanded(
              child: InkWell(
                onTap: () => onSelect(index),
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 39,
                      height: 31,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppPalette.darkGreen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        item.icon,
                        size: 19,
                        color: selected
                            ? AppPalette.gold
                            : AppSurfaces.forContext(context).muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected
                            ? AppSurfaces.forContext(context).text
                            : AppSurfaces.forContext(context).muted,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
