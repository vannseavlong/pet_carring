abstract final class DateFormatter {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String toDisplay(DateTime date) =>
      '${_months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';

  static String toApi(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static DateTime fromApi(String date) => DateTime.parse(date);
}
