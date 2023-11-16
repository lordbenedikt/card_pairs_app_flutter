import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

class Share {
  static images(List<Uint8List> images) {
    final List<XFile> xFiles = [];
    for (final image in images) {
      final now = DateTime.now();
      final dateString =
          '${now.year}${now.month}${now.day}_${now.microsecondsSinceEpoch}';
      xFiles.add(XFile.fromData(image,
          mimeType: 'image/jpeg', name: 'IMG-$dateString'));
    }
    share_plus.Share.shareXFiles(xFiles);
  }

  static fromUrl(List<String> urls) async {
    final List<XFile> xFiles = [];
    for (final url in urls) {
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);
      final now = DateTime.now();
      final dateString =
          '${now.year}${now.month}${now.day}_${now.microsecondsSinceEpoch}';
      xFiles.add(XFile.fromData(bytes,
          mimeType: 'image/jpeg', name: 'IMG-$dateString'));
    }
    share_plus.Share.shareXFiles(xFiles);
  }
}
