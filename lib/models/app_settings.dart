class AppSettings {
  AppSettings(
      {this.autoSize = true,
      this.turnCount = true,
      this.turnCounter = 0,
      this.cols = 4,
      this.rows = 4});
  bool autoSize;
  bool turnCount;
  int turnCounter;
  int cols;
  int rows;

  AppSettings copyWith(
      {bool? autoSize,
      bool? turnCount,
      int? turnCounter,
      int? cols,
      int? rows}) {
    return AppSettings(
      autoSize: autoSize ?? this.autoSize,
      turnCount: turnCount ?? this.turnCount,
      turnCounter: turnCounter ?? this.turnCounter,
      cols: cols ?? this.cols,
      rows: rows ?? this.rows,
    );
  }
}
