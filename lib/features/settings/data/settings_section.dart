enum SettingsSection {
  account,
  privacy,
  lists,
  backup,
  appearance,
  notifications,
  storage,
  language,
  help,
}

class SettingsItem {
  const SettingsItem({
    required this.section,
    required this.title,
    required this.subtitle,
  });

  final SettingsSection section;
  final String title;
  final String subtitle;
}

const settingsItems = <SettingsItem>[
  SettingsItem(
    section: SettingsSection.account,
    title: 'الحساب',
    subtitle: 'بيانات المحل',
  ),
  SettingsItem(
    section: SettingsSection.privacy,
    title: 'الخصوصية',
    subtitle: 'العملاء المحظورين',
  ),
  SettingsItem(
    section: SettingsSection.lists,
    title: 'القوائم',
    subtitle: 'إدارة العملاء والفواتير',
  ),
  SettingsItem(
    section: SettingsSection.backup,
    title: 'سجل العمليات والنسخ الاحتياطي',
    subtitle: 'البيانات المحفوظة على الجهاز',
  ),
  SettingsItem(
    section: SettingsSection.appearance,
    title: 'الشكل',
    subtitle: 'سمة التطبيق وأيقونته',
  ),
  SettingsItem(
    section: SettingsSection.notifications,
    title: 'الإشعارات',
    subtitle: 'تذكيرات الديون والدفعات',
  ),
  SettingsItem(
    section: SettingsSection.storage,
    title: 'التخزين والبيانات',
    subtitle: 'نسخة احتياطية وإدارة البيانات',
  ),
  SettingsItem(
    section: SettingsSection.language,
    title: 'لغة التطبيق',
    subtitle: 'العربية',
  ),
  SettingsItem(
    section: SettingsSection.help,
    title: 'المساعدة والملاحظات',
    subtitle: 'الأسئلة الشائعة والدعم',
  ),
];
