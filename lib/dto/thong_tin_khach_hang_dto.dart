import 'dart:convert';

class TTKhachHangDTO {
  String hoTen;
  String sdt;
  TTKhachHangDTO({
    required this.hoTen,
    required this.sdt,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'hoTen': hoTen});
    result.addAll({'sdt': sdt});

    return result;
  }

  factory TTKhachHangDTO.fromMap(Map<String, dynamic> map) {
    return TTKhachHangDTO(
      hoTen: map['hoTen'] ?? '',
      sdt: map['sdt'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TTKhachHangDTO.fromJson(String source) =>
      TTKhachHangDTO.fromMap(json.decode(source));
}
