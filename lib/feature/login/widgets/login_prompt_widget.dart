import 'package:flutter/material.dart';

class LoginPromptWidget extends StatelessWidget {
  final String comment;
  final String action;
  final VoidCallback? onPressed;

  const LoginPromptWidget({
    super.key,
    required this.comment,
    required this.action,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(comment, style: textTheme.bodyMedium?.copyWith(color: Colors.white)),
        TextButton(
          onPressed: onPressed ?? () {},
          child: Text(action, style: textTheme.bodyMedium?.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
