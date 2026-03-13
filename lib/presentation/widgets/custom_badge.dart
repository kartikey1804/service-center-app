import 'package:flutter/material.dart';

enum BadgeType { blue, green, yellow, red, gray, orange }

class CustomBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const CustomBadge({
    Key? key,
    required this.text,
    this.type = BadgeType.gray,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case BadgeType.blue:
        bgColor = Theme.of(context).colorScheme.primary.withOpacity(0.15);
        textColor = Theme.of(context).colorScheme.primary;
        break;
      case BadgeType.green:
        bgColor = const Color(0xFF059669).withOpacity(0.15);
        textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
        break;
      case BadgeType.yellow:
        bgColor = const Color(0xFFD97706).withOpacity(0.15);
        textColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        break;
      case BadgeType.red:
        bgColor = Theme.of(context).colorScheme.error.withOpacity(0.15);
        textColor = Theme.of(context).colorScheme.error;
        break;
      case BadgeType.orange:
        bgColor = Colors.orange.withOpacity(0.15);
        textColor = isDark ? Colors.orangeAccent : Colors.orange;
        break;
      case BadgeType.gray:
      default:
        bgColor = Theme.of(context).cardColor;
        textColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: type == BadgeType.gray ? Border.all(color: Theme.of(context).dividerColor) : null,
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
