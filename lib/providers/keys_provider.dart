import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class SecretProvider {
  static late final String unsplashAccessKey;
  static late final String unsplashSecretKey;

  static Future<void> init() {
    return rootBundle.loadStructuredData<void>(
      'assets/secrets/secrets.json',
      (jsonStr) async {
        final map = json.decode(jsonStr);
        unsplashAccessKey = map['unsplashAccessKey'];
        unsplashSecretKey = map['unsplashSecretKey'];
      },
    );
  }
}
