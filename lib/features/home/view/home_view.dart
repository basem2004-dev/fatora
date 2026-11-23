import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/utils/amount_formatters.dart';
import 'package:fatora/core/widgets/custom_card.dart';
import 'package:fatora/features/home/data/home_summary.dart';
import 'package:fatora/features/home/widget/home_balance_card.dart';
import 'package:fatora/features/home/widget/home_summary_card.dart';
import 'package:fatora/features/home/widget/recent_entry_card.dart';
import 'package:fatora/features/home/widget/voice_entry_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.summary,
    required this.onVoiceTap,
    required this.onManualEntry,
    required this.onViewInvoices,
  });

  final HomeSummary summary;
  final VoidCallback onVoiceTap;
  final VoidCallback onManualEntry;
  final VoidCallback onViewInvoices;

  @override
  Widget build(BuildContext context) {
    final surfaces = AppSurfaces.forContext(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppPalette.softGold,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: AppPalette.darkGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دفتر المحل',
                      style: TextStyle(fontSize: 12, color: surfaces.muted),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'أهلاً بك في فاتورة',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: surfaces.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: surfaces.border),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: surfaces.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          HomeBalanceCard(balance: summary.totalBalance),
          const SizedBox(height: 13),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: HomeSummaryCard(
                  icon: Icons.trending_up_rounded,
                  label: 'مبيعات اليوم',
                  value: '${formatAmount(summary.todaySales)} ₪',
                  accent: AppPalette.primaryGreen,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: HomeSummaryCard(
                  icon: Icons.receipt_long_rounded,
                  label: 'عمليات اليوم',
                  value: '${summary.todayOperations} عملية',
                  accent: AppPalette.goldDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          VoiceEntryCard(onPressed: onVoiceTap),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: onManualEntry,
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: const Text('إضافة عملية بالكتابة'),
              style: TextButton.styleFrom(
                foregroundColor: surfaces.muted,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              const Expanded(
                child: Text(
                  'آخر العمليات',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: onViewInvoices,
                child: const Text('عرض السجل'),
              ),
            ],
          ),
          if (summary.recentEntries.isEmpty)
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: surfaces.muted,
                    size: 28,
                  ),
                  const SizedBox(height: 9),
                  const Text('دفترك جاهز لأول فاتورة'),
                  const SizedBox(height: 4),
                  Text(
                    'سجّلها بصوتك أو أضفها يدويًا من هنا.',
                    style: TextStyle(fontSize: 12, color: surfaces.muted),
                  ),
                ],
              ),
            )
          else
            ...summary.recentEntries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecentEntryCard(entry: entry),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
