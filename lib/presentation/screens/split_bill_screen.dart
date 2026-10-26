import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:split_bill_app/cubit/split_bill_cubit.dart';
import 'package:split_bill_app/cubit/split_bill_state.dart';
import 'package:split_bill_app/presentation/screens/receipt_screen.dart';
import 'package:split_bill_app/presentation/screens/settings_screen.dart';
import 'package:split_bill_app/presentation/widgets/circular_conatiner.dart';
import 'package:split_bill_app/presentation/widgets/currency_logo_container.dart';
import 'package:split_bill_app/presentation/widgets/currency_selector_sheet.dart';
import 'package:split_bill_app/presentation/widgets/custom_keypad.dart';
import 'package:split_bill_app/presentation/widgets/custom_navigator.dart';
import 'package:split_bill_app/presentation/widgets/round_container.dart';

class SplitBillScreen extends StatelessWidget {
  const SplitBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SplitBillCubit>();

    // 1. Grab device environment constraints once per layout render path
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final statusBarHeight = mediaQuery.padding.top;

    // 2. Proportional scale vectors prevent crowding out on hardware action navigation rails
    final double headerVisualHeight =
        screenHeight * 0.36; // Allocates precisely 36% to header card
    final double stackHitTestHeight =
        headerVisualHeight +
        20; // Adds precise overlapping click target boundary space

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom:
            true, // Explicitly safeguards keypad layout over native device navigation bars
        child: BlocBuilder<SplitBillCubit, SplitBillState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // ================= RESPONSIVE LAVENDER HEADER STACK =================
                SizedBox(
                  height: stackHitTestHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: headerVisualHeight,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFcdcbe0),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Context-aware dynamic space shifts title down exactly past notch layers
                            SizedBox(height: statusBarHeight + 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Split Bill',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\nCalculator',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          height: 1,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 30),
                                Row(
                                  children: [
                                    CircularContainer(
                                      onTap: () {
                                        if (state.isHapticEnabled) {
                                          HapticFeedback.lightImpact();
                                        }
                                        CustomNavigator.pushUp(
                                          context,
                                          const SettingsScreen(),
                                        );
                                      },
                                      child: FaIcon(
                                        FontAwesomeIcons.ellipsis,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    CircularContainer(
                                      onTap: () {
                                        if (state.isHapticEnabled) {
                                          HapticFeedback.lightImpact();
                                        }
                                        CustomNavigator.pushUp(
                                          context,
                                          const ReceiptScreen(),
                                        );
                                      },
                                      child: const FaIcon(
                                        FontAwesomeIcons.receipt,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Flexible spacer blocks dynamically distribute internal layout metrics
                            const Spacer(),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  if (state.isHapticEnabled) {
                                    HapticFeedback.lightImpact(); // 🔥 Tactical buzz on sheet invocation
                                  }
                                  CurrencySelectorSheet.show(
                                    context,
                                    current: state.activeCurrency,
                                    onSelect: (selected) =>
                                        cubit.updateCurrency(selected),
                                  );
                                },
                                child: CurrencyLogoContainer(
                                  icon: Text(
                                    state
                                        .activeCurrency
                                        .symbol, // 🔥 Dynamic Symbol
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                  currency: state
                                      .activeCurrency
                                      .code, // 🔥 Dynamic Code
                                ),
                              ),
                            ),
                            const Spacer(),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 70,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: state.activeCurrency.symbol,
                                          style: GoogleFonts.poppins(
                                            fontSize: 55,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 4,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: state.formattedInputAmount,
                                          style: GoogleFonts.poppins(
                                            fontSize: 55,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -1.5,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ), // Protects baseline tracking bounds before tax chip
                          ],
                        ),
                      ),

                      // Intersecting Tax Badge (100% responsive and clickable over native display layers)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                // 🔥 Inject responsive haptic check
                                if (state.isHapticEnabled) {
                                  HapticFeedback.lightImpact();
                                }
                                cubit.toggleTax();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: state.isTaxApplied
                                      ? Colors.green
                                      : Colors.grey[700],
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 4,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.coins,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "+${state.taxPercentage.toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= LOWER CONTROL SECTIONS =================
                const Spacer(
                  flex: 1,
                ), // Gives structural flexibility below the header stack
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: RoundContainer(
                          icon: LucideIcons.plus,
                          onTap: () => cubit.incrementPeople(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: RoundContainer(
                          height: 60,
                          icon: LucideIcons.user,
                          isCounter: true,
                          counterValue: state.peopleCount,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: RoundContainer(
                          icon: LucideIcons.minus,
                          onTap: () => cubit.decrementPeople(),
                          onHold: () => cubit.resetPeople(),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex:
                      14, // Grid calculations compress/expand neatly based on media query remainders
                  child: Container(
                    alignment: Alignment.center,
                    child: CustomKeypad(
                      onKeyPressed: (key) => cubit.updateInput(key),
                      onHold: () => cubit.resetInput(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
