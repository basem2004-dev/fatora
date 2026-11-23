import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/ledger/ledger_entry.dart';

Future<LedgerEntryType?> showTransactionTypePicker(BuildContext context) {
  return showModalBottomSheet<LedgerEntryType>(
    context: context,
    backgroundColor: AppSurfaces.forContext(context).surface,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'اختر نوع العملية',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            const _TransactionTypeChoice(
              icon: Icons.receipt_long_outlined,
              label: 'تسجيل فاتورة',
              type: LedgerEntryType.invoice,
            ),
            const _TransactionTypeChoice(
              icon: Icons.history_rounded,
              label: 'إضافة دين قديم',
              type: LedgerEntryType.debt,
            ),
            const _TransactionTypeChoice(
              icon: Icons.payments_outlined,
              label: 'تسجيل دفعة',
              type: LedgerEntryType.payment,
            ),
          ],
        ),
      ),
    ),
  );
}

class _TransactionTypeChoice extends StatelessWidget {
  const _TransactionTypeChoice({
    required this.icon,
    required this.label,
    required this.type,
  });

  final IconData icon;
  final String label;
  final LedgerEntryType type;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppPalette.primaryGreen),
      title: Text(label, textAlign: TextAlign.right),
      onTap: () => Navigator.pop(context, type),
    );
  }
}
