class Country {
  final String code;
  final String emoji;
  final String name;
  final String? format;

  Country({
    required this.code,
    required this.emoji,
    required this.name,
    this.format,
  });
}
