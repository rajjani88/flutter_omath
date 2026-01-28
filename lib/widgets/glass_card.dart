import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? borderRadius;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? 16.r;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.r, sigmaY: 10.r),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(r),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05)
                    ],
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
