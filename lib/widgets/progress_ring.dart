import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 96,
    this.color,
    this.child,
  });

  final double progress;
  final double size;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final double clampedProgress = progress.clamp(0, 1);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            value: clampedProgress,
            strokeWidth: 8,
            backgroundColor: effectiveColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
          child ??
              Text(
                '${(clampedProgress * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: effectiveColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
        ],
      ),
    );
  }
}
