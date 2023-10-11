import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssetsPathProvider {
  static List<String> imagePaths = [];
  static List<String> allAssetPaths = [];

  static Future<void> init() async {
    final assetManifest = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(assetManifest);

    allAssetPaths = manifest.keys.toList();
    imagePaths = allAssetPaths
        .where((path) => path.startsWith('assets/images'))
        .toList();
  }
}
