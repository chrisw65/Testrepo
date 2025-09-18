import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.trailing,
    this.leading,
    this.child,
  });

  final String title;
  final String subtitle;
  final Gradient gradient;
  final Widget? trailing;
  final Widget? leading;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: gradient.colors.last.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (leading != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: leading!,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (child != null) ...<Widget>[
            const SizedBox(height: 16),
            child!,
          ],
        ],
      ),
    );
  }
}
