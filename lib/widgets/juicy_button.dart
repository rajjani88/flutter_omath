import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JuicyButton extends StatefulWidget {
  final Color color;
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final bool disabled;
  final double? height;
  final double? borderRadius;

  const JuicyButton({
    super.key,
    required this.color,
    this.icon,
    required this.label,
    this.onTap,
    this.disabled = false,
    this.height,
    this.borderRadius,
  });

  @override
  State<JuicyButton> createState() => _JuicyButtonState();
}

class _JuicyButtonState extends State<JuicyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.height ?? 70.h;
    final r = widget.borderRadius ?? 24.r;

    if (widget.disabled) {
      return Container(
        height: h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blueGrey[700],
          borderRadius: BorderRadius.circular(r),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          ),
        ),
        alignment: Alignment.center,
        child: _buildContent(isDisabled: true),
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: h,
        width: double.infinity,
        transform: Matrix4.translationValues(0, _isPressed ? 6.h : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(r),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(0, 6.h),
                    blurRadius: 0, // Solid shadow
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent({bool isDisabled = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
        ],
        Text(
          widget.label.toUpperCase(),
          style: GoogleFonts.nunito(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: isDisabled ? Colors.white38 : Colors.white,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2.r,
                offset: Offset(0, 1.h),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
