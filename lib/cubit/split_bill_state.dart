import 'package:intl/intl.dart';
import 'package:split_bill_app/models/currency_model.dart';

class SplitBillState {
  final String inputAmount;
  final int peopleCount;
  final bool isTaxApplied;
  final CurrencyModel activeCurrency;
  
  // 🔥 New Settings Fields
  final double taxPercentage;
  final bool isRoundingEnabled;
  final bool isHapticEnabled;

  const SplitBillState({
    this.inputAmount = '',
    this.peopleCount = 2,
    this.isTaxApplied = false,
    this.activeCurrency = CurrencyModel.nairas,
    this.taxPercentage = 5.0, // Default 5%
    this.isRoundingEnabled = false,
    this.isHapticEnabled = true,
  });

  String get formattedInputAmount {
    if (inputAmount.isEmpty) return "0";
    List<String> parts = inputAmount.split('.');
    String wholePart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    double wholeAmount = double.tryParse(wholePart) ?? 0.0;
    final formatter = NumberFormat('#,##0', activeCurrency.locale);
    String formattedWhole = formatter.format(wholeAmount);

    if (inputAmount.contains('.')) {
      String decimalSeparator = formatter.symbols.DECIMAL_SEP;
      return '$formattedWhole$decimalSeparator$decimalPart';
    }
    return formattedWhole;
  }

  double get baseAmount => double.tryParse(inputAmount) ?? 0.0;

  double get taxAmount {
    if (!isTaxApplied) return 0.0;
    return baseAmount * (taxPercentage / 100); // 🔥 Now reads from settings
  }

  double get grandTotal => baseAmount + taxAmount;

  double get perPersonAmount {
    if (peopleCount <= 0) return 0.0;
    double exactAmount = grandTotal / peopleCount;
    // 🔥 If rounding is enabled, we round UP so the host never loses money
    return isRoundingEnabled ? exactAmount.ceilToDouble() : exactAmount; 
  }

  SplitBillState copyWith({
    String? inputAmount,
    int? peopleCount,
    bool? isTaxApplied,
    CurrencyModel? activeCurrency,
    double? taxPercentage,
    bool? isRoundingEnabled,
    bool? isHapticEnabled,
  }) {
    return SplitBillState(
      inputAmount: inputAmount ?? this.inputAmount,
      peopleCount: peopleCount ?? this.peopleCount,
      isTaxApplied: isTaxApplied ?? this.isTaxApplied,
      activeCurrency: activeCurrency ?? this.activeCurrency,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      isRoundingEnabled: isRoundingEnabled ?? this.isRoundingEnabled,
      isHapticEnabled: isHapticEnabled ?? this.isHapticEnabled,
    );
  }
}