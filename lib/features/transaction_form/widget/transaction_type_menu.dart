import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/ledger/ledger_entry.dart';
import 'package:fatora/features/transaction_form/data/transaction_form_labels.dart';

class TransactionTypeMenu extends StatelessWidget {
  const TransactionTypeMenu({super.key, required this.onSelected});

  final ValueChanged<LedgerEntryType?> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<LedgerEntryType>(
      tooltip: 'تغيير نوع العملية',
      onSelected: (type) => onSelected(type),
      color: Theme.of(context).colorScheme.surface,
      icon: const Icon(Icons.swap_horiz, size: 20),
      itemBuilder: (context) => LedgerEntryType.values
          .map(
            (type) => PopupMenuItem(
              value: type,
              child: Text(TransactionFormLabels.title(type)),
            ),
          )
          .toList(),
    );
  }
}
