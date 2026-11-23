import 'package:fatora/core/ledger/ledger_entry.dart';
import 'package:fatora/core/ledger/ledger_storage.dart';

class HomeSummary {
  const HomeSummary({
    required this.totalBalance,
    required this.todaySales,
    required this.todayOperations,
    required this.recentEntries,
  });

  factory HomeSummary.fromLedgerStorage(LedgerStorage ledgerStorage) {
    final now = DateTime.now();
    final todayOperations = ledgerStorage.entries.where((entry) {
      return entry.createdAt.year == now.year &&
          entry.createdAt.month == now.month &&
          entry.createdAt.day == now.day;
    }).length;
    return HomeSummary(
      totalBalance: ledgerStorage.totalBalance,
      todaySales: ledgerStorage.salesOn(DateTime.now()),
      todayOperations: todayOperations,
      recentEntries: ledgerStorage.entries.take(3).toList(growable: false),
    );
  }

  final double totalBalance;
  final double todaySales;
  final int todayOperations;
  final List<LedgerEntry> recentEntries;
}
