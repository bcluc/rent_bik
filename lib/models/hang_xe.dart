class HangXe {
  int? maHangXe;
  String tenHangXe;

  HangXe({this.maHangXe, required this.tenHangXe});

  bool? get isEmpty => null;

  Map<String, dynamic> toMap() {
    return {
      'MaHangXe': maHangXe,
      'TenHangXe': tenHangXe,
    };
  }

  factory HangXe.fromJson(Map<String, dynamic> json) {
    return HangXe(
        maHangXe: int.parse(json['MaHangXe']), tenHangXe: json['TenHangXe']);
  }
}
