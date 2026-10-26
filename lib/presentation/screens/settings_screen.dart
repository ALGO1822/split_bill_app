import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:split_bill_app/cubit/split_bill_cubit.dart';
import 'package:split_bill_app/cubit/split_bill_state.dart';
import 'package:split_bill_app/presentation/widgets/circular_conatiner.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showCustomTaxDialog(BuildContext context, SplitBillCubit cubit) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF18181C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Custom Tax %',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'e.g., 7.5',
              hintStyle: GoogleFonts.poppins(color: Colors.white30),
              filled: true,
              fillColor: Colors.white.withAlpha(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null && value >= 0) {
                  cubit.setTaxPercentage(value);
                }
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFcdcbe0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SplitBillCubit>();
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: statusBarHeight + 10,
              ),
              child: Row(
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
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Settings',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= SETTINGS LIST =================
            Expanded(
              child: BlocBuilder<SplitBillCubit, SplitBillState>(
                builder: (context, state) {
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // --- TAX SECTION ---
                      Text(
                        'DEFAULT TAX / FEE',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildTaxChip(5.0, state.taxPercentage, cubit),
                          _buildTaxChip(10.0, state.taxPercentage, cubit),
                          _buildTaxChip(15.0, state.taxPercentage, cubit),
                          _buildTaxChip(20.0, state.taxPercentage, cubit),
                          _buildCustomTaxChip(
                            context,
                            state.taxPercentage,
                            cubit,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // --- PREFERENCES SECTION ---
                      Text(
                        'PREFERENCES',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildSwitchTile(
                        title: 'Round Up Splits',
                        subtitle:
                            'Rounds the per-person amount up to the nearest whole number to avoid losing cents.',
                        icon: LucideIcons.arrowUpCircle,
                        value: state.isRoundingEnabled,
                        onChanged: (val) => cubit.toggleRounding(),
                      ),
                      _buildSwitchTile(
                        title: 'Haptic Feedback',
                        subtitle:
                            'Provide subtle vibration feedback when tapping the keypad.',
                        icon: LucideIcons.vibrate,
                        value: state.isHapticEnabled,
                        onChanged: (val) => cubit.toggleHaptic(),
                      ),

                      const SizedBox(height: 40),

                      // --- ABOUT SECTION ---
                      Text(
                        'ABOUT',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181C),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withAlpha(20)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFcdcbe0),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                LucideIcons.code2,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Designed & Built by Axl',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '@axl1822',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFcdcbe0),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxChip(
    double value,
    double currentValue,
    SplitBillCubit cubit,
  ) {
    bool isSelected = value == currentValue;
    return GestureDetector(
      onTap: () => cubit.setTaxPercentage(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFcdcbe0)
              : Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${value.toStringAsFixed(1)}%',
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTaxChip(
    BuildContext context,
    double currentValue,
    SplitBillCubit cubit,
  ) {
    // Determine if the current tax is NOT one of our presets
    bool isCustomActive = ![5.0, 10.0, 15.0, 20.0].contains(currentValue);

    return GestureDetector(
      onTap: () => _showCustomTaxDialog(context, cubit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCustomActive
              ? const Color(0xFFcdcbe0)
              : Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(20),
          border: isCustomActive
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.pencil,
              color: isCustomActive ? Colors.black : Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isCustomActive ? '${currentValue.toStringAsFixed(1)}%' : 'Custom',
              style: GoogleFonts.poppins(
                color: isCustomActive ? Colors.black : Colors.white,
                fontWeight: isCustomActive
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF18181C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.black,
        activeTrackColor: const Color(0xFFcdcbe0),
        inactiveTrackColor: Colors.white.withAlpha(10),
        inactiveThumbColor: Colors.grey,
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
