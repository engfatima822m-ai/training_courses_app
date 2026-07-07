import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AppBackButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: 22,
      onPressed: onTap ?? () => Navigator.maybePop(context),
      icon: const Icon(
        Icons.arrow_back_rounded,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}