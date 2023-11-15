import 'package:flutter/material.dart';
import 'package:memory/widgets/responsive_icon_button.dart';

class ViewImage extends StatelessWidget {
  const ViewImage(this.url, {super.key});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [
          Image.network(url),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: Colors.black.withOpacity(0.6),
              ),
              child: ResponsiveIconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
