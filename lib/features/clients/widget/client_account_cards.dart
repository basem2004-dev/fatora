import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/widgets/custom_card.dart';
import 'package:fatora/core/utils/amount_formatters.dart';
import 'package:fatora/core/ledger/ledger_entry.dart';
import 'package:fatora/features/clients/data/client_account.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({super.key, required this.account, required this.onTap});

  final ClientAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasDebt = account.balance > 0;
    return Material(
      color: AppSurfaces.forContext(context).surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppSurfaces.forContext(context).border),
            boxShadow: Theme.of(context).brightness == Brightness.light
                ? [
                    BoxShadow(
                      color: AppPalette.ink.withValues(alpha: .04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppPalette.softGold,
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: AppPalette.darkGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasDebt ? 'دين مستحق' : 'لا يوجد دين',
                      style: TextStyle(
                        color: AppSurfaces.forContext(context).muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatAmount(account.balance)} ₪',
                    style: TextStyle(
                      color: hasDebt ? AppPalette.goldDark : AppPalette.success,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDebt ? 'دين مستحق' : 'الحساب مسدد',
                    style: TextStyle(
                      color: AppSurfaces.forContext(context).muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClientEntryCard extends StatelessWidget {
  const ClientEntryCard({super.key, required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final title = entry.product.trim().isEmpty
        ? entry.typeLabel
        : entry.product;
    final isPayment = entry.type == LedgerEntryType.payment;
    final sign = isPayment ? '−' : '+';

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      borderRadius: 20,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
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
            '$sign${formatAmount(entry.amount)} ₪',
            style: TextStyle(
              color: isPayment ? AppPalette.success : AppPalette.goldDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
