class DongXe {
  int? maDongXe;
  String tenDongXe;

  DongXe(this.maDongXe, this.tenDongXe);

  bool? get isEmpty => null;

  Map<String, dynamic> toMap() {
    return {
      'MaDongXe': maDongXe,
      'TenDongXe': tenDongXe,
    };
  }
}
