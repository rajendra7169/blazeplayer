import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Reusable social sign-in button widget
class SocialSignInButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const SocialSignInButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          foregroundColor: backgroundColor != null
              ? Colors.white
              : AppTheme.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: backgroundColor ?? AppTheme.textLight.withAlpha(76),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon.endsWith('.svg'))
              // For SVG icons (you'll need flutter_svg package)
              Icon(
                Icons.login,
                size: 24,
              ) // Placeholder - replace with actual SVG
            else
              Image.asset(icon, height: 24, width: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: backgroundColor != null
                    ? Colors.white
                    : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
