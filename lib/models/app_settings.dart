class AppSettings {
  AppSettings({this.autoSize = true, this.cols = 4, this.rows = 4});
  bool autoSize;
  int cols;
  int rows;

  AppSettings copyWith({bool? autoSize, int? cols, int? rows}) {
    return AppSettings(
      autoSize: autoSize ?? this.autoSize,
      cols: cols ?? this.cols,
      rows: rows ?? this.rows,
    );
  }
}
