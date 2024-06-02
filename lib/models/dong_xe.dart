class DongXe {
  int? maDongXe;
  String tenDongXe;

  DongXe({this.maDongXe, required this.tenDongXe});

  bool? get isEmpty => null;

  Map<String, dynamic> toMap() {
    return {
      'MaDongXe': maDongXe,
      'TenDongXe': tenDongXe,
    };
  }

  factory DongXe.fromJson(Map<String, dynamic> json) {
    return DongXe(
        maDongXe: int.parse(json['MaDongXe']), tenDongXe: json['TenDongXe']);
  }
}
