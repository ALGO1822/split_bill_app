class CurrencyModel {
  final String symbol;
  final String code;
  final String locale;
  final bool hasDecimals;

  const CurrencyModel({
    required this.symbol,
    required this.code,
    required this.locale,
    required this.hasDecimals,
  });

  // The true compile-time default
  static const CurrencyModel nairas = CurrencyModel(symbol: '₦', code: 'NGN', locale: 'en_NG', hasDecimals: true);

  static const List<CurrencyModel> presets = [
    // Africa
    nairas,
    CurrencyModel(symbol: 'R', code: 'ZAR', locale: 'en_ZA', hasDecimals: true), // South African Rand
    CurrencyModel(symbol: '₵', code: 'GHS', locale: 'en_GH', hasDecimals: true), // Cedi

    // Americas
    CurrencyModel(symbol: '\$', code: 'USD', locale: 'en_US', hasDecimals: true),
    CurrencyModel(symbol: '\$', code: 'CAD', locale: 'en_CA', hasDecimals: true), // Canadian Dollar
    CurrencyModel(symbol: '\$', code: 'MXN', locale: 'es_MX', hasDecimals: true), // Mexican Peso

    // Europe
    CurrencyModel(symbol: '€', code: 'EUR', locale: 'fr_FR', hasDecimals: true), // Euro (using France for comma formats)
    CurrencyModel(symbol: '£', code: 'GBP', locale: 'en_GB', hasDecimals: true), // British Pound

    // Asia & Oceania
    CurrencyModel(symbol: '¥', code: 'JPY', locale: 'ja_JP', hasDecimals: false), // Japanese Yen (NO DECIMALS)
    CurrencyModel(symbol: '₹', code: 'INR', locale: 'en_IN', hasDecimals: true), // Indian Rupee
    CurrencyModel(symbol: '¥', code: 'CNY', locale: 'zh_CN', hasDecimals: true), // Chinese Yuan
    CurrencyModel(symbol: '₩', code: 'KRW', locale: 'ko_KR', hasDecimals: false), // South Korean Won (NO DECIMALS)
    CurrencyModel(symbol: '\$', code: 'AUD', locale: 'en_AU', hasDecimals: true), // Australian Dollar
  ];
}