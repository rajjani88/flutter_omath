import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/reward_choice_dialog.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable power-up button with icon, cost label, and tap handler.
class PowerUpButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final int cost;
  final VoidCallback onActivate;
  final Color color;
  final String description;

  const PowerUpButton({
    super.key,
    required this.icon,
    required this.label,
    required this.cost,
    required this.onActivate,
    this.color = GameColors.secondary,
    this.description = "How would you like to pay?",
  });

  @override
  State<PowerUpButton> createState() => _PowerUpButtonState();
}

class _PowerUpButtonState extends State<PowerUpButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    Get.dialog(
      RewardChoiceDialog(
        title: widget.label,
        icon: widget.icon,
        coinCost: widget.cost,
        description: widget.description,
        onConfirm: () {
          Get.find<SoundController>().playSuccess();
          widget.onActivate();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animController.reverse();
        _handleTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _isPressed ? widget.color.withOpacity(0.8) : widget.color,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: Offset(0, _isPressed ? 2.h : 4.h),
                blurRadius: 6.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 28.sp),
              SizedBox(height: 4.h),
              Text(
                widget.label,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  widget.cost > 0 ? "${widget.cost} 🪙" : "Watch ▶️",
                  style: GoogleFonts.fredoka(
                    color: Colors.amber,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
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
