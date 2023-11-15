import 'package:flutter/material.dart';

class ResponsiveIconButton extends StatelessWidget {
  const ResponsiveIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  final void Function() onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.6),
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: Theme(
        data: ThemeData(hoverColor: Colors.white12),
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
        ),
      ),
    );
  }
}
