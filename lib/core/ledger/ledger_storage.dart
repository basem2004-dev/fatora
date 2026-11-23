import 'package:flutter/services.dart';

import 'package:fatora/core/ledger/ledger_entry.dart';

/// يقرأ العمليات ويحفظها في قاعدة بيانات أندرويد عن طريق Kotlin.
class LedgerStorage {
  static const MethodChannel _channel = MethodChannel(
    'com.example.fatora/ledger',
  );

  List<LedgerEntry> _entries = [];
  List<LedgerEntry> get entries => List.unmodifiable(_entries);

  Map<String, double> get balances {
    final totals = <String, double>{};
    for (final entry in _entries) {
      final oldBalance = totals[entry.customerName] ?? 0;
      totals[entry.customerName] = oldBalance + entry.signedAmount;
    }
    return Map.unmodifiable(totals);
  }

  double get totalBalance {
    double total = 0;
    for (final balance in balances.values) {
      total += balance;
    }
    return total;
  }

  int get customerCount => balances.length;
  int get operationCount => _entries.length;

  double salesOn(DateTime day) {
    double total = 0;
    for (final entry in _entries) {
      final isInvoice = entry.type == LedgerEntryType.invoice;
      final isSameDay =
          entry.createdAt.year == day.year &&
          entry.createdAt.month == day.month &&
          entry.createdAt.day == day.day;
      if (isInvoice && isSameDay) total += entry.amount;
    }
    return total;
  }

  Future<void> loadEntries() async {
    final rows = await _channel.invokeListMethod<Object?>('getEntries');
    final loadedEntries = <LedgerEntry>[];
    for (final row in rows ?? const <Object?>[]) {
      if (row is Map<Object?, Object?>) {
        loadedEntries.add(LedgerEntry.fromMap(row));
      }
    }
    _entries = loadedEntries;
  }

  Future<Map<String, String>> loadShopProfile() async {
    final values = await _channel.invokeMapMethod<String, String>('getProfile');
    return Map.unmodifiable(values ?? const <String, String>{});
  }

  Future<void> saveShopProfile({
    required String shopName,
    required String phone,
  }) => _channel.invokeMethod<void>('saveProfile', {
    'shopName': shopName,
    'phone': phone,
  });

  Future<LedgerEntry> addEntry(LedgerEntry entry) async {
    final id = await _channel.invokeMethod<int>('addEntry', entry.toMap());
    final savedEntry = entry.copyWith(id: id);
    _entries.insert(0, savedEntry);
    return savedEntry;
  }

  Future<bool> updateEntry(LedgerEntry oldEntry, LedgerEntry newEntry) async {
    final id = oldEntry.id;
    if (id == null) return false;
    final savedValues = newEntry.copyWith(id: id).toMap();
    final didUpdate = await _channel.invokeMethod<bool>(
      'updateEntry',
      savedValues,
    );
    if (didUpdate != true) return false;
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index < 0) return false;
    _entries[index] = newEntry.copyWith(id: id);
    return true;
  }

  Future<bool> deleteEntry(LedgerEntry entry) async {
    final id = entry.id;
    if (id == null) return false;
    final didDelete = await _channel.invokeMethod<bool>('deleteEntry', {
      'id': id,
    });
    if (didDelete != true) return false;
    _entries.removeWhere((savedEntry) => savedEntry.id == id);
    return true;
  }

  Future<int> deleteCustomer(String customerName) async {
    final deletedCount = await _channel.invokeMethod<int>('deleteCustomer', {
      'customerName': customerName,
    });
    _entries.removeWhere((entry) => entry.customerName == customerName);
    return deletedCount ?? 0;
  }

  Future<void> clearEntries() async {
    await _channel.invokeMethod<void>('clear');
    _entries.clear();
  }
}
