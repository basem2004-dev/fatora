import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/utils/amount_formatters.dart';
import 'package:fatora/core/widgets/custom_card.dart';
import 'package:fatora/core/widgets/custom_screen_header.dart';
import 'package:fatora/core/ledger/ledger_entry.dart';
import 'package:fatora/features/invoices/data/invoice_filter.dart';
import 'package:fatora/features/invoices/widget/invoice_entry_widgets.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({
    super.key,
    required this.entries,
    required this.balances,
    required this.onAdd,
    required this.onDeleted,
    required this.onEdited,
    required this.onOpenReport,
  });

  final List<LedgerEntry> entries;
  final Map<String, double> balances;
  final VoidCallback onAdd;
  final ValueChanged<LedgerEntry> onDeleted;
  final void Function(LedgerEntry oldEntry, LedgerEntry newEntry) onEdited;
  final VoidCallback onOpenReport;

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  InvoiceFilter _filter = InvoiceFilter.all;

  Future<void> _deleteEntry(LedgerEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العملية؟'),
        content: const Text('سيتم حذف هذه العملية من سجل الفواتير.'),
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
    if (shouldDelete == true && mounted) widget.onDeleted(entry);
  }

  Future<void> _editEntry(LedgerEntry entry) async {
    final edited = await showEditEntrySheet(context, entry);
    if (edited != null && mounted) widget.onEdited(entry, edited);
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries.where(_filter.includes).toList();
    final openBalance = widget.balances.values.fold<double>(
      0,
      (total, value) => total + value,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(19, 14, 19, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomScreenHeader(
            title: 'الفواتير',
            leadingAction: IconButton(
              onPressed: widget.onOpenReport,
              tooltip: 'كشف المبيعات',
              icon: const Icon(
                Icons.bar_chart_rounded,
                color: AppPalette.success,
              ),
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
            borderRadius: 22,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: AppPalette.softGold,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppPalette.darkGreen,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المبالغ المستحقة',
                        style: TextStyle(
                          color: AppSurfaces.forContext(context).muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${formatAmount(openBalance)} ₪',
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.softGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.entries.length} عملية',
                    style: const TextStyle(
                      color: AppPalette.darkGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  'سجل العمليات',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppSurfaces.forContext(context).muted,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onAdd,
                tooltip: 'إضافة عملية',
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppPalette.primaryGreen,
                ),
              ),
            ],
          ),
          Row(
            textDirection: TextDirection.rtl,
            children: InvoiceFilter.values.map(_buildFilterChip).toList(),
          ),
          const SizedBox(height: 4),
          if (entries.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 90),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: AppSurfaces.forContext(context).muted,
                      size: 38,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'لا توجد عمليات',
                      style: TextStyle(
                        color: AppSurfaces.forContext(context).muted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InvoiceCard(
                  entry: entry,
                  balance: widget.balances[entry.customerName] ?? 0,
                  onEdit: () => _editEntry(entry),
                  onDelete: () => _deleteEntry(entry),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(InvoiceFilter filter) {
    final selected = _filter == filter;
    Color color = AppPalette.success;
    if (filter == InvoiceFilter.all) color = AppPalette.primaryGreen;
    if (filter == InvoiceFilter.debts) color = AppPalette.goldDark;
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
        onSelected: (_) => setState(() => _filter = filter),
        selectedColor: color,
        backgroundColor: AppSurfaces.forContext(context).surface,
        side: BorderSide(
          color: selected ? color : AppSurfaces.forContext(context).border,
        ),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 2),
      ),
    );
  }
}
