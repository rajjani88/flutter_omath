import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Floating Background Animation ---

class FloatingBackground extends StatefulWidget {
  const FloatingBackground({super.key});

  @override
  State<FloatingBackground> createState() => _FloatingBackgroundState();
}

class _FloatingBackgroundState extends State<FloatingBackground>
    with TickerProviderStateMixin {
  final List<FloatingSymbol> symbols = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    // Generate 20 symbols
    for (int i = 0; i < 20; i++) {
      symbols.add(FloatingSymbol(
        char: [
          '+',
          '-',
          '×',
          '÷',
          '=',
          '?',
          '1',
          '2',
          '3',
          'π',
          '%',
          '√'
        ][_rnd.nextInt(12)],
        startLeft: _rnd.nextDouble(),
        startTop: _rnd.nextDouble(),
        speed: 0.5 + _rnd.nextDouble() * 1.5,
        angle: _rnd.nextDouble() * 2 * pi,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: symbols.map((sym) => _buildAnimatedSymbol(sym)).toList(),
    );
  }

  Widget _buildAnimatedSymbol(FloatingSymbol sym) {
    return _FloatingSymbolWidget(symbol: sym);
  }
}

class FloatingSymbol {
  final String char;
  final double startLeft;
  final double startTop;
  final double speed;
  final double angle;

  FloatingSymbol({
    required this.char,
    required this.startLeft,
    required this.startTop,
    required this.speed,
    required this.angle,
  });
}

class _FloatingSymbolWidget extends StatefulWidget {
  final FloatingSymbol symbol;
  const _FloatingSymbolWidget({required this.symbol});

  @override
  State<_FloatingSymbolWidget> createState() => _FloatingSymbolWidgetState();
}

class _FloatingSymbolWidgetState extends State<_FloatingSymbolWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: (10000 + widget.symbol.speed * 5000).toInt()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final offsetY = sin(progress * 2 * pi) * 20;
        final rotation = progress * widget.symbol.angle;

        return Positioned(
          left: widget.symbol.startLeft * size.width,
          top: widget.symbol.startTop * size.height + offsetY,
          child: Transform.rotate(
            angle: rotation,
            child: Opacity(
              opacity: 0.1,
              child: Text(
                widget.symbol.char,
                style: GoogleFonts.quicksand(
                  fontSize: 10 + widget.symbol.speed * 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
