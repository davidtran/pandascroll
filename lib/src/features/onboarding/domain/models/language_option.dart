class LanguageOption {
  final String code;
  final String name;
  final String subtitle; // Native name or "Hello"
  final String flagUrl;
  final bool available;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.subtitle,
    required this.flagUrl,
    this.available = true,
  });
}
