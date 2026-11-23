import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/widgets/custom_screen_header.dart';
import 'package:fatora/core/widgets/show_message.dart';
import 'package:fatora/core/widgets/custom_card.dart';
import 'package:fatora/core/utils/amount_formatters.dart';
import 'package:fatora/features/clients/data/client_account.dart';
import 'package:fatora/features/clients/widget/client_account_cards.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({
    super.key,
    required this.accounts,
    required this.onDeleteCustomer,
  });

  final List<ClientAccount> accounts;
  final ValueChanged<String> onDeleteCustomer;

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.accounts
        .where((account) => account.name.toLowerCase().contains(_query))
        .toList(growable: false);
    final openBalance = widget.accounts.fold<double>(
      0,
      (total, account) => total + account.balance,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomScreenHeader(title: 'العملاء'),
          const SizedBox(height: 8),
          CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            borderRadius: 22,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppPalette.softGold,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: AppPalette.darkGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.accounts.length} عميل',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'إجمالي الذمم المسجلة',
                        style: TextStyle(
                          color: AppSurfaces.forContext(context).muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${formatAmount(openBalance)} ₪',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: AppPalette.goldDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'دور على اسم عميل ...',
              prefixIcon: Icon(
                Icons.search,
                color: AppSurfaces.forContext(context).muted,
              ),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close, size: 18),
                    ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: accounts.isEmpty
                ? Center(
                    child: Text(
                      'لا يوجد عملاء',
                      style: TextStyle(
                        color: AppSurfaces.forContext(context).muted,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 10),
                    itemCount: accounts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return ClientCard(
                        account: account,
                        onTap: () => Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => ClientDetailsScreen(
                              account: account,
                              onDelete: () =>
                                  widget.onDeleteCustomer(account.name),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ClientDetailsScreen extends StatelessWidget {
  const ClientDetailsScreen({
    super.key,
    required this.account,
    required this.onDelete,
  });

  final ClientAccount account;
  final VoidCallback onDelete;

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف ${account.name}؟'),
        content: const Text('سيتم حذف العميل وكل عملياته المسجلة معه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppPalette.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !context.mounted) return;
    onDelete();
    showMessage(context, 'تم حذف العميل وعملياته');
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomScreenHeader(
                title: account.name,
                onBack: () => Navigator.maybePop(context),
                leadingAction: IconButton(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppPalette.error,
                  ),
                  tooltip: 'حذف العميل',
                ),
              ),
              const SizedBox(height: 18),
              CustomCard(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppSurfaces.forContext(context).raised,
                      child: Icon(
                        Icons.person,
                        color: AppSurfaces.forContext(context).muted,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${formatAmount(account.balance)} ₪',
                      style: const TextStyle(
                        color: AppPalette.goldDark,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'إجمالي الدين المتبقي',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'كل العمليات مع ${account.name} (${account.entries.length})',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppSurfaces.forContext(context).muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: account.entries.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد عمليات لهذا العميل',
                          style: TextStyle(
                            color: AppSurfaces.forContext(context).muted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: account.entries.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            ClientEntryCard(entry: account.entries[index]),
                      ),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.description_outlined),
                label: const Text('تصدير كشف PDF — غير متاح حالياً'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppSurfaces.forContext(context).surface,
                  foregroundColor: AppSurfaces.forContext(context).text,
                  side: BorderSide(
                    color: AppSurfaces.forContext(context).border,
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
