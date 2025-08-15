import 'package:flutter/material.dart';

class FFButtonOptions {
  final double width;
  final double height;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  const FFButtonOptions({
    required this.width,
    required this.height,
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
  });
}

class FFButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final FFButtonOptions options;

  const FFButtonWidget({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: options.width,
      height: options.height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: options.color,
          foregroundColor: options.textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(options.borderRadius),
            side: BorderSide(
              color: options.borderColor,
              width: options.borderWidth,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
