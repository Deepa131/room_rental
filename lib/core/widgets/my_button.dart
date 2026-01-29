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