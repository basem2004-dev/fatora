import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/widgets/show_message.dart';
import 'package:fatora/core/ledger/ledger_storage.dart';
import 'package:fatora/features/clients/data/client_account.dart';
import 'package:fatora/features/clients/view/clients_view.dart';
import 'package:fatora/features/home/data/home_summary.dart';
import 'package:fatora/features/home/view/home_view.dart';
import 'package:fatora/features/invoices/view/invoices_view.dart';
import 'package:fatora/core/ledger/ledger_entry.dart';
import 'package:fatora/features/reports/view/reports_view.dart';
import 'package:fatora/features/settings/view/settings_view.dart';
import 'package:fatora/features/transaction_form/view/transaction_form_view.dart';
import 'package:fatora/features/voice_capture/view/voice_capture_view.dart';
import 'package:fatora/features/app_shell/data/app_tab.dart';
import 'package:fatora/features/app_shell/widget/app_bottom_bar.dart';
import 'package:fatora/features/transaction_form/widget/transaction_type_picker.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final LedgerStorage _ledgerStorage = LedgerStorage();
  AppTab _selectedTab = AppTab.home;
  bool _isLoading = true;
  Map<String, String> _profile = const <String, String>{};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      await _ledgerStorage.loadEntries();
      _profile = await _ledgerStorage.loadShopProfile();
    } catch (error) {
      if (mounted && !kIsWeb) {
        showMessage(context, 'تعذر تحميل قاعدة البيانات: $error');
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveShopProfile(String shopName, String phone) async {
    try {
      await _ledgerStorage.saveShopProfile(shopName: shopName, phone: phone);
      if (!mounted) return;
      setState(() => _profile = {'shopName': shopName, 'phone': phone});
      showMessage(context, 'تم حفظ بيانات المحل');
    } catch (error) {
      if (mounted) showMessage(context, 'تعذر حفظ بيانات المحل: $error');
    }
  }

  Future<void> _addTransaction() async {
    final type = await showTransactionTypePicker(context);
    if (!mounted || type == null) return;

    final entry = await Navigator.of(context).push<LedgerEntry>(
      MaterialPageRoute<LedgerEntry>(
        builder: (_) => TransactionFormScreen(type: type),
      ),
    );
    if (!mounted || entry == null) return;

    await _saveTransaction(entry);
  }

  Future<void> _addVoiceTransaction() async {
    final entry = await Navigator.of(context).push<LedgerEntry>(
      MaterialPageRoute<LedgerEntry>(
        builder: (_) => const VoiceCaptureScreen(),
      ),
    );
    if (!mounted || entry == null) return;
    await _saveTransaction(entry);
  }

  Future<void> _saveTransaction(LedgerEntry entry) async {
    try {
      await _ledgerStorage.addEntry(entry);
      if (!mounted) return;
      setState(() {});
      showMessage(context, 'تم تسجيل العملية في قاعدة البيانات');
    } catch (error) {
      if (mounted) showMessage(context, 'تعذر حفظ العملية: $error');
    }
  }

  void _editEntry(LedgerEntry oldEntry, LedgerEntry newEntry) {
    unawaited(_saveEditedTransaction(oldEntry, newEntry));
  }

  Future<void> _saveEditedTransaction(
    LedgerEntry oldEntry,
    LedgerEntry newEntry,
  ) async {
    try {
      if (!await _ledgerStorage.updateEntry(oldEntry, newEntry)) return;
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) showMessage(context, 'تعذر تعديل العملية: $error');
    }
  }

  void _deleteEntry(LedgerEntry entry) {
    unawaited(_removeTransaction(entry));
  }

  Future<void> _removeTransaction(LedgerEntry entry) async {
    try {
      if (await _ledgerStorage.deleteEntry(entry) && mounted) setState(() {});
    } catch (error) {
      if (mounted) showMessage(context, 'تعذر حذف العملية: $error');
    }
  }

  void _deleteCustomer(String customerName) {
    unawaited(_removeCustomer(customerName));
  }

  Future<void> _removeCustomer(String customerName) async {
    try {
      await _ledgerStorage.deleteCustomer(customerName);
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) showMessage(context, 'تعذر حذف العميل: $error');
    }
  }

  void _clearLedger() {
    unawaited(_removeAllTransactions());
  }

  Future<void> _removeAllTransactions() async {
    try {
      await _ledgerStorage.clearEntries();
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) showMessage(context, 'تعذر مسح البيانات: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final entries = _ledgerStorage.entries;
    final accounts = ClientAccount.fromEntries(entries);
    final homeSummary = HomeSummary.fromLedgerStorage(_ledgerStorage);
    final screens = [
      HomeScreen(
        summary: homeSummary,
        onVoiceTap: _addVoiceTransaction,
        onManualEntry: _addTransaction,
        onViewInvoices: () => setState(() => _selectedTab = AppTab.invoices),
      ),
      InvoicesScreen(
        entries: entries,
        balances: _ledgerStorage.balances,
        onAdd: _addTransaction,
        onDeleted: _deleteEntry,
        onEdited: _editEntry,
        onOpenReport: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => ReportsScreen(entries: entries),
          ),
        ),
      ),
      ClientsScreen(accounts: accounts, onDeleteCustomer: _deleteCustomer),
      SettingsScreen(
        profile: _profile,
        onSaveProfile: _saveShopProfile,
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        customerCount: _ledgerStorage.customerCount,
        operationCount: _ledgerStorage.operationCount,
        onClearData: _clearLedger,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedTab.index, children: screens),
      ),
      bottomNavigationBar: AppBottomBar(
        selectedIndex: _selectedTab.index,
        onSelect: (index) =>
            setState(() => _selectedTab = AppTab.values[index]),
      ),
    );
  }
}
