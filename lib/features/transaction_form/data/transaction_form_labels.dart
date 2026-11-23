import 'package:fatora/core/ledger/ledger_entry.dart';

class TransactionFormLabels {
  static String title(LedgerEntryType type) {
    if (type == LedgerEntryType.invoice) return 'تسجيل فاتورة';
    if (type == LedgerEntryType.debt) return 'إضافة دين';
    return 'تسجيل دفعة';
  }

  static String saveLabel(LedgerEntryType type) {
    if (type == LedgerEntryType.invoice) return 'تسجيل فاتورة';
    if (type == LedgerEntryType.debt) return 'حفظ الدين';
    return 'حفظ الدفعة';
  }

  static String reviewLabel(LedgerEntryType type) {
    if (type == LedgerEntryType.invoice) return 'مراجعة وتعديل الفاتورة';
    if (type == LedgerEntryType.debt) return 'مراجعة وتعديل الدين';
    return 'مراجعة وتعديل الدفعة';
  }
}
