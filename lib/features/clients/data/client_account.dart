import 'package:fatora/core/ledger/ledger_entry.dart';

class ClientAccount {
  const ClientAccount({
    required this.name,
    required this.balance,
    required this.entries,
  });

  final String name;
  final double balance;
  final List<LedgerEntry> entries;

  static List<ClientAccount> fromEntries(List<LedgerEntry> entries) {
    final grouped = <String, List<LedgerEntry>>{};
    for (final entry in entries) {
      final customerEntries = grouped[entry.customerName] ?? <LedgerEntry>[];
      customerEntries.add(entry);
      grouped[entry.customerName] = customerEntries;
    }

    final accounts = <ClientAccount>[];
    for (final group in grouped.entries) {
      double balance = 0;
      for (final entry in group.value) {
        balance += entry.signedAmount;
      }
      accounts.add(
        ClientAccount(
          name: group.key,
          balance: balance,
          entries: List.unmodifiable(group.value),
        ),
      );
    }
    accounts.sort((first, second) => first.name.compareTo(second.name));

    return List.unmodifiable(accounts);
  }
}
