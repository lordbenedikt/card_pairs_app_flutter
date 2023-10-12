import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class CompressedImageProvider {
  static List<String> imagePaths = [];
  static List<String> allAssetPaths = [];
  static Map<String, Uint8List> compressedImages = {};

  static Future<Uint8List> getCompressedAssetImage(String assetName) async {
    var list = await FlutterImageCompress.compressAssetImage(
      assetName,
      minHeight: 200,
      minWidth: 200,
      quality: 96,
      rotate: 180,
    );
    assert(list != null, "Failed to compress image: $assetName");
    return list!;
  }

  static Future<void> init() async {
    final assetManifest = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(assetManifest);

    allAssetPaths = manifest.keys.toList();
    imagePaths = allAssetPaths
        .where((path) => path.startsWith('assets/images'))
        .toList();

    for (var path in imagePaths) {
      compressedImages[path] = await getCompressedAssetImage(path);
    }
  }
}
