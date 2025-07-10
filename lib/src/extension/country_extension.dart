extension CountryFlagExtension on String {
  String get countryEmoji {
    String defaultEmoji = '🌐';
    String anonymous = '👤';
    if (length != 2 || this == 'GO' || this == 'YL') return defaultEmoji;
    if (this == 'FT') return anonymous;

    final upper = toUpperCase();
    final isValid = upper.codeUnits.every(
      (codeUnit) => codeUnit >= 65 && codeUnit <= 90,
    );
    if (!isValid) return defaultEmoji;

    return String.fromCharCode(0x1F1E6 + upper.codeUnitAt(0) - 65) +
        String.fromCharCode(0x1F1E6 + upper.codeUnitAt(1) - 65);
  }
}
