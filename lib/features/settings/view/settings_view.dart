import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/widgets/custom_screen_header.dart';
import 'package:fatora/core/widgets/custom_card.dart';
import 'package:fatora/features/settings/data/settings_section.dart';
import 'package:fatora/features/settings/view/settings_details_view.dart';
import 'package:fatora/features/settings/widget/settings_option_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.profile,
    required this.onSaveProfile,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.customerCount,
    required this.operationCount,
    required this.onClearData,
  });

  final Map<String, String> profile;
  final Future<void> Function(String shopName, String phone) onSaveProfile;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final int customerCount;
  final int operationCount;
  final VoidCallback onClearData;

  Future<void> _openSection(
    BuildContext context,
    SettingsSection section,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SettingsDetailsScreen(
          section: section,
          profile: profile,
          onSaveProfile: onSaveProfile,
          themeMode: themeMode,
          onThemeModeChanged: onThemeModeChanged,
          customerCount: customerCount,
          operationCount: operationCount,
          onClearData: onClearData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomScreenHeader(title: 'الإعدادات'),
          const SizedBox(height: 9),
          CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
            borderRadius: 23,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: AppSurfaces.forContext(context).raised,
                  child: Icon(
                    Icons.storefront,
                    color: AppSurfaces.forContext(context).text,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile['shopName']?.isNotEmpty == true
                      ? profile['shopName']!
                      : 'اسم المحل غير مضاف',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  profile['phone']?.isNotEmpty == true
                      ? profile['phone']!
                      : 'أضف اسم المحل ورقم الهاتف',
                  style: TextStyle(
                    color: AppSurfaces.forContext(context).muted,
                    fontSize: 12,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _openSection(context, SettingsSection.account),
                  icon: const Icon(
                    Icons.edit,
                    size: 14,
                    color: AppPalette.goldDark,
                  ),
                  label: const Text(
                    'إضافة بيانات المحل',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            padding: const EdgeInsets.fromLTRB(14, 10, 15, 10),
            borderRadius: 20,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                const Icon(
                  Icons.phone_android,
                  color: AppPalette.primaryGreen,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'التخزين المحلي',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'تُحفظ البيانات على الجهاز وتعمل دون إنترنت',
                        style: TextStyle(
                          color: AppSurfaces.forContext(context).muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'المزامنة السحابية تتطلب إعداد خادم',
                        style: TextStyle(
                          color: AppSurfaces.forContext(context).muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          ...settingsItems.map((item) {
            return SettingRow(
              title: item.title,
              subtitle: item.subtitle,
              icon: _iconFor(item.section),
              onTap: () => _openSection(context, item.section),
            );
          }),
        ],
      ),
    );
  }

  IconData _iconFor(SettingsSection section) {
    if (section == SettingsSection.account) return Icons.person_outline;
    if (section == SettingsSection.privacy) return Icons.lock_outline;
    if (section == SettingsSection.lists) return Icons.list_alt;
    if (section == SettingsSection.backup) return Icons.backup_outlined;
    if (section == SettingsSection.appearance) return Icons.palette_outlined;
    if (section == SettingsSection.notifications) {
      return Icons.notifications_none;
    }
    if (section == SettingsSection.storage) return Icons.storage_outlined;
    if (section == SettingsSection.language) return Icons.language;
    return Icons.help_outline;
  }
}
