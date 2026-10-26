import 'package:flutter/material.dart';

class CircularContainer extends StatelessWidget {
  final Widget child; 
  final double radius;
  final Color backgroundColor;
  final VoidCallback? onTap; // 🔥 We added this!

  const CircularContainer({
    super.key,
    required this.child,
    this.radius = 30.0, 
    this.backgroundColor = const Color(0xFFd7d8ec), 
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 Material + InkWell replaces CircleAvatar to unlock system haptics & ripples
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: Center(child: child),
        ),
      ),
    );
  }
}