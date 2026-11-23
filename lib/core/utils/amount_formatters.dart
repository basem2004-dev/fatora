String formatAmount(double amount) =>
    amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);

String formatEntryTime(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour < 12 ? 'ص' : 'م';
  return '$hour:$minute $period';
}

String formatArabicDate(DateTime dateTime) {
  const weekdays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  const months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  return '${weekdays[dateTime.weekday - 1]}، ${dateTime.day} '
      '${months[dateTime.month - 1]} ${dateTime.year}';
}
