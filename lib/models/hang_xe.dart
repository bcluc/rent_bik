class HangXe {
  int? maHangXe;
  String tenHangXe;

  HangXe(this.maHangXe, this.tenHangXe);

  bool? get isEmpty => null;

  Map<String, dynamic> toMap() {
    return {
      'MaHangXe': maHangXe,
      'TenHangXe': tenHangXe,
    };
  }
}
