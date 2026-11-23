import 'package:fatora/core/ledger/ledger_entry.dart';

enum ReportFilter {
  all,
  debts,
  payments;

  String get label {
    if (this == ReportFilter.all) return 'الكل';
    if (this == ReportFilter.debts) return 'المستحقات';
    return 'دفعة';
  }

  bool includes(LedgerEntry entry) {
    if (this == ReportFilter.all) return true;
    if (this == ReportFilter.debts) {
      return entry.type == LedgerEntryType.debt ||
          (entry.type == LedgerEntryType.invoice && !entry.isPaid);
    }
    return entry.type == LedgerEntryType.payment;
  }
}

class SalesReport {
  const SalesReport({required this.entries});

  factory SalesReport.forPeriod({
    required List<LedgerEntry> source,
    required DateTime date,
    required bool monthly,
    required ReportFilter filter,
  }) {
    final entries = <LedgerEntry>[];
    for (final entry in source) {
      final sameYear = entry.createdAt.year == date.year;
      final sameMonth = entry.createdAt.month == date.month;
      final sameDay = entry.createdAt.day == date.day;
      final samePeriod = monthly
          ? sameYear && sameMonth
          : sameYear && sameMonth && sameDay;

      if (samePeriod && filter.includes(entry)) {
        entries.add(entry);
      }
    }
    return SalesReport(entries: entries);
  }

  final List<LedgerEntry> entries;

  double get net {
    double total = 0;
    for (final entry in entries) {
      total += entry.reportAmount;
    }
    return total;
  }
}
