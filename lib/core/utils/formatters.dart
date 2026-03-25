/// Display formatters (numbers, percentages, text). Keep domain-agnostic.

/// Formats a 0–100 value as "72%" for display.
String formatPercent(int value) {
  return '$value%';
}

/// Truncates [text] to [maxLength] with ellipsis.
String truncateWithEllipsis(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}…';
}
