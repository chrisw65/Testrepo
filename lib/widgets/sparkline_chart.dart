import 'dart:math';

import 'package:flutter/material.dart';

class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.values,
    this.color,
    this.fillColor,
    this.strokeWidth = 3,
  });

  final List<int> values;
  final Color? color;
  final Color? fillColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final List<double> normalized = _normalize(values);
    final Color resolved = color ?? Theme.of(context).colorScheme.primary;
    final Color resolvedFill =
        fillColor ?? resolved.withOpacity(0.25);
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          normalized: normalized,
          strokeColor: resolved,
          fillColor: resolvedFill,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }

  List<double> _normalize(List<int> values) {
    if (values.isEmpty) {
      return const <double>[];
    }
    final int maxValue = values.reduce(max);
    final double safeMax = max(1, maxValue).toDouble();
    return values
        .map((int value) => value / safeMax)
        .toList();
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.normalized,
    required this.strokeColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  final List<double> normalized;
  final Color strokeColor;
  final Color fillColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (normalized.isEmpty) {
      return;
    }
    final Paint strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path linePath = Path();
    final Path fillPath = Path();

    final double dx = size.width / max(1, normalized.length - 1);
    for (int i = 0; i < normalized.length; i++) {
      final double x = dx * i;
      final double y = size.height - (normalized[i] * size.height);
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.normalized != normalized ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
