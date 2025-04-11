import 'package:flutter/cupertino.dart';

class CustomTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final EdgeInsetsGeometry? padding;

  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      borderRadius: BorderRadius.circular(8.0),
      color: CupertinoDynamicColor.resolve(
        CupertinoColors.secondarySystemFill,
        context,
      ),
      pressedOpacity: 0.6,
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.secondaryLabel,
            context,
          ),
        ),
      ),
    );
  }
}