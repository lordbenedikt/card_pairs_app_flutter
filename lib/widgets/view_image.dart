import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:memory/widgets/responsive_icon_button.dart';
import 'package:memory/helpers/share.dart';

class ViewImage extends StatelessWidget {
  const ViewImage({this.image, this.url, super.key});

  final Uint8List? image;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [
          image != null ? Image.memory(image!) : Image.network(url!),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: Colors.black.withOpacity(0.6),
              ),
              child: ResponsiveIconButton(
                onPressed: () {
                  if (image != null) {
                    Share.images([image!]);
                  } else {
                    Share.fromUrl([url!]);
                  }
                },
                icon: const Icon(Icons.share, color: Colors.white70),
              ),
            ),
          ),
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
