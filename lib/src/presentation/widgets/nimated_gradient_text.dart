import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedGradientText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;
  final Duration duration;
  final double glowRadius;

  const AnimatedGradientText({
    super.key,
    required this.text,
    required this.style,
    required this.colors,
    this.duration = const Duration(seconds: 3),
    this.glowRadius = 18,
  });

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(); // Continuous looping
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _measureTextWidth() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final textWidth = _measureTextWidth();
    final fontSize = widget.style.fontSize ?? 40;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;

        // Smooth sine wave for center-to-edge motion
        final offset = math.sin(t * 2 * math.pi) * 0.5 + 0.5;

        // Shift gradient center using shader transform
        final shader = LinearGradient(
          colors: widget.colors,
          begin: Alignment(-1.0 + offset, 0),
          end: Alignment(1.0 + offset, 0),
          tileMode: TileMode.mirror,
        ).createShader(Rect.fromLTWH(0, 0, textWidth, fontSize));

        // Breathing glow using sine
        final dynamicGlow =
            widget.glowRadius * (0.8 + 0.4 * math.sin(t * 2 * math.pi));

        return Text(
          widget.text,
          style: widget.style.copyWith(
            foreground: Paint()..shader = shader,
            shadows: [
              Shadow(
                color: widget.colors.last.withValues(alpha: 0.7),
                blurRadius: dynamicGlow,
              ),
            ],
          ),
        );
      },
    );
  }
}
