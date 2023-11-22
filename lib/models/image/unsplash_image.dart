import 'package:memory/models/image/responsive_image.dart';
import 'package:memory/providers/keys_provider.dart';
import 'package:http/http.dart' as http;

class UnsplashImage extends ResponsiveImage {
  UnsplashImage({
    required this.rawUrl,
    required this.fullUrl,
    required this.triggerDownloadUrl,
  });

  final String rawUrl;
  final String fullUrl;
  final String triggerDownloadUrl;

  String urlFullSize() {
    return fullUrl;
  }

  String urlWithSize(int width, int height) {
    return '$rawUrl&w=$width&h=$height';
  }

  void triggerDownload() async {
    final String apiKey = SecretProvider.unsplashAccessKey;
    await http.get(Uri.parse(triggerDownloadUrl), headers: {
      'Authorization': 'Client-ID $apiKey',
    });
  }
}
