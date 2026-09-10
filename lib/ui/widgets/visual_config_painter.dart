import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Draws the "visual configuration" diagram showing the relative positions
/// of the Sun (S), Mercury (M) and Venus (V) along a horizontal elongation
/// axis. West elongations (morning sky) hang to the left, East elongations
/// (evening sky) to the right.
///
/// The painter itself is pure drawing: an enclosing widget is responsible
/// for exposing the diagram to assistive technologies via [Semantics].
class VisualConfigPainter extends CustomPainter {
  final double mercuryElongation;
  final double venusElongation;
  final Color sunColor;
  final Color mercuryColor;
  final Color venusColor;
  final Color axisColor;
  final Color labelColor;

  const VisualConfigPainter({
    required this.mercuryElongation,
    required this.venusElongation,
    required this.sunColor,
    required this.mercuryColor,
    required this.venusColor,
    required this.axisColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Sun
    canvas.drawCircle(center, 15, Paint()..color = sunColor);
    _drawLabel(
      canvas,
      center,
      'S',
      Colors.black.withValues(alpha: 1),
      fontSize: 12,
    );

    const double maxRange = 60.0;
    final double scale = size.width / (2 * maxRange);

    // Mercury
    final mercuryX = center.dx + mercuryElongation * scale;
    final mercuryPos = Offset(mercuryX, center.dy);
    canvas.drawCircle(mercuryPos, 5, Paint()..color = mercuryColor);
    _drawLabel(
      canvas,
      mercuryPos.translate(0, -18),
      'M',
      labelColor,
      fontSize: 12,
    );

    // Venus
    final venusX = center.dx + venusElongation * scale;
    final venusPos = Offset(venusX, center.dy);
    canvas.drawCircle(venusPos, 8, Paint()..color = venusColor);
    _drawLabel(
      canvas,
      venusPos.translate(0, 18),
      'V',
      labelColor,
      fontSize: 12,
    );

    // Elongation axis
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      Paint()
        ..color = axisColor
        ..strokeWidth = 1,
    );
  }

  void _drawLabel(
    Canvas canvas,
    Offset pos,
    String text,
    Color color, {
    required double fontSize,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      pos.translate(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant VisualConfigPainter oldDelegate) {
    return oldDelegate.mercuryElongation != mercuryElongation ||
        oldDelegate.venusElongation != venusElongation ||
        oldDelegate.sunColor != sunColor ||
        oldDelegate.mercuryColor != mercuryColor ||
        oldDelegate.venusColor != venusColor ||
        oldDelegate.axisColor != axisColor ||
        oldDelegate.labelColor != labelColor;
  }
}