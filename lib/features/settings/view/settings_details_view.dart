import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/widgets/custom_field_block.dart';
import 'package:fatora/core/widgets/custom_button.dart';
import 'package:fatora/core/widgets/custom_screen_header.dart';
import 'package:fatora/core/widgets/show_message.dart';
import 'package:fatora/core/widgets/custom_card.dart';
import 'package:fatora/core/widgets/custom_text_field.dart';
import 'package:fatora/features/offline_voice_model/view/offline_voice_model_view.dart';
import 'package:fatora/features/settings/data/settings_section.dart';
import 'package:fatora/features/settings/widget/settings_option_widgets.dart';

class SettingsDetailsScreen extends StatelessWidget {
  const SettingsDetailsScreen({
    super.key,
    required this.section,
    required this.profile,
    required this.onSaveProfile,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.customerCount,
    required this.operationCount,
    required this.onClearData,
  });

  final SettingsSection section;
  final Map<String, String> profile;
  final Future<void> Function(String shopName, String phone) onSaveProfile;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final int customerCount;
  final int operationCount;
  final VoidCallback onClearData;

  String get _title {
    if (section == SettingsSection.account) return 'الحساب';
    if (section == SettingsSection.privacy) return 'الخصوصية';
    if (section == SettingsSection.lists) return 'القوائم';
    if (section == SettingsSection.backup) {
      return 'سجل العمليات والنسخ الاحتياطي';
    }
    if (section == SettingsSection.appearance) return 'الشكل';
    if (section == SettingsSection.notifications) return 'الإشعارات';
    if (section == SettingsSection.storage) return 'التخزين والبيانات';
    if (section == SettingsSection.language) return 'لغة التطبيق';
    return 'المساعدة والملاحظات';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomScreenHeader(
                title: _title,
                onBack: () => Navigator.maybePop(context),
              ),
              const SizedBox(height: 18),
              Expanded(child: _buildPage(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    if (section == SettingsSection.account) {
      return _AccountPage(profile: profile, onSave: onSaveProfile);
    }
    if (section == SettingsSection.privacy) return const _PrivacyPage();
    if (section == SettingsSection.lists) return const _ListsPage();
    if (section == SettingsSection.backup) {
      return _BackupPage(
        customerCount: customerCount,
        operationCount: operationCount,
      );
    }
    if (section == SettingsSection.appearance) {
      return _AppearancePage(
        themeMode: themeMode,
        onChanged: onThemeModeChanged,
      );
    }
    if (section == SettingsSection.notifications) {
      return const _NotificationsPage();
    }
    if (section == SettingsSection.storage) {
      return _StoragePage(
        customerCount: customerCount,
        operationCount: operationCount,
        onClearData: onClearData,
      );
    }
    if (section == SettingsSection.language) return const _LanguagePage();
    return const _HelpPage();
  }
}

class _BackupPage extends StatelessWidget {
  const _BackupPage({
    required this.customerCount,
    required this.operationCount,
  });

  final int customerCount;
  final int operationCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        CustomCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سجل الفواتير',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$operationCount عملية مسجلة',
                      style: TextStyle(
                        color: AppSurfaces.forContext(context).muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'محلي',
                style: TextStyle(color: AppPalette.success, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'النسخ الاحتياطي',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'يوجد $customerCount عميل و$operationCount عملية على الجهاز.',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppSurfaces.forContext(context).muted,
            fontSize: 12,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 21),
        const CustomButton(
          label: 'تصدير نسخة احتياطية — غير متاح حالياً',
          onPressed: null,
        ),
        const SizedBox(height: 11),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.file_upload_outlined),
          label: const Text('استعادة من نسخة احتياطية'),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppSurfaces.forContext(context).surface,
            foregroundColor: AppSurfaces.forContext(context).text,
            side: BorderSide(color: AppSurfaces.forContext(context).border),
            minimumSize: const Size.fromHeight(54),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'تعمل قاعدة البيانات محلياً. تصدير النسخة واستعادتها يحتاجان إلى استكمال.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppSurfaces.forContext(context).muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StoragePage extends StatelessWidget {
  const _StoragePage({
    required this.customerCount,
    required this.operationCount,
    required this.onClearData,
  });

  final int customerCount;
  final int operationCount;
  final VoidCallback onClearData;

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف كل البيانات؟'),
        content: const Text('سيتم حذف جميع العملاء والفواتير المسجلة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppPalette.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && context.mounted) {
      onClearData();
      showMessage(context, 'تم حذف جميع العمليات والعملاء');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: _StorageCount(label: 'العملاء', count: '$customerCount'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StorageCount(label: 'العمليات', count: '$operationCount'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'التسجيل الصوتي دون إنترنت',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 9),
        if (kIsWeb)
          const CustomCard(
            child: Text(
              'تنزيل نموذج الصوت يعمل في نسخة الهاتف. من هنا يمكنك تجربة تصميم التطبيق فقط.',
              textAlign: TextAlign.center,
            ),
          )
        else
          const OfflineVoiceModelView(),
        const SizedBox(height: 19),
        CustomCard(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              const Expanded(
                child: Text(
                  'النسخ الاحتياطي والاستعادة',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const Text(
                'محلي',
                style: TextStyle(color: AppPalette.success, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'منطقة الخطر',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppPalette.error,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        CustomCard(
          padding: EdgeInsets.zero,
          child: TextButton.icon(
            onPressed: () => _confirmDeleteAll(context),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('حذف كل البيانات (عملاء وفواتير)'),
            style: TextButton.styleFrom(
              foregroundColor: AppPalette.error,
              minimumSize: const Size.fromHeight(49),
            ),
          ),
        ),
      ],
    );
  }
}

class _StorageCount extends StatelessWidget {
  const _StorageCount({required this.label, required this.count});

  final String label;
  final String count;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppSurfaces.forContext(context).muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _AppearancePage extends StatelessWidget {
  const _AppearancePage({required this.themeMode, required this.onChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Text(
          'مظهر التطبيق',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'يُطبّق المظهر المختار على واجهات التطبيق.',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppSurfaces.forContext(context).muted,
            fontSize: 12,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        RadioGroup<ThemeMode>(
          groupValue: themeMode,
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          child: Column(
            children: [
              const ThemeChoice(label: 'فاتح', value: ThemeMode.light),
              const ThemeChoice(label: 'غامق', value: ThemeMode.dark),
              const ThemeChoice(
                label: 'حسب إعدادات الجهاز',
                value: ThemeMode.system,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'تعمل النسخة الحالية باللغة العربية.',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppSurfaces.forContext(context).muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ListsPage extends StatelessWidget {
  const _ListsPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsCard(
          icon: Icons.person_outline,
          title: 'إدارة العملاء',
          subtitle: 'عرض، بحث، وحذف العملاء',
          onTap: () =>
              showMessage(context, 'استخدم تبويب العملاء لعرض القائمة'),
        ),
        const SizedBox(height: 12),
        SettingsCard(
          icon: Icons.description_outlined,
          title: 'إدارة الفواتير',
          subtitle: 'عرض، تعديل، وحذف العمليات',
          onTap: () =>
              showMessage(context, 'استخدم تبويب الفواتير لإدارة العمليات'),
        ),
      ],
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, color: AppPalette.primaryGreen, size: 28),
            SizedBox(height: 12),
            Text(
              'اللغة المتاحة: العربية',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            SizedBox(height: 7),
            Text(
              'لا يتوفر تغيير اللغة في هذه النسخة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppSurfaces.forContext(context).muted,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountPage extends StatefulWidget {
  const _AccountPage({required this.profile, required this.onSave});

  final Map<String, String> profile;
  final Future<void> Function(String shopName, String phone) onSave;

  @override
  State<_AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<_AccountPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _shopNameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController(
      text: widget.profile['shopName'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.profile['phone'] ?? '',
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.onSave(
      _shopNameController.text.trim(),
      _phoneController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          CustomFieldBlock(
            label: 'اسم المحل',
            child: CustomTextField(
              controller: _shopNameController,
              textInputAction: TextInputAction.next,
              hintText: 'اسم المحل',
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'أدخل اسم المحل'
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          CustomFieldBlock(
            label: 'رقم الهاتف',
            child: CustomTextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              hintText: 'رقم الهاتف',
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(label: 'حفظ التعديل', onPressed: _save),
        ],
      ),
    );
  }
}

class _PrivacyPage extends StatelessWidget {
  const _PrivacyPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        CustomCard(
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              const Expanded(
                child: Text(
                  'لا تتوفر ميزة حظر العملاء في هذه النسخة.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 11),
        Text(
          'تُحفظ بيانات العملاء والفواتير محلياً على الجهاز.',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppSurfaces.forContext(context).muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'الإشعارات والتذكيرات غير مفعلة في هذه النسخة.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppSurfaces.forContext(context).muted),
        ),
      ),
    );
  }
}

class _HelpPage extends StatelessWidget {
  const _HelpPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Text(
          'كيف أسجل فاتورة بالصوت؟',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          'من الصفحة الرئيسية اضغط زر الميكروفون، وتحدث بجملة قصيرة. راجع العميل والمنتج والمبلغ ثم أكّد الحفظ.',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppSurfaces.forContext(context).muted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 17),
        const Text(
          'كيف أضيف دفعة؟',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          'من الفواتير اضغط إضافة عملية ثم اختر تسجيل دفعة.',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppSurfaces.forContext(context).muted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 20),
        const CustomButton(
          label: 'إرسال ملاحظة — غير متاح حالياً',
          onPressed: null,
        ),
      ],
    );
  }
}
