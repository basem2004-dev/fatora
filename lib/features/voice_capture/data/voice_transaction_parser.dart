import 'package:fatora/core/ledger/ledger_entry.dart';

class VoiceTransactionDraft {
  const VoiceTransactionDraft({
    required this.type,
    required this.customerName,
    required this.product,
    required this.amount,
    required this.isPaid,
  });

  final LedgerEntryType type;
  final String customerName;
  final String product;
  final double? amount;
  final bool isPaid;
}

class VoiceTransactionParser {
  static const Map<String, double> _spokenNumbers = {
    'واحد': 1,
    'واحدة': 1,
    'اثنين': 2,
    'اتنين': 2,
    'ثلاثة': 3,
    'تلاتة': 3,
    'أربعة': 4,
    'اربعة': 4,
    'خمسة': 5,
    'ستة': 6,
    'سبعة': 7,
    'ثمانية': 8,
    'تسعة': 9,
    'عشرة': 10,
    'عشرين': 20,
    'ثلاثين': 30,
    'تلاتين': 30,
    'أربعين': 40,
    'اربعين': 40,
    'خمسين': 50,
    'ستين': 60,
    'سبعين': 70,
    'ثمانين': 80,
    'تسعين': 90,
    'مية': 100,
    'مئة': 100,
    'مائة': 100,
  };

  static const Set<String> _purchaseWords = {
    'اشترى',
    'اشترت',
    'شراء',
    'اتشرى',
    'اشتر',
    'أخذ',
    'اخذ',
    'باع',
  };

  static const Set<String> _debtWords = {'دين', 'دَين', 'استدان', 'استلف'};

  static const Set<String> _paymentWords = {
    'دفع',
    'دفعت',
    'يدفع',
    'دفعة',
    'دفعها',
    'دفعه',
    'سدد',
    'سددت',
    'يسدد',
    'تسديد',
  };

  static const Set<String> _cashWords = {
    'نقدا',
    'نقداً',
    'كاش',
    'مدفوع',
    'مدفوعة',
    'فورا',
    'فوراً',
    'هسا',
    'حالا',
    'حالاً',
    'بلحظتها',
  };

  static const Set<String> _commandWords = {
    'سجل',
    'سجّل',
    'اكتب',
    'ضيف',
    'أضف',
    'فاتورة',
    'دين',
    'دفعة',
  };

  static const Set<String> _recordWords = {'سجل', 'سجّل', 'اكتب', 'ضيف', 'أضف'};

  static const Set<String> _extraWords = {
    'على',
    'الحساب',
    'إلى',
    'الى',
    'من',
    'ل',
    'لـ',
    'ب',
    'بـ',
    'بمبلغ',
    'شيكل',
    'شاقل',
    'شيقل',
    'جنيه',
  };

  static final RegExp _numberPattern = RegExp(r'\d+(?:[.,]\d+)?');

  static VoiceTransactionDraft makeDraftFromWords(String words) {
    final text = _cleanText(words);
    final type = _findType(text);
    final amount = _findAmount(text);
    final customerName = _findCustomerName(text);
    final product = type == LedgerEntryType.payment
        ? ''
        : _findProductName(text, customerName);
    final isPaid =
        type == LedgerEntryType.invoice &&
        (_hasAnyWord(text, _cashWords) || _hasAnyWord(text, _paymentWords));

    return VoiceTransactionDraft(
      type: type,
      customerName: customerName,
      product: product,
      amount: amount,
      isPaid: isPaid,
    );
  }

  static LedgerEntryType _findType(String text) {
    final isPurchase = _hasAnyWord(text, _purchaseWords);
    final isInvoiceCommand =
        text.contains('فاتورة') && _hasAnyWord(text, _recordWords);
    final isDebt = _hasAnyWord(text, _debtWords) || text.contains('على الحساب');
    final isPayment =
        _hasAnyWord(text, _paymentWords) || _hasAnyWord(text, _cashWords);

    if (isPurchase || isInvoiceCommand) {
      if (isDebt) return LedgerEntryType.debt;
      return LedgerEntryType.invoice;
    }
    if (isPayment) return LedgerEntryType.payment;
    if (isDebt) return LedgerEntryType.debt;
    return LedgerEntryType.invoice;
  }

  static double? _findAmount(String text) {
    final number = _numberPattern.firstMatch(text);
    if (number != null) {
      final value = number.group(0)!.replaceAll(',', '.');
      return double.tryParse(value);
    }

    for (final word in text.split(' ')) {
      final amount =
          _spokenNumbers[word] ??
          (word.startsWith('و') ? _spokenNumbers[word.substring(1)] : null);
      if (amount != null) return amount;
    }
    return null;
  }

  static String _findCustomerName(String text) {
    final amountMatch = _numberPattern.firstMatch(text);
    final beforeAmount = amountMatch == null
        ? text
        : text.substring(0, amountMatch.start);
    final words = beforeAmount.split(' ');

    for (var index = 0; index < words.length; index++) {
      final word = words[index];
      final isAction =
          _hasWord(_purchaseWords, word) || _hasWord(_paymentWords, word);
      if (isAction && index > 0) {
        return _keepNameWords(words.take(index));
      }
    }

    return _keepNameWords(words);
  }

  static String _findProductName(String text, String customerName) {
    final customerWords = customerName.split(' ').toSet();
    final productWords = <String>[];

    for (final originalWord in text.split(' ')) {
      final word = _cleanWord(originalWord);
      if (word.isEmpty || customerWords.contains(word)) continue;
      if (_isAmountWord(word) || _isExtraWord(word)) continue;
      if (_numberPattern.hasMatch(word)) continue;
      productWords.add(word);
    }

    return productWords.join(' ');
  }

  static String _keepNameWords(Iterable<String> words) {
    final nameWords = <String>[];

    for (final originalWord in words) {
      final word = _cleanWord(originalWord);
      if (word.isEmpty) continue;
      if (_isAmountWord(word) || _isExtraWord(word)) continue;
      if (_numberPattern.hasMatch(word)) continue;
      nameWords.add(word);
    }

    return nameWords.join(' ');
  }

  static bool _isAmountWord(String word) {
    if (_spokenNumbers.containsKey(word)) return true;
    return word.startsWith('و') &&
        _spokenNumbers.containsKey(word.substring(1));
  }

  static bool _isExtraWord(String word) {
    return _hasWord(_purchaseWords, word) ||
        _hasWord(_debtWords, word) ||
        _hasWord(_paymentWords, word) ||
        _hasWord(_cashWords, word) ||
        _hasWord(_commandWords, word) ||
        _hasWord(_extraWords, word);
  }

  static bool _hasAnyWord(String text, Set<String> words) {
    for (final word in text.split(' ')) {
      if (_hasWord(words, word)) return true;
    }
    return false;
  }

  static bool _hasWord(Set<String> words, String word) {
    if (words.contains(word)) return true;
    if (word.startsWith('و') && words.contains(word.substring(1))) {
      return true;
    }
    return false;
  }

  static String _cleanWord(String word) {
    return word.replaceAll(RegExp(r'^[،,:؛؟!.]+|[،,:؛؟!.]+$'), '');
  }

  static String _cleanText(String source) {
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    var text = source.trim();

    for (var index = 0; index < arabicDigits.length; index++) {
      text = text.replaceAll(arabicDigits[index], '$index');
    }

    text = text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    text = text.replaceAll(RegExp(r'[،؛؟!]+'), ' ');
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
