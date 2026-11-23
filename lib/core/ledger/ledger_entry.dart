/// عملية واحدة محفوظة في دفتر العميل.
enum LedgerEntryType { invoice, debt, payment }

class LedgerEntry {
  const LedgerEntry({
    this.id,
    required this.customerName,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.product = '',
    this.isPaid = false,
    this.isOldDebt = false,
  });

  final int? id;
  final String customerName;
  final double amount;
  final LedgerEntryType type;
  final DateTime createdAt;
  final String product;
  final bool isPaid;
  final bool isOldDebt;

  double get signedAmount {
    if (type == LedgerEntryType.payment) return -amount;
    if (type == LedgerEntryType.invoice && isPaid) return 0;
    return amount;
  }

  double get reportAmount => type == LedgerEntryType.payment ? -amount : amount;

  String get typeLabel {
    if (type == LedgerEntryType.invoice) {
      return isPaid ? 'فاتورة مدفوعة' : 'فاتورة غير مدفوعة';
    }
    if (type == LedgerEntryType.debt) return 'دين';
    return 'دفعة';
  }

  LedgerEntry copyWith({
    int? id,
    String? customerName,
    double? amount,
    LedgerEntryType? type,
    DateTime? createdAt,
    String? product,
    bool? isPaid,
    bool? isOldDebt,
  }) => LedgerEntry(
    id: id ?? this.id,
    customerName: customerName ?? this.customerName,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
    product: product ?? this.product,
    isPaid: isPaid ?? this.isPaid,
    isOldDebt: isOldDebt ?? this.isOldDebt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'customerName': customerName,
    'amount': amount,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
    'product': product,
    'isPaid': isPaid,
    // نحتفظ بالقيمة السابقة حتى تبقى العمليات القديمة مقروءة.
    'isOldDebt': type == LedgerEntryType.invoice ? isPaid : isOldDebt,
  };

  factory LedgerEntry.fromMap(Map<Object?, Object?> map) {
    final typeName = map['type'] as String;
    LedgerEntryType type = LedgerEntryType.invoice;
    if (typeName == 'debt') {
      type = LedgerEntryType.debt;
    } else if (typeName == 'payment') {
      type = LedgerEntryType.payment;
    }
    final oldFlag =
        map['isOldDebt'] == true ||
        (map['isOldDebt'] is num && (map['isOldDebt'] as num).toInt() == 1);
    final paidFlag =
        map['isPaid'] == true ||
        (map['isPaid'] is num && (map['isPaid'] as num).toInt() == 1);

    return LedgerEntry(
      id: (map['id'] as num).toInt(),
      customerName: map['customerName'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: type,
      createdAt: DateTime.parse(map['createdAt'] as String),
      product: map['product'] as String? ?? '',
      isPaid: paidFlag || (type == LedgerEntryType.invoice && oldFlag),
      isOldDebt: type == LedgerEntryType.debt && oldFlag,
    );
  }
}
