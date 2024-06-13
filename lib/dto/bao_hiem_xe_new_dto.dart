// ignore_for_file: public_member_api_docs, sort_constructors_first
class BaoHiemXeNewDTO {
  String bienSoXe;
  int maXe;
  BaoHiemXeNewDTO({
    required this.bienSoXe,
    required this.maXe,
  });

  factory BaoHiemXeNewDTO.fromJson(Map<String, dynamic> json) {
    return BaoHiemXeNewDTO(
      bienSoXe: json['BienSoXe'],
      maXe: int.parse(json['MaXe']),
    );
  }
}
