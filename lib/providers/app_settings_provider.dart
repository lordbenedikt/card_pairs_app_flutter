import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/models/app_settings.dart';

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(AppSettings());

  void updateAppSettings(
      {bool? autoSize, bool? turnCount, int? cols, int? rows}) {
    state = AppSettings(
      autoSize: autoSize ?? state.autoSize,
      turnCount: turnCount ?? state.turnCount,
      cols: cols ?? state.cols,
      rows: rows ?? state.rows,
    );
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
