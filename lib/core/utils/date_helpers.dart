/// Date formatting and relative-time helpers. Use for display, not business logic.

/// Formats [DateTime] for display (e.g. "23 Feb 2026").
String formatDisplayDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Returns start of week (Monday) for the given [date].
DateTime startOfWeek(DateTime date) {
  final weekday = date.weekday;
  return DateTime(date.year, date.month, date.day - (weekday - 1));
}
