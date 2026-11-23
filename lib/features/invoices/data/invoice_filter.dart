import 'package:fatora/core/ledger/ledger_entry.dart';

enum InvoiceFilter {
  all,
  debts,
  payments;

  String get label {
    if (this == InvoiceFilter.all) return 'الكل';
    if (this == InvoiceFilter.debts) return 'المستحقات';
    return 'دفعة';
  }

  bool includes(LedgerEntry entry) {
    if (this == InvoiceFilter.all) return true;
    if (this == InvoiceFilter.debts) {
      return entry.type == LedgerEntryType.debt ||
          (entry.type == LedgerEntryType.invoice && !entry.isPaid);
    }
    return entry.type == LedgerEntryType.payment;
  }
}
