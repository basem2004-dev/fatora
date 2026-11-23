import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/widgets/custom_screen_header.dart';
import 'package:fatora/core/widgets/custom_card.dart';
import 'package:fatora/core/utils/amount_formatters.dart';
import 'package:fatora/core/ledger/ledger_entry.dart';
import 'package:fatora/features/reports/data/sales_report.dart';
import 'package:fatora/features/reports/widget/report_period_and_table.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.entries});

  final List<LedgerEntry> entries;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _monthly = false;
  ReportFilter _filter = ReportFilter.all;
  DateTime _selectedDate = DateTime.now();

  void _shiftDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
  }

  @override
  Widget build(BuildContext context) {
    final report = SalesReport.forPeriod(
      source: widget.entries,
      date: _selectedDate,
      monthly: _monthly,
      filter: _filter,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomScreenHeader(
                title: 'كشف المبيعات',
                onBack: () => Navigator.maybePop(context),
              ),
              const SizedBox(height: 12),
              ReportPeriodSelector(
                monthly: _monthly,
                onChanged: (value) => setState(() => _monthly = value),
              ),
              const SizedBox(height: 24),
              CustomCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    IconButton(
                      onPressed: () => _shiftDate(-1),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.chevron_right),
                    ),
                    Expanded(
                      child: Text(
                        formatArabicDate(_selectedDate),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _shiftDate(1),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.chevron_left),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                textDirection: TextDirection.rtl,
                children: ReportFilter.values.map(_buildFilterChip).toList(),
              ),
              const SizedBox(height: 7),
              CustomCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 15,
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Text(
                        'عدد العمليات: ${report.entries.length}',
                        style: TextStyle(
                          color: AppSurfaces.forContext(context).muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      'الصافي: ${formatAmount(report.net)} ₪',
                      style: const TextStyle(
                        color: AppPalette.goldDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: CustomCard(
                  padding: const EdgeInsets.fromLTRB(10, 13, 10, 9),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 520,
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                const ReportTableRow(
                                  customer: 'العميل',
                                  product: 'المنتج',
                                  amount: 'المبلغ',
                                  time: 'الوقت',
                                  type: 'النوع',
                                  isHeader: true,
                                ),
                                Divider(
                                  color: AppSurfaces.forContext(context).border,
                                  height: 12,
                                ),
                                if (report.entries.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 22),
                                    child: Text(
                                      'لا توجد عمليات',
                                      style: TextStyle(
                                        color: AppSurfaces.forContext(context)
                                            .muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                else
                                  ...report.entries.map(
                                    ReportTableRow.fromEntry,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'مرّر يمين/يسار لعرض كل الأعمدة',
                          style: TextStyle(
                            color: AppSurfaces.forContext(context).muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(ReportFilter filter) {
    final selected = _filter == filter;
    Color color = AppPalette.success;
    if (filter == ReportFilter.all) color = AppPalette.primaryGreen;
    if (filter == ReportFilter.debts) color = AppPalette.goldDark;
    return Padding(
      padding: const EdgeInsets.only(left: 7),
      child: ChoiceChip(
        label: Text(
          filter.label,
          style: TextStyle(
            fontSize: 12,
            color: selected
                ? Colors.white
                : AppSurfaces.forContext(context).muted,
          ),
        ),
        selected: selected,
        selectedColor: color.withValues(alpha: .34),
        backgroundColor: AppSurfaces.forContext(context).surface,
        side: BorderSide(
          color: selected ? color : AppSurfaces.forContext(context).border,
        ),
        visualDensity: VisualDensity.compact,
        onSelected: (_) => setState(() => _filter = filter),
      ),
    );
  }
}
