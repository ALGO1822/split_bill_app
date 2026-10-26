import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:split_bill_app/cubit/split_bill_state.dart';
import 'package:split_bill_app/cubit/split_bill_cubit.dart';
import 'package:split_bill_app/models/currency_model.dart';
import 'package:split_bill_app/presentation/widgets/circular_conatiner.dart';
import 'package:split_bill_app/presentation/widgets/custom_snackbar.dart';
import 'package:split_bill_app/presentation/widgets/round_container.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  Future<void> _captureAndSaveBill(
    SplitBillState state,
    String wholeAmount,
    String decimalPart,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );

      final ScreenshotController hiddenController = ScreenshotController();
      final Uint8List imageBytes = await hiddenController.captureFromWidget(
        BuildScreenShot(
          state: state,
          wholeAmount: wholeAmount,
          decimalPart: decimalPart,
        ),
      );

      if (mounted) Navigator.pop(context);
      await Gal.putImageBytes(imageBytes);

      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Screenshot Saved');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        CustomSnackBar.showError(context, 'Save Failed');
      }
    }
  }

  Future<void> _shareBill(
    SplitBillState state,
    String wholeAmount,
    String decimalPart,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: const SizedBox.shrink(),
        ),
      );

      final ScreenshotController hiddenController = ScreenshotController();
      final Uint8List imageBytes = await hiddenController.captureFromWidget(
        BuildScreenShot(
          state: state,
          wholeAmount: wholeAmount,
          decimalPart: decimalPart,
        ),
      );

      final box = context.findRenderObject() as RenderBox?;
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/split_bill_receipt.png';
      final File imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      final params = ShareParams(
        text: 'Here is our split bill breakdown!',
        files: [XFile(imagePath)],
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );

      final ShareResult result = await SharePlus.instance.share(params);

      if (mounted) Navigator.pop(context);
      if (mounted) {
        if (result.status == ShareResultStatus.success) {
          CustomSnackBar.showSuccess(context, 'Receipt Shared');
        } else if (result.status == ShareResultStatus.dismissed) {
          CustomSnackBar.showError(context, 'Sharing Cancelled');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        CustomSnackBar.showError(context, 'Failed to share');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final statusBarHeight = mediaQuery.padding.top;

    final double topSpacing = statusBarHeight + 10;
    final double displaySectionGap = screenHeight * 0.035;
    final double breakdownCardGap = screenHeight * 0.025;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: true,
        child: BlocBuilder<SplitBillCubit, SplitBillState>(
          builder: (context, state) {
            final String pattern = state.activeCurrency.hasDecimals
                ? '#,##0.00'
                : '#,##0';
            final formatter = NumberFormat(
              pattern,
              state.activeCurrency.locale,
            );

            String perPersonFormatted = formatter.format(state.perPersonAmount);
            String decSep = formatter.symbols.DECIMAL_SEP;

            List<String> parts = perPersonFormatted.split(decSep);
            String wholeAmount = parts[0];

            String decimalPart = '';
            if (state.activeCurrency.hasDecimals) {
              decimalPart = parts.length > 1
                  ? '$decSep${parts[1]}'
                  : '${decSep}00';
            }

            if (state.isRoundingEnabled) {
              decimalPart = '';
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // ================= NAVIGATION HEADER BAR =================
                Padding(
                  padding: EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: topSpacing,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircularContainer(
                        backgroundColor: Colors.grey.withAlpha(30),
                        onTap: () {
                          if (context
                              .read<SplitBillCubit>()
                              .state
                              .isHapticEnabled) {
                            HapticFeedback.lightImpact();
                          }
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          LucideIcons.x,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      Text(
                        'Bill Details',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 48.0),
                    ],
                  ),
                ),

                // ========================================================================
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      children: [
                        SizedBox(height: displaySectionGap),
                        Text(
                          'each person pays'.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 5),

                        SizedBox(
                          width: double.infinity,
                          height: 75,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: state.activeCurrency.symbol,
                                    style: GoogleFonts.poppins(
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 4,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: wholeAmount,
                                    style: GoogleFonts.poppins(
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -1.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: decimalPart,
                                    style: GoogleFonts.poppins(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -1.5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(70),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.users2,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Split between ${state.peopleCount} people',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: displaySectionGap),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Breakdown',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: breakdownCardGap),

                        BillBreakdownBuilder(
                          baseAmount: state.baseAmount,
                          extraAmountFee: state.taxAmount,
                          grandTotal: state.grandTotal,
                          // 🔥 Dynamically injects the custom tax rate from settings
                          taxPercentage: state.isTaxApplied
                              ? state.taxPercentage
                              : 0.0,
                          activeCurrency: state.activeCurrency,
                        ),

                        SizedBox(height: displaySectionGap),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: RoundContainer(
                                icon: LucideIcons.share,
                                size: 25,
                                height: 60,
                                borderRadius: 16,
                                iconColor: Colors.white60,
                                onTap: () =>
                                    _shareBill(state, wholeAmount, decimalPart),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RoundContainer(
                                size: 25,
                                height: 60,
                                borderRadius: 16,
                                iconColor: Colors.white60,
                                icon: LucideIcons.camera,
                                onTap: () => _captureAndSaveBill(
                                  state,
                                  wholeAmount,
                                  decimalPart,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                      ],
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

class BillBreakdownBuilder extends StatelessWidget {
  final double baseAmount;
  final double extraAmountFee;
  final double taxPercentage;
  final double grandTotal;
  final CurrencyModel activeCurrency;

  const BillBreakdownBuilder({
    super.key,
    required this.baseAmount,
    required this.extraAmountFee,
    required this.grandTotal,
    required this.taxPercentage,
    required this.activeCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(70),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Base Amount',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF9E9E9E),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 15),
                Flexible(child: _buildCurrencyText(baseAmount)),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: Colors.white10, height: 1),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extra Fee',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF9E9E9E),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // 🔥 Will now seamlessly display customized tax outputs like 7.5%
                      '${taxPercentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF4CAF50),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                Flexible(child: _buildCurrencyText(extraAmountFee)),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Divider(color: Colors.white10, height: 1),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grand Total',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: _buildCurrencyText(grandTotal, isGrandTotal: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyText(double amount, {bool isGrandTotal = false}) {
    final String pattern = activeCurrency.hasDecimals ? '#,##0.00' : '#,##0';
    String formattedAmount = NumberFormat(
      pattern,
      activeCurrency.locale,
    ).format(amount);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: activeCurrency.symbol,
              style: GoogleFonts.poppins(
                color: isGrandTotal ? Colors.white : const Color(0xFFE0E0E0),
                fontSize: isGrandTotal ? 22 : 16,
                fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            TextSpan(
              text: formattedAmount,
              style: GoogleFonts.poppins(
                color: isGrandTotal ? Colors.white : const Color(0xFFE0E0E0),
                fontSize: isGrandTotal ? 24 : 16,
                fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuildScreenShot extends StatelessWidget {
  final SplitBillState state;
  final String wholeAmount;
  final String decimalPart;

  const BuildScreenShot({
    super.key,
    required this.state,
    required this.wholeAmount,
    required this.decimalPart,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Container(
        width: 375,
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Split Bill',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: '\nCalculator',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        color: const Color(0xFFcdcbe0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),

            Text(
              'each person pays'.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: state.activeCurrency.symbol,
                    style: GoogleFonts.poppins(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: wholeAmount,
                    style: GoogleFonts.poppins(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: decimalPart,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Split between ${state.peopleCount} people',
              style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 35),

            BillBreakdownBuilder(
              baseAmount: state.baseAmount,
              extraAmountFee: state.taxAmount,
              grandTotal: state.grandTotal,
              // 🔥 Ensures off-screen rendering pipeline accurately maps the custom state settings as well
              taxPercentage: state.isTaxApplied ? state.taxPercentage : 0.0,
              activeCurrency: state.activeCurrency,
            ),
          ],
        ),
      ),
    );
  }
}
