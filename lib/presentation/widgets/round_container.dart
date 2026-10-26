import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_bill_app/cubit/split_bill_cubit.dart';

class RoundContainer extends StatelessWidget {
  final IconData icon;
  final bool isCounter;
  final int counterValue;
  final int width;
  final int height;
  final double? size;
  final Color iconColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onHold;

  const RoundContainer({
    super.key,
    required this.icon,
    this.isCounter = false,
    this.counterValue = 0,
    this.width = 50,
    this.height = 50,
    this.onTap,
    this.size,
    this.iconColor = Colors.white,
    this.borderRadius = 15,
    this.onHold,
  });

  @override
  Widget build(BuildContext context) {
    // 1. If it's a counter, return a simple non-clickable Container
    if (isCounter) {
      return Container(
        width: width.toDouble(),
        height: height.toDouble(),
        decoration: BoxDecoration(
          color: const Color(0xFFcdcbe0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            counterValue.toString(),
            style: GoogleFonts.poppins(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    // 2. Otherwise, return the TextButton for the icon action
    final isHapticEnabled = context.read<SplitBillCubit>().state.isHapticEnabled;
    return SizedBox(
      width: width.toDouble(),
      height: height.toDouble(),
      child: GestureDetector(
        onLongPress: () {
          if (isHapticEnabled) {
            HapticFeedback.vibrate(); // Distinct hold registration buzz
          }
          if (onHold != null) onHold!();
        },
        child: TextButton(
          onPressed: () {
            if (isHapticEnabled) {
              HapticFeedback.lightImpact(); // Standard touch tick
            }
            if (onTap != null) onTap!();
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF44444e),
            foregroundColor: Colors.white.withAlpha(
              100,
            ), // This changes the splash/ripple color!
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: EdgeInsets.zero, // Centers the icon perfectly
          ),
          child: Icon(icon, color: iconColor, size: size,),
        ),
      ),
    );
  }
}

