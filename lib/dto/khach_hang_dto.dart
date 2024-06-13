import 'dart:convert';

class KhachHangDTO {
  String hoTen;
  String hangGPLX;
  int maKH;
  KhachHangDTO({
    required this.hoTen,
    required this.hangGPLX,
    required this.maKH,
  });

  factory KhachHangDTO.fromJson(Map<String, dynamic> map) {
    return KhachHangDTO(
      hoTen: map['HoTen'],
      hangGPLX: map['HangGPLX'],
      maKH: int.parse(map['MaKH']),
    );
  }
}
