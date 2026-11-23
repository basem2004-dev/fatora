import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/ledger/ledger_entry.dart';
import 'package:fatora/core/utils/amount_formatters.dart';
import 'package:fatora/core/widgets/custom_card.dart';

class RecentEntryCard extends StatelessWidget {
  const RecentEntryCard({super.key, required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final surfaces = AppSurfaces.forContext(context);
    final detail = entry.product.trim().isEmpty
        ? entry.typeLabel
        : entry.product;
    final isPayment = entry.type == LedgerEntryType.payment;
    final isSettled = isPayment || entry.isPaid;
    final accent = isSettled ? AppPalette.success : AppPalette.goldDark;

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      borderRadius: 20,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 41,
            height: 41,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isPayment ? Icons.south_west_rounded : Icons.receipt_long_rounded,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$detail · ${formatEntryTime(entry.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: surfaces.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isPayment ? '−' : '+'}${formatAmount(entry.amount)} ₪',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
