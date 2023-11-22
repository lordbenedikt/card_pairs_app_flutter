import 'package:memory/models/image/responsive_image.dart';

class FirebaseImage extends ResponsiveImage {
  FirebaseImage({
    required this.urlFull,
    this.urlLarge,
    this.urlMedium,
    this.urlSmall,
  });

  final String urlFull; // full resolution
  String? urlLarge; // min 600px
  String? urlMedium; // min 300px
  String? urlSmall; // min 100px

  @override
  String urlFullSize() {
    return urlFull;
  }

  @override
  String urlWithSize(int width, int height) {
    if (width <= 100 && height <= 100 && urlSmall != null) {
      return urlSmall!;
    }
    if (width <= 300 && height <= 300 && urlMedium != null) {
      return urlMedium!;
    }
    if (width <= 600 && height <= 600 && urlLarge != null) {
      return urlLarge!;
    }
    return urlFull;
  }
}
