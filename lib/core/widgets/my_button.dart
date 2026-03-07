import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key, 
    required this.onPressed, 
    required this.text, 
    this.color, 
    this.isLoading,
  });

  // on pressed callback
  final VoidCallback? onPressed;
  final String text;
  final Color? color;
  final bool? isLoading;

  @override
  Widget build(BuildContext context) {
    final isLoading = this.isLoading ?? false;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.amber,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          disabledBackgroundColor: (color ?? Colors.amber).withOpacity(0.5),
        ), 
        onPressed: isLoading ? null : onPressed, 
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              )
            : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
      ),
    );
  }
}

// Icon Button with customizable style
class MyIconButton extends StatelessWidget {
  const MyIconButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.padding,
    this.borderRadius,
    this.elevation,
  });

  final VoidCallback? onPressed;
  final String text;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.blue,
          foregroundColor: foregroundColor ?? Colors.white,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
          elevation: elevation ?? 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Outlined Button with icon
class MyOutlinedButton extends StatelessWidget {
  const MyOutlinedButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
    this.borderColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
  });

  final VoidCallback? onPressed;
  final String text;
  final IconData icon;
  final Color? borderColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? Colors.blue,
          side: BorderSide(
            color: borderColor ?? Colors.blue,
            width: 1.5,
          ),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}