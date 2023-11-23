class AppSettings {
  AppSettings({
    this.autoSize = true,
    this.turnCount = false,
    this.cols = 4,
    this.rows = 4,
  });
  bool autoSize;
  bool turnCount;
  int cols;
  int rows;

  AppSettings copyWith({
    bool? autoSize,
    bool? turnCount,
    int? cols,
    int? rows,
  }) {
    return AppSettings(
      autoSize: autoSize ?? this.autoSize,
      turnCount: turnCount ?? this.turnCount,
      cols: cols ?? this.cols,
      rows: rows ?? this.rows,
    );
  }
}
