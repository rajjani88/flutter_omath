import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GameButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final Color shadowColor;
  final double width;
  final double height;
  final double fontSize;
  final IconData? icon;
  final Color? textColor;

  const GameButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color = GameColors.secondary,
    this.shadowColor = GameColors.secondaryShadow,
    this.width = double.infinity,
    this.height = 60,
    this.fontSize = 20,
    this.icon,
    this.textColor,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final SoundController soundController = Get.find<SoundController>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    soundController.playClick();
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        soundController.playClick();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.shadowColor,
                    offset: const Offset(0, 6),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon,
                        color: widget.textColor ?? Colors.white, size: 28),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    widget.text,
                    style: GoogleFonts.fredoka(
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.bold,
                      color: widget.textColor ?? Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
