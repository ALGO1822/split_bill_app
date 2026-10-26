import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:split_bill_app/cubit/split_bill_cubit.dart';
import 'package:split_bill_app/cubit/split_bill_state.dart';

class CustomKeypad extends StatelessWidget {
  final Function(String)? onKeyPressed;
  final VoidCallback? onHold;
  const CustomKeypad({super.key, this.onKeyPressed, this.onHold});

  @override
  Widget build(BuildContext context) {
    // 1. Wrap with BlocBuilder to listen to the active currency state
    return BlocBuilder<SplitBillCubit, SplitBillState>(
      builder: (context, state) {
        // 2. Dynamically inject the decimal point if the currency supports it
        final String dynamicEmptyKey = state.activeCurrency.hasDecimals
            ? '.'
            : ' ';

        final List<String> keys = [
          '1', '2', '3',
          '4', '5', '6',
          '7', '8', '9',
          dynamicEmptyKey, '0', '<', // Index 9 adapts dynamically
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            double calculatedWidth = constraints.maxWidth / 3;

            double maxHeight = constraints.maxHeight.isInfinite
                ? 400.0
                : constraints.maxHeight;
            double calculatedHeight = maxHeight / 4;

            double idealAspectRatio =
                (calculatedWidth > 0 && calculatedHeight > 0)
                ? (calculatedWidth / calculatedHeight)
                : 1.0;

            return GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: idealAspectRatio,
              ),
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final key = keys[index];
                final isBackspace = key == '<';
                final isEmpty = key == ' ';
                final isDecimal = key == '.'; // 🔥 Identify the decimal key

                return Center(
                  child: isEmpty
                      ? const SizedBox.shrink()
                      : SizedBox(
                          width: calculatedWidth * 0.85,
                          height: calculatedHeight * 0.85,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),

                              // 1. The standard tap for all keys
                              onTap: () {
                                if (state.isHapticEnabled) {
                                  HapticFeedback.lightImpact();
                                }
                                if (onKeyPressed != null) {
                                  onKeyPressed!(key);
                                }
                              },

                              child: Center(
                                child: isBackspace
                                    // 🔥 We are bringing back your original, perfectly-working GestureDetector!
                                    ? GestureDetector(
                                        behavior: HitTestBehavior
                                            .opaque, // Guarantees it catches your finger perfectly
                                        onLongPress: () {
                                          if (state.isHapticEnabled) {
                                            // 🔥 Changed from mediumImpact to vibrate() so your S8 motor definitively triggers
                                            HapticFeedback.vibrate();
                                          }
                                          if (onHold != null) onHold!();
                                        },
                                        child: const Padding(
                                          // Added a tiny bit of padding to make the hold-zone slightly larger for thumbs
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            LucideIcons.chevronLeft,
                                            color: Color(0xFFcdcbe0),
                                            size: 30,
                                          ),
                                        ),
                                      )
                                    : isDecimal
                                    ? const Icon(
                                        LucideIcons.dot,
                                        color: Color(0xFFcdcbe0),
                                        size: 32,
                                      )
                                    : Text(
                                        key,
                                        style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFcdcbe0),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                );
              },
            );
          },
        );
      },
    );
  }
}
