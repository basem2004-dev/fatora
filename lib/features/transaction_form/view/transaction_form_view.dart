import 'package:material_ui/material_ui.dart';

import 'package:fatora/core/app_theme.dart';
import 'package:fatora/core/widgets/custom_field_block.dart';
import 'package:fatora/core/widgets/custom_button.dart';
import 'package:fatora/core/widgets/custom_screen_header.dart';
import 'package:fatora/core/widgets/custom_card.dart';
import 'package:fatora/core/widgets/custom_text_field.dart';
import 'package:fatora/core/ledger/ledger_entry.dart';
import 'package:fatora/features/transaction_form/data/transaction_form_labels.dart';
import 'package:fatora/features/transaction_form/widget/transaction_type_menu.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({
    super.key,
    required this.type,
    this.initialCustomerName,
    this.initialProduct,
    this.initialAmount,
    this.initialIsPaid = false,
    this.recognizedText,
  });

  final LedgerEntryType type;
  final String? initialCustomerName;
  final String? initialProduct;
  final double? initialAmount;
  final bool initialIsPaid;
  final String? recognizedText;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  late LedgerEntryType _type;
  late bool _isPaid;
  late final TextEditingController _customerController;
  late final TextEditingController _productController;
  late final TextEditingController _amountController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    _isPaid = widget.initialIsPaid;
    _customerController = TextEditingController(
      text: widget.initialCustomerName ?? '',
    );
    _productController = TextEditingController(
      text: widget.initialProduct ?? '',
    );
    _amountController = TextEditingController(
      text: widget.initialAmount?.toString() ?? '',
    );
  }

  void _changeType(LedgerEntryType? type) {
    if (type == null) return;
    setState(() {
      _type = type;
      if (type != LedgerEntryType.invoice) _isPaid = false;
    });
    if (widget.initialCustomerName == null) _customerController.clear();
    _productController.clear();
    _amountController.clear();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) return;

    Navigator.of(context).pop(
      LedgerEntry(
        customerName: _customerController.text.trim(),
        product: _productController.text.trim(),
        amount: amount,
        type: _type,
        createdAt: DateTime.now(),
        isPaid: _type == LedgerEntryType.invoice && _isPaid,
        isOldDebt: _type == LedgerEntryType.debt,
      ),
    );
  }

  @override
  void dispose() {
    _customerController.dispose();
    _productController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPayment = _type == LedgerEntryType.payment;
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomScreenHeader(
                  title: TransactionFormLabels.title(_type),
                  onBack: () => Navigator.maybePop(context),
                  leadingAction: TransactionTypeMenu(onSelected: _changeType),
                ),
                if (widget.recognizedText != null) ...[
                  const SizedBox(height: 14),
                  CustomCard(
                    padding: const EdgeInsets.all(13),
                    child: Text(
                      'النص المسموع: ${widget.recognizedText}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppSurfaces.forContext(context).muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 7),
                Text(
                  'أدخل التفاصيل، ثم اختر إن كانت الفاتورة مدفوعة الآن.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppSurfaces.forContext(context).muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 23),
                CustomFieldBlock(
                  label: 'اسم العميل',
                  child: CustomTextField(
                    controller: _customerController,
                    textInputAction: TextInputAction.next,
                    hintText: 'اسم العميل',
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'اكتب اسم العميل'
                        : null,
                  ),
                ),
                if (!isPayment) ...[
                  const SizedBox(height: 23),
                  CustomFieldBlock(
                    label: 'المنتج (اختياري)',
                    child: CustomTextField(
                      controller: _productController,
                      textInputAction: TextInputAction.next,
                      hintText: 'اسم المنتج',
                    ),
                  ),
                ],
                if (_type == LedgerEntryType.invoice) ...[
                  const SizedBox(height: 15),
                  CustomCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'مدفوعة الآن',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _isPaid
                                    ? 'تُسجل كمبيعة ولا تُضاف إلى دين العميل'
                                    : 'تُضاف إلى مستحقات العميل',
                                style: TextStyle(
                                  color: AppSurfaces.forContext(context).muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isPaid,
                          activeTrackColor: AppPalette.primaryGreen,
                          onChanged: (value) => setState(() => _isPaid = value),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: isPayment ? 23 : 25),
                CustomFieldBlock(
                  label: 'المبلغ (شيكل)',
                  child: CustomTextField(
                    controller: _amountController,
                    hintText: '0',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      final amount = double.tryParse(value?.trim() ?? '');
                      if (amount == null || amount <= 0) {
                        return 'أدخل مبلغاً صحيحاً';
                      }
                      return null;
                    },
                    onSubmitted: (_) => _save(),
                  ),
                ),
                SizedBox(height: isPayment ? 34 : 43),
                CustomButton(
                  label: TransactionFormLabels.saveLabel(_type),
                  onPressed: _save,
                ),
                if (isPayment) ...[
                  const SizedBox(height: 25),
                  CustomCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 22,
                    ),
                    child: Text(
                      'تُسجّل الدفعة باسم العميل المكتوب هنا وتُخصم من رصيده.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppSurfaces.forContext(context).muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
