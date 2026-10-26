import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomSnackBar {
  static void showSuccess(BuildContext context, String title) {
    _show(
      context: context,
      title: title,
      icon: LucideIcons.checkCircle2,
      iconColor: const Color(0xFF4CAF50), // Vibrant neon green accent
    );
  }

  static void showError(BuildContext context, String title) {
    _show(
      context: context,
      title: title,
      icon: LucideIcons.alertTriangle,
      iconColor: const Color(0xFFE57373), // Soft modern coral red
    );
  }

  static void _show({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent, 
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        duration: const Duration(seconds: 2), 
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF18181C), 
            borderRadius: BorderRadius.circular(24), // Distinct squircle style preserved
            border: Border.all(
              color: Colors.white.withAlpha(25), 
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.center, // Vertically centers both icon and text
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 15, // Slightly bumped font size to match the thicker profile
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}