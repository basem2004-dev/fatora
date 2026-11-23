import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/utils/amount_formatters.dart';
import 'package:fatora/core/ledger/ledger_entry.dart';

class ReportPeriodSelector extends StatelessWidget {
  const ReportPeriodSelector({
    super.key,
    required this.monthly,
    required this.onChanged,
  });

  final bool monthly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppSurfaces.forContext(context).surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppSurfaces.forContext(context).border),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: _PeriodButton(
              label: 'حسب اليوم',
              selected: !monthly,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _PeriodButton(
              label: 'حسب الشهر',
              selected: monthly,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppPalette.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected
                ? Colors.white
                : AppSurfaces.forContext(context).text,
          ),
        ),
      ),
    );
  }
}

class ReportTableRow extends StatelessWidget {
  const ReportTableRow({
    super.key,
    required this.customer,
    required this.product,
    required this.amount,
    required this.time,
    required this.type,
    this.isHeader = false,
    this.amountColor,
  });

  factory ReportTableRow.fromEntry(LedgerEntry entry) {
    return ReportTableRow(
      customer: entry.customerName,
      product: entry.product.trim().isEmpty ? entry.typeLabel : entry.product,
      amount: '${formatAmount(entry.amount)} ₪',
      time: formatEntryTime(entry.createdAt),
      type: entry.typeLabel,
      amountColor: entry.type == LedgerEntryType.payment
          ? AppPalette.success
          : AppPalette.goldDark,
    );
  }

  final String customer;
  final String product;
  final String amount;
  final String time;
  final String type;
  final bool isHeader;
  final Color? amountColor;

  @override
  Widget build(BuildContext context) {
    final rowAmountColor = amountColor ?? AppSurfaces.forContext(context).text;
    final style = TextStyle(
      color: isHeader
          ? AppSurfaces.forContext(context).muted
          : AppSurfaces.forContext(context).text,
      fontSize: isHeader ? 11 : 12,
      fontWeight: isHeader ? FontWeight.w500 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 82,
            child: Text(customer, textAlign: TextAlign.right, style: style),
          ),
          SizedBox(
            width: 95,
            child: Text(product, textAlign: TextAlign.center, style: style),
          ),
          SizedBox(
            width: 80,
            child: Text(
              amount,
              textAlign: TextAlign.center,
              style: style.copyWith(
                color: isHeader
                    ? AppSurfaces.forContext(context).muted
                    : rowAmountColor,
              ),
            ),
          ),
          SizedBox(
            width: 88,
            child: Text(time, textAlign: TextAlign.center, style: style),
          ),
          SizedBox(
            width: 70,
            child: Text(
              type,
              textAlign: TextAlign.center,
              style: style.copyWith(
                color: isHeader
                    ? AppSurfaces.forContext(context).muted
                    : type == 'دفعة'
                    ? AppPalette.success
                    : AppPalette.goldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
