import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_bill_app/cubit/split_bill_cubit.dart';
import 'package:split_bill_app/models/currency_model.dart'; // Adjust path if needed

class CurrencySelectorSheet extends StatelessWidget {
  final CurrencyModel selectedCurrency;
  final ValueChanged<CurrencyModel> onCurrencySelected;

  const CurrencySelectorSheet({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  static void show(
    BuildContext context, {
    required CurrencyModel current,
    required ValueChanged<CurrencyModel> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // 🔥 Crucial: Allows the sheet to expand and become scrollable
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFF141418),
      barrierColor: Colors.black.withAlpha(150),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => CurrencySelectorSheet(
        selectedCurrency: current,
        onCurrencySelected: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Grab screen height to constrain the sheet so it doesn't cover the whole screen
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Container(
        // 🔥 Cap the maximum height of the sheet to 75% of the screen
        height: screenHeight * 0.70,
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Currency',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 🔥 Expanded + ListView.builder handles massive lists effortlessly with smooth scrolling
            Expanded(
              child: ListView.builder(
                physics:
                    const BouncingScrollPhysics(), // Premium iOS-style scroll bounce
                itemCount: CurrencyModel.presets.length,
                itemBuilder: (context, index) {
                  final currency = CurrencyModel.presets[index];
                  final bool isSelected =
                      currency.code == selectedCurrency.code;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      onTap: () {
                        // Instant Tap-to-Dismiss optimization
                        if (context
                            .read<SplitBillCubit>()
                            .state
                            .isHapticEnabled) {
                          HapticFeedback.lightImpact(); // 🔥 Confirms user choice row tap
                        }
                        Navigator.pop(context);
                        onCurrencySelected(currency);
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tileColor: isSelected
                          ? Colors.white.withAlpha(15)
                          : Colors.transparent,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFcdcbe0)
                              : Colors.white.withAlpha(10),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            currency.symbol,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        currency.code,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFFcdcbe0),
                              size: 22,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
