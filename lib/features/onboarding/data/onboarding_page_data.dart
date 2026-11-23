import 'package:material_ui/material_ui.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.icon,
    required this.showLogo,
  });

  final String title;
  final IconData icon;
  final bool showLogo;
}

const onboardingPages = <OnboardingPageData>[
  OnboardingPageData(
    title: 'نظم أموالك بكل سهولة',
    icon: Icons.trending_up,
    showLogo: true,
  ),
  OnboardingPageData(
    title: 'تتبع آمن وموثوق للمدفوعات',
    icon: Icons.verified_user_outlined,
    showLogo: false,
  ),
  OnboardingPageData(
    title: 'أضف الفواتير بسهولة وسجلها بوضوح',
    icon: Icons.receipt_long_outlined,
    showLogo: false,
  ),
];
