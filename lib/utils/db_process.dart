import 'dart:convert';
import 'package:rent_bik/dto/bao_hiem_xe_dto.dart';
import 'package:rent_bik/dto/bao_hiem_xe_new_dto.dart';
import 'package:rent_bik/dto/ket_qua_tra_phieu_dto.dart';
import 'package:rent_bik/dto/khach_hang_dto.dart';
import 'package:rent_bik/dto/phieu_bao_tri_can_tra_dto.dart';
import 'package:rent_bik/dto/phieu_thue_can_tra_dto.dart';
import 'package:rent_bik/dto/phieu_thue_dto.dart';
import 'package:rent_bik/dto/xe_dto.dart';
import 'package:rent_bik/models/bao_hiem_xe.dart';
import 'package:rent_bik/models/dong_xe.dart';
import 'package:rent_bik/models/hang_xe.dart';
import 'package:rent_bik/models/khach_hang.dart';
import 'package:rent_bik/models/phieu_bao_tri.dart';
import 'package:rent_bik/models/phieu_thue.dart';
import 'package:rent_bik/utils/extesion.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:http/http.dart' as http;

class DbProcess {
  late Database _database;
  final String _baseUrl = "http://localhost/RentBikBE";

  Future<void> updateMaPin(String newMaPin) async {
    await _database.rawUpdate(
      '''
      update TaiKhoan
      set password = ?
      where username = 'PIN'
      ''',
      [newMaPin],
    );
  }

  //
  // CODING KHACH HANG HERE
  //

  Future<List<KhachHang>> queryKhachHang({
    required int numberRowIgnore,
  }) async {
    List<KhachHang> danhSachKhachHang = [];

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/get_Customers.php')
        .replace(queryParameters: {'offset': numberRowIgnore.toString()}));
    if (response.statusCode == 200) {
      //print(response.body);

      List<dynamic> jsonData = json.decode(response.body)['customers'];
      danhSachKhachHang =
          jsonData.map((data) => KhachHang.fromJson(data)).toList();
    } else {
      // Handle error if needed
    }
    return danhSachKhachHang;
  }

  Future<List<KhachHang>> queryKhachHangFullnameWithString({
    required String str,
    required int numberRowIgnore,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    List<KhachHang> danhSachKhachHang = [];

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/search_Customer.php')
        .replace(queryParameters: {'search': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      List<dynamic> jsonData = json.decode(response.body)['customers'];
      danhSachKhachHang =
          jsonData.map((data) => KhachHang.fromJson(data)).toList();
    } else {
      // Handle error if needed
    }
    return danhSachKhachHang;
  }

  Future<int> queryCountKhachHang() async {
    String total = '0';
    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/get_Customers.php'));
    if (response.statusCode == 200) {
      //print(response.body);

      total = json.decode(response.body)['total_customers'];
    } else {
      // Handle error if needed
    }
    return int.parse(total);
  }

  Future<int> queryCountKhachHangFullnameWithString(String str) async {
    String total = '0';
    final response = await http.get(Uri.parse('$_baseUrl/search_Customer.php')
        .replace(queryParameters: {'search': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      total = json.decode(response.body)['total_customers'];
    } else {
      // Handle error if needed
    }
    return int.parse(total);
  }

  Future<int> insertKhachHang(KhachHang newKhachHang) async {
    int newMaKH = 0;
    final response = await http.post(
      Uri.parse('$_baseUrl/add_Customer.php'),
      body: jsonEncode(<String, String?>{
        "CCCD": newKhachHang.cccd,
        "HoTen": newKhachHang.hoTen,
        "NgaySinh": newKhachHang.ngaySinh.toVnFormat(),
        "SoDienThoai": newKhachHang.soDienThoai,
        "HangGPLX": newKhachHang.hangGPLX,
        "GhiChu": newKhachHang.ghiChu
      }),
    );
    if (response.statusCode == 200) {
      newMaKH = json.decode(response.body)['MaKH'];
    } else {
      // Handle error if needed
    }
    return newMaKH;
  }

  Future<void> updateKhachHang(KhachHang updatedKhachHang) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/update_Customer.php'),
      body: jsonEncode(<String, String?>{
        "MaKhachHang": updatedKhachHang.maKhachHang.toString(),
        "CCCD": updatedKhachHang.cccd,
        "HoTen": updatedKhachHang.hoTen,
        "NgaySinh": updatedKhachHang.ngaySinh.toVnFormat(),
        "SoDienThoai": updatedKhachHang.soDienThoai,
        "HangGPLX": updatedKhachHang.hangGPLX,
        "GhiChu": updatedKhachHang.ghiChu
      }),
    );
    if (response.statusCode == 200) {
      // Success
    } else {
      // Handle error if needed
    }
    return;
  }

  Future<void> deleteKhachHang(int maKhachHang) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/delete_Customer.php'),
      body: jsonEncode(<String, String>{
        'MaKhachHang': maKhachHang.toString(),
      }),
    );
    if (response.statusCode == 200) {
      //print(response.body);
    } else {
      // Handle error if needed
    }
    return;
  }

  Future<KhachHangDTO> getKHWithString({
    required String str,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    late KhachHangDTO xeGet;

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/search_Customer.php')
        .replace(queryParameters: {'CCCD': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      xeGet = KhachHangDTO.fromJson(json.decode(response.body)['customer']);
    } else {
      // Handle error if needed
    }
    return xeGet;
  }

  Future<String> getStatusKHWithCCCD(
    String str,
  ) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    String? bhxGet = "error";

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/search_Customer.php')
        .replace(queryParameters: {'CCCD': str}));

    if (response.statusCode == 200) {
      //print(response.body);
      bhxGet = (json.decode(response.body)['status']);
      if (bhxGet == null) return "error";
    }
    return bhxGet;
  }

  //
  // CODING XE HERE
  //

  Future<List<XeDTO>> queryXe({required int numberRowIgnore}) async {
    List<XeDTO> danhSachXe = [];

    final response = await http.get(Uri.parse('$_baseUrl/get_Xes.php')
        .replace(queryParameters: {'offset': numberRowIgnore.toString()}));
    if (response.statusCode == 200) {
      //print(response.body);

      final jsonData = json.decode(response.body);
      final List<dynamic> xeList = jsonData['Xes'];

      danhSachXe = xeList.map((json) => XeDTO.fromJson(json)).toList();
    } else {
      // Handle error if needed
    }
    return danhSachXe;
  }

  Future<List<XeDTO>> queryXeDto() async {
    List<XeDTO> danhSachXe = [];

    final response = await http.get(Uri.parse('$_baseUrl/get_Xes.php'));
    if (response.statusCode == 200) {
      //print(response.body);

      List<dynamic> jsonData = json.decode(response.body)['Xes'];
      danhSachXe = jsonData.map((data) => XeDTO.fromJson(data)).toList();
    } else {
      // Handle error if needed
    }
    return danhSachXe;
  }

  // Future<int> insertXeDto(XeDTO newXeDto) async {
  //   // Insert Xe
  //   int returningId = await createXe(newXeDto);

  //   bool isBHX = await initBHX(returningId, newXeDto.soBHX);

  //   if (isBHX) {
  //     return returningId;
  //   } else {
  //     return 0;
  //   }
  // }

  Future<int> createXe(XeDTO newXeDto) async {
    // Insert Xe
    int returningId = 0;
    final response = await http.post(
      Uri.parse('$_baseUrl/create_Xe.php'),
      body: jsonEncode(<String, dynamic>{
        "BienSoXe": newXeDto.bienSoXe,
        "TinhTrang": newXeDto.tinhTrang,
        "GiaThue": newXeDto.giaThue,
        "HangGPLX": newXeDto.hangGPLX,
        "LoaiXe": newXeDto.loaiXe,
        "GiaMua": newXeDto.giaMua,
        "NgayMua": newXeDto.ngayMua.toVnFormat(),
        "MaDongXe": newXeDto.dongXes.last.maDongXe,
        "MaHangXe": newXeDto.hangXes.last.maHangXe,
        "SoHanhTrinh": newXeDto.soHanhTrinh,
      }),
    );
    if (response.statusCode == 200) {
      returningId = json.decode(response.body)['MaXe'];
    } else {
      // Handle error if needed
    }
    return returningId;
  }

  Future<void> updateXeDto(XeDTO updatedXeDto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/update_Xe.php'),
      body: jsonEncode(<String, dynamic>{
        "MaXe": updatedXeDto.maXe,
        "BienSoXe": updatedXeDto.bienSoXe,
        "TinhTrang": updatedXeDto.tinhTrang,
        "GiaThue": updatedXeDto.giaThue,
        "HangGPLX": updatedXeDto.hangGPLX,
        "LoaiXe": updatedXeDto.loaiXe,
        "GiaMua": updatedXeDto.giaMua,
        "NgayMua": updatedXeDto.ngayMua.toVnFormat(),
        "MaDongXe": updatedXeDto.dongXes.last.maDongXe,
        "MaHangXe": updatedXeDto.hangXes.last.maHangXe,
        "SoHanhTrinh": updatedXeDto.soHanhTrinh,
      }),
    );
    if (response.statusCode == 200) {
      // Success
    } else {
      // Handle error if needed
    }
    return;
  }

  Future<List<XeDTO>> queryXeFullnameWithString({
    required String str,
    required int numberRowIgnore,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    List<XeDTO> danhSachXe = [];

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/search_Xe.php')
        .replace(queryParameters: {'BienSoXe': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      List<dynamic> jsonData = json.decode(response.body)['data'];
      danhSachXe = jsonData.map((data) => XeDTO.fromJson(data)).toList();
    } else {
      // Handle error if needed
    }
    return danhSachXe;
  }

  Future<XeDTO> getXeWithString({
    required String str,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    late XeDTO xeGet;

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.post(
      Uri.parse('$_baseUrl/search_in_BaoTri.php'),
      body: jsonEncode(<String, String>{
        "BienSoXe": str,
      }),
    );
    if (response.statusCode == 200) {
      //print(response.body);
      xeGet = XeDTO.fromJson(json.decode(response.body)['Xe']);
    } else {
      // Handle error if needed
    }
    return xeGet;
  }

  Future<String?> getStatusXeWithBSX(
    String str,
  ) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    String? bhxGet = "error";

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.post(
      Uri.parse('$_baseUrl/search_in_BaoTri.php'),
      body: jsonEncode(<String, String>{
        "BienSoXe": str,
      }),
    );
    if (response.statusCode == 200) {
      //print(response.body);
      bhxGet = (json.decode(response.body)['status']);
    }
    return bhxGet;
  }

  Future<int> queryCountXe() async {
    String total = '0';

    final response = await http.get(Uri.parse('$_baseUrl/get_Xes.php'));
    if (response.statusCode == 200) {
      //print(response.body);

      total = json.decode(response.body)['total_xe'];
    } else {
      // Handle error if needed
    }
    return int.parse(total);
  }

  Future<int> queryCountXeFullnameWithString(String str) async {
    String total = '0';
    final response = await http.get(Uri.parse('$_baseUrl/search_Xe.php')
        .replace(queryParameters: {'BienSoXe': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      total = json.decode(response.body)['total_xe'];
    } else {
      // Handle error if needed
    }
    return int.parse(total);
  }

  Future<void> deleteXeWithId(int maXe) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/delete_Xe.php'),
      body: jsonEncode(<String, String>{
        'MaXe': maXe.toString(),
      }),
    );
    if (response.statusCode == 200) {
      //print(response.body);
    } else {
      // Handle error if needed
    }
    return;
  }

  //
  // BẢO HIỂM
  //

  // Future<bool> initBHX(int maXe, String? soBHX) async {
  //   bool returning = false;
  //   final response = await http.post(
  //     Uri.parse('$_baseUrl/add_BaoHiem.php'),
  //     body: jsonEncode(<String, dynamic>{
  //       "MaXe": maXe,
  //       "SoBHX": soBHX,
  //       "NgayMua": "",
  //       "NgayHetHan": "",
  //       "SoTien": "0"
  //     }),
  //   );
  //   if (response.statusCode == 200) {
  //     returning = (json.decode(response.body)['status'] == 'success');
  //   } else {
  //     // Handle error if needed
  //   }
  //   return returning;
  // }

  //
  // DÒNG XE
  //

  Future<List<DongXe>> queryDongXes() async {
    List<DongXe> dongXes = [];

    final response = await http.get(Uri.parse('$_baseUrl/get_DongXe.php'));
    if (response.statusCode == 200) {
      //print(response.body);

      List<dynamic> jsonData = json.decode(response.body);
      dongXes = jsonData.map((data) => DongXe.fromJson(data)).toList();
    } else {
      // Handle error if needed
    }

    return dongXes;
  }

  Future<int> insertDongXe(DongXe newDongXe) async {
    int newMaDx = 0;
    final response = await http.post(
      Uri.parse('$_baseUrl/add_DongXe.php'),
      body: jsonEncode(<String, String?>{
        "TenDongXe": newDongXe.tenDongXe,
      }),
    );
    if (response.statusCode == 200) {
      newMaDx = json.decode(response.body)['MaDongXe'];
    } else {
      // Handle error if needed
    }
    return newMaDx;
  }

  Future<void> updateDongXe(int maDongXe, String tenDongXe) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/update_DongXe.php'),
      body: jsonEncode(<String, dynamic>{
        "MaDongXe": maDongXe,
        "TenDongXe": tenDongXe,
      }),
    );
    if (response.statusCode == 200) {
      //Success
    } else {
      // Handle error if needed
    }
  }

  Future<void> deleteDongXeWithMaDongXe(int maDongXe) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/delete_DongXe.php'),
      body: jsonEncode(<String, String>{
        'MaDongXe': maDongXe.toString(),
      }),
    );
    if (response.statusCode == 200) {
      //print(response.body);
    } else {
      // Handle error if needed
    }
    return;
  }

  //
  // HÃNG XE
  //

  Future<List<HangXe>> queryHangXes() async {
    List<HangXe> hangXes = [];

    final response = await http.get(Uri.parse('$_baseUrl/get_HangXe.php'));
    if (response.statusCode == 200) {
      //print(response.body);

      List<dynamic> jsonData = json.decode(response.body);
      hangXes = jsonData.map((data) => HangXe.fromJson(data)).toList();
    } else {
      // Handle error if needed
    }
    return hangXes;
  }

  Future<int> insertHangXe(HangXe newHangXe) async {
    int newMaDx = 0;
    final response = await http.post(
      Uri.parse('$_baseUrl/add_HangXe.php'),
      body: jsonEncode(<String, String?>{
        "TenHangXe": newHangXe.tenHangXe,
      }),
    );
    if (response.statusCode == 200) {
      newMaDx = json.decode(response.body)['MaHangXe'];
    } else {
      // Handle error if needed
    }
    return newMaDx;
  }

  Future<void> updateHangXe(int maHangXe, String tenHangXe) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/update_HangXe.php'),
      body: jsonEncode(<String, dynamic>{
        "MaHangXe": maHangXe,
        "TenHangXe": tenHangXe,
      }),
    );
    if (response.statusCode == 200) {
      //Success
    } else {
      // Handle error if needed
    }
  }

  Future<void> deleteHangXeWithMaHangXe(int maHangXe) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/delete_HangXe.php'),
      body: jsonEncode(<String, String>{
        'MaHangXe': maHangXe.toString(),
      }),
    );
    if (response.statusCode == 200) {
      //print(response.body);
    } else {
      // Handle error if needed
    }
    return;
  }

  //
  //
  // CODING BHX
  //
  //

  Future<List<BaoHiemXe>> queryBaoHiemXe({
    required int numberRowIgnore,
  }) async {
    List<BaoHiemXe> danhSachBHX = [];

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/get_BaoHiem.php')
        .replace(queryParameters: {'offset': numberRowIgnore.toString()}));
    if (response.statusCode == 200) {
      //print(response.body);

      List<dynamic> jsonData = json.decode(response.body)['BaoHiemXe'];
      danhSachBHX = jsonData.map((data) => BaoHiemXe.fromJson(data)).toList();
    } else {
      // Handle error if needed
    }
    return danhSachBHX;
  }

  Future<BaoHiemXeDTO> queryBaoHiemXeFullnameWithBSX({
    required String str,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    late BaoHiemXeDTO bhxGet;

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.post(
      Uri.parse('$_baseUrl/get_BaoHiem.php'),
      body: jsonEncode(<String, String>{
        "BienSoXe": str,
      }),
    );
    if (response.statusCode == 200) {
      //print(response.body);
      bhxGet = BaoHiemXeDTO.fromJson(json.decode(response.body)['data']);
    }
    return bhxGet;
  }

  Future<BaoHiemXeNewDTO> queryNewBaoHiemXeSubmitedWithBSX({
    required String str,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    late BaoHiemXeNewDTO bhxGet;

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.post(
      Uri.parse('$_baseUrl/get_BaoHiem.php'),
      body: jsonEncode(<String, String>{
        "BienSoXe": str,
      }),
    );
    if (response.statusCode == 200) {
      //print(response.body);
      bhxGet = BaoHiemXeNewDTO.fromJson(json.decode(response.body)['data']);
    }
    return bhxGet;
  }

  Future<String?> queryStatusBHXWithBSX(
    String str,
  ) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    String? bhxGet = "error";

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.post(
      Uri.parse('$_baseUrl/get_BaoHiem.php'),
      body: jsonEncode(<String, String>{
        "BienSoXe": str,
      }),
    );
    if (response.statusCode == 200) {
      //print(response.body);
      bhxGet = (json.decode(response.body)['status']);
    }
    return bhxGet;
  }

  Future<int> queryCountBaoHiemXe() async {
    String total = '0';
    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/get_BaoHiem.php'));
    if (response.statusCode == 200) {
      //print(response.body);

      total = json.decode(response.body)['total_BaoHiemXe'];
    } else {
      // Handle error if needed
    }
    return int.parse(total);
  }

  Future<int> insertBaoHiemXe(BaoHiemXe newBHX, int maXe) async {
    int newMaBHX = -1;
    final response = await http.post(
      Uri.parse('$_baseUrl/add_BaoHiem.php'),
      body: jsonEncode(<String, Object>{
        "MaXe": maXe,
        "SoBHX": newBHX.soBHX,
        "NgayMua": newBHX.ngayMua.toVnFormat(),
        "NgayHetHan": newBHX.ngayHetHan.toVnFormat(),
        "SoTien": newBHX.soTien.toString(),
      }),
    );
    if (response.statusCode == 200) {
      newMaBHX = json.decode(response.body)['MaBHX'];
    } else {
      // Handle error if needed
    }
    return newMaBHX;
  }

  Future<void> updateBaoHiemXe(BaoHiemXe updatedKhachHang) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/update_BaoHiem.php'),
      body: jsonEncode(<String, Object?>{
        "MaBHX": updatedKhachHang.maBHX,
        "SoBHX": updatedKhachHang.soBHX,
        "NgayMua": updatedKhachHang.ngayMua.toVnFormat(),
        "NgayHetHan": updatedKhachHang.ngayHetHan.toVnFormat(),
        "SoTien": updatedKhachHang.soTien.toString(),
      }),
    );
    if (response.statusCode == 200) {
      // Success
    } else {
      // Handle error if needed
    }
    return;
  }

  Future<void> deleteBaoHiemXe(int maBHX) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/delete_BaoHiem.php'),
      body: jsonEncode(<String, String>{
        'MaBHX': maBHX.toString(),
      }),
    );
    if (response.statusCode == 200) {
      //print(response.body);
    } else {
      // Handle error if needed
    }
    return;
  }

//
//
//
// CODING PHIEU BAO TRI
//
//
//

  Future<List<PhieuBaoTri>> queryPhieuBaoTri({
    required int numberRowIgnore,
  }) async {
    List<PhieuBaoTri> danhSachPhieuBaoTri = [];

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/get_PhieuBaoTri.php')
        .replace(queryParameters: {'offset': numberRowIgnore.toString()}));
    if (response.statusCode == 200) {
      //print(response.body);

      List<dynamic> jsonData = json.decode(response.body)['PhieuBaoTri'];
      danhSachPhieuBaoTri =
          jsonData.map((data) => PhieuBaoTri.fromJson(data)).toList();
    } else {
      // Handle error if needed
    }
    return danhSachPhieuBaoTri;
  }

  Future<List<PhieuBaoTri>> queryPhieuBaoTriFullnameWithString({
    required String str,
    required int numberRowIgnore,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    List<PhieuBaoTri> danhSachPhieuBaoTri = [];

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(
        Uri.parse('$_baseUrl/search_PhieuBaoTri.php')
            .replace(queryParameters: {'BienSoXe': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      List<dynamic> jsonData = json.decode(response.body)['PhieuBaoTri'];
      danhSachPhieuBaoTri =
          jsonData.map((data) => PhieuBaoTri.fromJson(data)).toList();
    } else {
      // Handle error if needed
    }
    return danhSachPhieuBaoTri;
  }

  Future<List<PhieuBaoTriCanTraDTO>> queryPhieuBaoTriChuaTTWithString({
    required String str,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    List<PhieuBaoTriCanTraDTO> danhSachPhieuBaoTri = [];

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/get_PhieuBaoTri.php')
        .replace(queryParameters: {'BienSoXe': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      List<dynamic> jsonData = json.decode(response.body)['PhieuBaoTri'];
      danhSachPhieuBaoTri =
          jsonData.map((data) => PhieuBaoTriCanTraDTO.fromJson(data)).toList();
    } else {
      // Handle error if needed
    }
    return danhSachPhieuBaoTri;
  }

  Future<int> countPhieuBaoTriChuaTTWithString({
    required String str,
  }) async {
    String total = '0';
    final response = await http.get(Uri.parse('$_baseUrl/get_PhieuBaoTri.php')
        .replace(queryParameters: {'BienSoXe': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      total = json.decode(response.body)['total_pages'];
    } else {
      // Handle error if needed
    }
    return int.parse(total);
  }

  Future<int> queryCountPhieuBaoTri() async {
    String total = '0';
    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/get_PhieuBaoTri.php'));
    if (response.statusCode == 200) {
      //print(response.body);

      total = json.decode(response.body)['total_pages'];
    } else {
      // Handle error if needed
    }
    return int.parse(total);
  }

  Future<int> queryCountPhieuBaoTriFullnameWithString(String str) async {
    String total = '0';
    final response = await http.get(
        Uri.parse('$_baseUrl/search_PhieuBaoTri.php')
            .replace(queryParameters: {'BienSoXe': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      total = json.decode(response.body)['total_PhieuBaoTri'];
    } else {
      // Handle error if needed
    }
    return int.parse(total);
  }

  Future<int> insertPhieuBaoTri(String bienSoXe, String ngayBaoTri) async {
    int newPBT = -1;
    final response = await http.post(
      Uri.parse('$_baseUrl/add_PhieuBaoTri.php'),
      body: jsonEncode(
          <String, String>{"BienSoXe": bienSoXe, "NgayBaoTri": ngayBaoTri}),
    );
    if (response.statusCode == 200) {
      String status = json.decode(response.body)['status'];
      if (status == "success") {
        newPBT = json.decode(response.body)['MaPhieuBaoTri'];
      } else {
        return -2;
      }
    } else {
      // Handle error if needed
      return -2;
    }
    return newPBT;
  }

  Future<void> updatePhieuBaoTri(PhieuBaoTri updatedPhieuBaoTri) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/update_PhieuBaoTri.php'),
      body: jsonEncode(<String, Object>{
        "MaPhieuBaoTri": updatedPhieuBaoTri.maPhieuBaoTri!,
        "NgayBaoTri": updatedPhieuBaoTri.ngayBaoTri.toVnFormat(),
      }),
    );
    if (response.statusCode == 200) {
      // Success
    } else {
      // Handle error if needed
    }
    return;
  }

  Future<void> thanhToanPhieuBaoTri(
      int maPhieuBaoTri, String ngayThanhToan, int total) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/add_ThanhToanBaoTri.php'),
      body: jsonEncode(<String, Object>{
        "MaPhieuBaoTri": maPhieuBaoTri,
        "NgayThanhToan": ngayThanhToan,
        "TongHoaDon": total.toString(),
      }),
    );
    if (response.statusCode == 200) {
      // Success
    } else {
      // Handle error if needed
    }
    return;
  }

  Future<void> deletePhieuBaoTri(int maKhachHang) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/delete_PhieuBaoTri.php'),
      body: jsonEncode(<String, int>{
        'MaPhieuBaoTri': maKhachHang,
      }),
    );
    if (response.statusCode == 200) {
      //print(response.body);
    } else {
      // Handle error if needed
    }
    return;
  }

  //
  //
  // PHIEU THUE
  //
  //

  Future<PhieuThue> queryPhieuThueWithString({
    required String str,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    late PhieuThue phieuThue;

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/get_PhieuThue.php')
        .replace(queryParameters: {'CCCD': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      phieuThue = PhieuThue.fromJson(json.decode(response.body)['PhieuThue']);
    } else {
      // Handle error if needed
    }
    return phieuThue;
  }

  Future<int> countPhieuThueWithString({
    required String str,
  }) async {
    String total = '0';
    final response = await http.get(Uri.parse('$_baseUrl/get_PhieuThue.php')
        .replace(queryParameters: {'CCCD': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      total = json.decode(response.body)['total_pages'];
    } else {
      // Handle error if needed
    }
    return int.parse(total);
  }

  Future<int> insertPhieuThue(PhieuThueDTO newPhieuThue) async {
    int newMaPT = 0;
    final response = await http.post(
      Uri.parse('$_baseUrl/add_PhieuThue.php'),
      body: jsonEncode(<String, String?>{
        "MaXe": newPhieuThue.maXe.toString(),
        "MaKH": newPhieuThue.maKH.toString(),
        "NgayThue": newPhieuThue.ngayThue.toVnFormat(),
        "NgayTra": newPhieuThue.ngayTra.toVnFormat(),
        "GiaCoc": newPhieuThue.giaCoc.toString()
      }),
    );
    if (response.statusCode == 200) {
      newMaPT = int.parse(json.decode(response.body)['MaPhieuThue']);
    } else {
      // Handle error if needed
    }
    return newMaPT;
  }

  Future<KetQuaTraPhieuDTO?> kiemTraTienPhieuThue(
      int maPhieuThue, String ngayTra, int? phiPhat, String? note) async {
    late KetQuaTraPhieuDTO newMaPT;
    final response = await http.post(
      Uri.parse('$_baseUrl/add_PhieuTra.php'),
      body: jsonEncode(<String, Object?>{
        "MaPhieuThue": maPhieuThue,
        "NgayTra": ngayTra,
        // Có thể thêm note, phí phạt nếu trường hợp xe phụ thu các phí khác như xe hỏng, mất phụ kiên,vv trừ trường hợp quá ngày sẽ tự động tính
        "PhiPhat": phiPhat.toString(),
        "Note": note
      }),
    );
    if (response.statusCode == 200) {
      newMaPT =
          KetQuaTraPhieuDTO.fromJson(json.decode(response.body)['MaPhieuTra']);
    } else {
      // Handle error if needed
    }
    return newMaPT;
  }

  Future<List<PhieuThueCanTraDTO>> queryPhieuThueChuaTTWithString({
    required String str,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    List<PhieuThueCanTraDTO> danhSachPhieuBaoTri = [];

    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/get_PhieuThue.php')
        .replace(queryParameters: {'CCCD': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      List<dynamic> jsonData = json.decode(response.body)['PhieuThues'];
      danhSachPhieuBaoTri =
          jsonData.map((data) => PhieuThueCanTraDTO.fromJson(data)).toList();
    } else {
      // Handle error if needed
    }
    return danhSachPhieuBaoTri;
  }

  Future<String> queryHoTenPTWithString({
    required String str,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    String hoTen = '';
    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    final response = await http.get(Uri.parse('$_baseUrl/get_PhieuThue.php')
        .replace(queryParameters: {'CCCD': str}));
    if (response.statusCode == 200) {
      //print(response.body);
      hoTen = json.decode(response.body)['HoTen'];
    } else {
      // Handle error if needed
    }
    return hoTen;
  }
}
