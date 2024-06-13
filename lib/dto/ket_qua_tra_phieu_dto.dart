class KetQuaTraPhieuDTO {
  String status;
  int soTienThue;
  String? ghiChu;
  KetQuaTraPhieuDTO({
    required this.status,
    required this.soTienThue,
    this.ghiChu,
  });

  factory KetQuaTraPhieuDTO.fromJson(Map<String, dynamic> json) {
    return KetQuaTraPhieuDTO(
      status: json['Status'],
      soTienThue: int.parse(json['SoTienThue']),
      ghiChu: json['ghiChu'],
    );
  }
}
