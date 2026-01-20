import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable power-up button with icon, cost label, and tap handler.
class PowerUpButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final int cost;
  final VoidCallback onActivate;
  final Color color;

  const PowerUpButton({
    super.key,
    required this.icon,
    required this.label,
    required this.cost,
    required this.onActivate,
    this.color = GameColors.secondary,
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
    final currencyController = Get.find<CurrencyController>();
    final soundController = Get.find<SoundController>();

    if (currencyController.spendCoins(widget.cost)) {
      // Success - play sound and activate
      soundController.playSuccess();
      widget.onActivate();
    } else {
      // Not enough coins - show dialog
      soundController.playWrong();
      _showNotEnoughCoinsDialog();
    }
  }

  void _showNotEnoughCoinsDialog() {
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: GameColors.panel,
        title: Text(
          "💰 Not Enough Coins!",
          style: GoogleFonts.fredoka(color: Colors.white, fontSize: 22.sp),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You need ${widget.cost} coins for this power-up.",
              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                Get.find<CurrencyController>().watchAdForCoins();
              },
              icon: const Icon(Icons.play_circle_fill),
              label: Text("Watch Ad (+100 🪙)", style: GoogleFonts.nunito()),
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.success,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel",
                style: GoogleFonts.nunito(color: Colors.white60)),
          ),
        ],
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
                  "${widget.cost} 🪙",
                  style: GoogleFonts.fredoka(
                    color: Colors.amber,
                    fontSize: 12.sp,
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
