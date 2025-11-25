import 'dart:ui';
import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final VoidCallback? onArrowFly; // New callback
  final bool isArrowFlying;
  final List<Color>? gradientColors;
  final Color? textColor;
  final TextStyle? textStyle;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.onArrowFly,
    this.isArrowFlying = false,
    this.gradientColors,
    this.textColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = gradientColors ?? [Color(0xFFFFA726), Color(0xFFFF7043)];
    final txtColor = textColor ?? Colors.white;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(32),
                  onTap: () {
                    if (onArrowFly != null) {
                      onArrowFly!();
                    } else {
                      onPressed();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        text,
                        style:
                            textStyle ??
                            TextStyle(
                              color: txtColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.1,
                              decoration: TextDecoration.none,
                            ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 26,
                        height: 26,
                        child: !isArrowFlying
                            ? Icon(
                                Icons.arrow_forward_rounded,
                                color: txtColor,
                                size: 26,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
