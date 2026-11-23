import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/widgets/custom_field_block.dart';
import 'package:fatora/core/widgets/show_message.dart';
import 'package:fatora/core/widgets/custom_card.dart';
import 'package:fatora/core/utils/amount_formatters.dart';
import 'package:fatora/core/ledger/ledger_entry.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.entry,
    required this.balance,
    required this.onEdit,
    required this.onDelete,
  });

  final LedgerEntry entry;
  final double balance;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isPayment = entry.type == LedgerEntryType.payment;
    final isPaidInvoice = entry.type == LedgerEntryType.invoice && entry.isPaid;
    final color = isPayment || isPaidInvoice
        ? AppPalette.success
        : AppPalette.goldDark;

    return CustomCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
      borderRadius: 21,
      child: Column(
        children: [
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entry.type == LedgerEntryType.debt && entry.isOldDebt
                          ? 'دين قديم'
                          : entry.typeLabel,
                      style: TextStyle(
                        color: AppSurfaces.forContext(context).muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatEntryTime(entry.createdAt),
                      style: TextStyle(
                        color: AppSurfaces.forContext(context).muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isPayment ? '−' : '+'}${formatAmount(entry.amount)} ₪',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onEdit,
                tooltip: 'تعديل',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.edit,
                  size: 16,
                  color: AppPalette.goldDark,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'حذف',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.delete_outline,
                  size: 17,
                  color: AppSurfaces.forContext(context).muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              _EntryTypeBadge(label: entry.typeLabel, color: color),
              const Spacer(),
              if (entry.product.isNotEmpty)
                Text(
                  entry.product,
                  style: TextStyle(
                    color: AppSurfaces.forContext(context).muted,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              color: AppSurfaces.forContext(context).border,
            ),
          ),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  'إجمالي على ${entry.customerName} لحد الآن',
                  style: TextStyle(
                    color: AppSurfaces.forContext(context).muted,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${formatAmount(balance)} ₪',
                style: TextStyle(
                  color: AppSurfaces.forContext(context).muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntryTypeBadge extends StatelessWidget {
  const _EntryTypeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .17),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

Future<LedgerEntry?> showEditEntrySheet(
  BuildContext context,
  LedgerEntry entry,
) {
  return showModalBottomSheet<LedgerEntry>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppSurfaces.forContext(context).surface,
    builder: (_) => _EditEntrySheet(entry: entry),
  );
}

class _EditEntrySheet extends StatefulWidget {
  const _EditEntrySheet({required this.entry});

  final LedgerEntry entry;

  @override
  State<_EditEntrySheet> createState() => _EditEntrySheetState();
}

class _EditEntrySheetState extends State<_EditEntrySheet> {
  late final TextEditingController _productController;
  late final TextEditingController _amountController;
  late bool _isPaid;

  @override
  void initState() {
    super.initState();
    _isPaid = widget.entry.isPaid;
    _productController = TextEditingController(text: widget.entry.product);
    _amountController = TextEditingController(
      text: formatAmount(widget.entry.amount),
    );
  }

  @override
  void dispose() {
    _productController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      showMessage(context, 'أدخل مبلغاً صحيحاً');
      return;
    }
    Navigator.pop(
      context,
      widget.entry.copyWith(
        product: _productController.text.trim(),
        amount: amount,
        isPaid: widget.entry.type == LedgerEntryType.invoice && _isPaid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(22, 24, 22, bottomInset + 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تعديل العملية',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Text(
            widget.entry.customerName,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppSurfaces.forContext(context).muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 13),
          CustomFieldBlock(
            label: 'المنتج (اختياري)',
            child: TextField(
              controller: _productController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(hintText: 'اسم المنتج'),
            ),
          ),
          const SizedBox(height: 15),
          CustomFieldBlock(
            label: 'المبلغ (شيكل)',
            child: TextField(
              controller: _amountController,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(hintText: '0'),
            ),
          ),
          if (widget.entry.type == LedgerEntryType.invoice) ...[
            const SizedBox(height: 9),
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  const Expanded(child: Text('مدفوعة الآن')),
                  Switch.adaptive(
                    value: _isPaid,
                    activeTrackColor: AppPalette.primaryGreen,
                    onChanged: (value) => setState(() => _isPaid = value),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              TextButton(onPressed: _save, child: const Text('حفظ التعديل')),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: AppSurfaces.forContext(context).muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
