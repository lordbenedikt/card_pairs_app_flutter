import 'package:flutter/material.dart';
import 'package:memory/asset_path_provider.dart';
import 'package:memory/memory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AssetsPathProvider.init();

  runApp(const MaterialApp(
    home: Memory(),
  ));
}
