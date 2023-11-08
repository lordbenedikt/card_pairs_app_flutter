import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/models/app_settings.dart';
import 'package:memory/models/card_set.dart';

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(AppSettings());

  void updateAppSettings({bool? autoSize, int? cols, int? rows}) {
    state = AppSettings(
      autoSize: autoSize ?? state.autoSize,
      cols: cols ?? state.cols,
      rows: rows ?? state.rows,
    );
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
