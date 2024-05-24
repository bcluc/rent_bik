import 'dart:convert';
import 'dart:io';

import 'package:rent_bik/dto/dong_xe_dto.dart';
import 'package:rent_bik/dto/hang_xe_dto.dart';
import 'package:rent_bik/dto/xe_dto.dart';
import 'package:rent_bik/models/dong_xe.dart';
import 'package:rent_bik/models/hang_xe.dart';
import 'package:rent_bik/models/khach_hang.dart';
import 'package:rent_bik/models/xe.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';
import 'package:sqflite/utils/utils.dart';
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

  //TODO: Fix queryKHWithName
  Future<List<KhachHang>> queryKhachHangFullnameWithString({
    required String str,
    required int numberRowIgnore,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    List<Map<String, dynamic>> data = await _database.rawQuery(
      '''
      select * from KhachHang 
      where HoTen like ? or SoDienThoai like ?
      limit ?, 8
      ''',
      ['%$str%', '%$str%', numberRowIgnore],
    );
    List<KhachHang> danhSachKhachHang = [];

    for (var element in data) {
      // danhSachKhachHang.add(
      //   KhachHang(
      //     element['MaKhachHang'],
      //     element['CCCD'],
      //     element['HoTen'],
      //     vnDateFormat.parse(element['NgaySinh'] as String),
      //     element['SoDienThoai'],
      //     element['HangGPLX'],
      //     element['GhiChu'],
      //   ),
      // );
    }

    return danhSachKhachHang;
  }

  //TODO: Count KH
  Future<int> queryCountKhachHang() async {
    return 4;
    // return firstIntValue(
    //     await _database.rawQuery('select count(MaKhachHang) from KhachHang'))!;
  }

  //TODO: Query Count KH
  Future<int> queryCountKhachHangFullnameWithString(String str) async {
    return firstIntValue(
      await _database.rawQuery(
        '''
          select count(MaKhachHang) from KhachHang 
          where HoTen like ?
          ''',
        ['%${str.toLowerCase()}%'],
      ),
    )!;
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
      body: jsonEncode(<String, int>{
        'MaKhachHang': maKhachHang,
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
  // CODING XE HERE
  //

  Future<List<Xe>> queryXe({
    required int numberRowIgnore,
  }) async {
    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    List<Map<String, dynamic>> data = await _database.rawQuery(
      '''
      select * from Xe 
      limit ?, 8
      ''',
      [numberRowIgnore],
    );

    List<Xe> danhSachXe = [];

    for (var element in data) {
      danhSachXe.add(
        Xe(
          element['MaXe'],
          element['BienSoXe'],
          element['TinhTrang'],
          element['GiaThue'],
          element['HangGPLX'],
          element['LoaiXe'],
          element['GiaMua'],
          element['NgayMua'],
          element['SoHanhTrinh'],
        ),
      );
    }

    return danhSachXe;
  }

  Future<List<XeDTO>> queryXeDto() async {
    List<Map<String, dynamic>> data = await _database.rawQuery(
      '''
      select * from Xe 
      ''',
    );

    List<XeDTO> xes = [];

    for (var element in data) {
      final xe = XeDTO(
        element['MaXe'],
        element['BienSoXe'],
        element['TinhTrang'],
        element['GiaThue'],
        element['GiaMua'],
        element['LoaiXe'],
        element['HangGPLX'],
        [],
        [],
        element['NgayMua'],
        element['SoHanhTrinh'],
      );

      QueryCursor cur = await _database.rawQueryCursor(
        '''
        select MaDongXe, TenDongXe from DongXe_Xe join DongXe USING(MaDongXe)
        where MaXe = ?
        ''',
        [xe.maXe],
      );

      while (await cur.moveNext()) {
        xe.dongXes.add(DongXe(
          cur.current['MaDongXe'] as int,
          cur.current['TenDongXe'] as String,
        ));
      }

      cur = await _database.rawQueryCursor(
        '''
        select MaHangXe, TenHangXe from HangXe_Xe join HangXe USING(MaHangXe)
        where MaXe = ?
        ''',
        [xe.maXe],
      );

      while (await cur.moveNext()) {
        xe.hangXes.add(HangXe(
          cur.current['MaHangXe'] as int,
          cur.current['TenHangXe'] as String,
        ));
      }
      xes.add(xe);
    }
    for (XeDTO xe in xes) {
      print(xe.maXe);
      print(xe.bienSoXe);
    }
    return xes;
  }

  Future<int> insertXeDto(XeDTO newXeDto) async {
    // Insert Xe
    int returningId = await _database.insert(
      'Xe',
      {
        'BienSoXe': newXeDto.bienSoXe,
        'TinhTrang': newXeDto.tinhTrang,
        'GiaThue': newXeDto.giaThue,
        'GiaMua': newXeDto.giaMua,
        'LoaiXe': newXeDto.loaiXe,
        'HangGPLX': newXeDto.hangGPLX,
        'NgayMua': newXeDto.ngayMua.toVnFormat(),
        'SoHanhTrinh': newXeDto.soHanhTrinh,
      },
    );

    // Insert DongXe_Xe
    for (var dongXe in newXeDto.dongXes) {
      await _database.insert(
        'DongXe_Xe',
        {
          'MaDongXe': dongXe.maDongXe,
          'MaXe': returningId,
        },
      );
    }

    // Insert HangXe_Xe
    for (var hangXe in newXeDto.hangXes) {
      await _database.insert(
        'HangXe_Xe',
        {
          'MaHangXe': hangXe.maHangXe,
          'MaXe': returningId,
        },
      );
    }

    return returningId;
  }

  Future<void> updateXeDto(XeDTO updatedXeDto) async {
    /* Delete các Dòng xe cũ đang gắn với Xe */
    await _database.rawDelete(
      '''
      delete from DongXe_Xe
      where MaXe = ?
      ''',
      [updatedXeDto.maXe],
    );
    /* Delete các Hãng cũ đang gắn với Xe */
    await _database.rawDelete(
      '''
      delete from HangXe_Xe
      where MaXe = ?
      ''',
      [updatedXeDto.maXe],
    );
    /* Cập nhật Xe */
    await _database.rawUpdate(
      '''
      update Xe
      set BienSoXe = ?,
      TinhTrang = ?,
      GiaThue = ?,
      GiaMua = ?,
      LoaiXe = ?,
      HangGPLX = ?,
      NgayMua = ?,
      SoHanhTrinh = ?
      where MaXe = ?
      ''',
      [
        updatedXeDto.bienSoXe,
        updatedXeDto.tinhTrang,
        updatedXeDto.giaThue,
        updatedXeDto.giaMua,
        updatedXeDto.loaiXe,
        updatedXeDto.hangGPLX,
        updatedXeDto.ngayMua.toVnFormat(),
        updatedXeDto.soHanhTrinh,
        updatedXeDto.maXe,
      ],
    );
    /* Thêm mới các Tác giả */
    await _database.insert(
      'HangXe_Xe',
      {
        'MaHangXe': updatedXeDto.hangXes.last.maHangXe,
        'MaXe': updatedXeDto.maXe,
      },
    );
    await _database.insert(
      'DongXe_Xe',
      {
        'MaDongXe': updatedXeDto.dongXes.last.maDongXe,
        'MaXe': updatedXeDto.maXe,
      },
    );
    /* DONE */
  }

  Future<List<Xe>> queryXeFullnameWithString({
    required String str,
    required int numberRowIgnore,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    List<Map<String, dynamic>> data = await _database.rawQuery(
      '''
      select * from DocGia 
      where MaXe like ? or BienSoXe like ?
      limit ?, 8
      ''',
      ['%$str%', '%$str%', numberRowIgnore],
    );
    List<Xe> danhSachXe = [];

    for (var element in data) {
      danhSachXe.add(
        Xe(
          element['MaXe'],
          element['BienSoXe'],
          element['TinhTrang'],
          element['GiaThue'],
          element['HangGPLX'],
          element['LoaiXe'],
          element['GiaMua'],
          element['NgayMua'],
          element['SoHanhTrinh'],
        ),
      );
    }

    return danhSachXe;
  }

  Future<int> queryCountXe() async {
    return firstIntValue(
        await _database.rawQuery('select count(MaXe) from Xe'))!;
  }

  Future<int> queryCountXeFullnameWithString(String str) async {
    return firstIntValue(
      await _database.rawQuery(
        '''
          select count(MaXe) from Xe 
          where MaXe like ?
          ''',
        ['%${str.toLowerCase()}%'],
      ),
    )!;
  }

  Future<int> insertXe(Xe newXe) async {
    return await _database.insert('Xe', newXe.toMap());
  }

  Future<void> updateXe(Xe updatedXe) async {
    await _database.rawUpdate(
      '''
      update Xe 
      set TinhTrang = ?, GiaThue = ?, 
      HangGPLX = ?
      where MaXe  = ?
      ''',
      [
        updatedXe.tinhTrang,
        updatedXe.giaThue,
        updatedXe.hangGPLX,
        updatedXe.maXe,
      ],
    );
  }

  Future<void> deleteXe(int maXe) async {
    await _database.rawDelete('delete from Xe where MaXe  = ?', [maXe]);
  }

  Future<void> deleteXeWithId(int maXe) async {
    /* 
    Vì ON DELETE CASCADE không hoạt động trong flutter 

    Nhưng khi delete Xe trong DB Brower for SQLite thì ON DELETE CASCADE lại hoạt động, 
    nó tự động xoát các dòng liên quan trong bảng TacGia_DauSach, DauSach_TheLoai )

    => Vậy nên, phải tự delete thủ công trong Flutter 
    */
    /* Delete các Tác giả cũ đang gắn với Đầu sách */
    await _database.rawDelete(
      '''
      delete from DongXe_Xe
      where MaXe = ?
      ''',
      [maXe],
    );
    /* Delete các Thể loại cũ đang gắn với Đầu sách */
    await _database.rawDelete(
      '''
      delete from HangXe_Xe
      where MaXe = ?
      ''',
      [maXe],
    );
    await _database.rawDelete(
      '''
      delete from BaoHiemXe_Xe
      where MaXe = ?
      ''',
      [maXe],
    );
    /* Delete Đầu Sách */
    await _database.rawDelete(
      '''
      delete from Xe
      where MaXe = ?
      ''',
      [maXe],
    );
  }

  //
  // DÒNG XE
  //

  Future<List<DongXe>> queryDongXes() async {
    List<Map<String, dynamic>> data = await _database.rawQuery(
      '''
      select * from DongXe;
      ''',
    );

    List<DongXe> dongXes = [];

    for (var element in data) {
      dongXes.add(
        DongXe(
          element['MaDongXe'],
          element['TenDongXe'],
        ),
      );
    }

    return dongXes;
  }

  Future<List<DongXeDto>> queryDongXeDtos() async {
    List<Map<String, dynamic>> data = await _database.rawQuery(
      '''
      select * from DongXe;
      ''',
    );

    List<DongXeDto> dongXes = [];

    for (var element in data) {
      final dongXe = DongXeDto(
        element['MaDongXe'],
        element['TenDongXe'],
        0,
      );

      List<Map<String, dynamic>> soLuongXeData = await _database.rawQuery(
        '''
        select count(MaXe) as SoLuong
        from DongXe_Xe
        where MaDongXe = ?
        ''',
        [dongXe.maDongXe],
      );

      if (soLuongXeData.isNotEmpty) {
        dongXe.soLuongXe = soLuongXeData[0]['SoLuong'];
      }

      dongXes.add(dongXe);
    }

    return dongXes;
  }

  Future<int> insertDongXe(DongXe newDongXe) async {
    return await _database.insert(
      'DongXe',
      {
        'TenDongXe': newDongXe.tenDongXe,
      },
    );
  }

  Future<void> updateDongXe(int maDongXe, String tenDongXe) async {
    await _database.rawUpdate(
      '''
      update DongXe
      set TenDongXe = ?
      where MaDongXe = ?
      ''',
      [
        tenDongXe,
        maDongXe,
      ],
    );
  }

  Future<void> deleteDongXeWithMaDongXe(int maDongXe) async {
    /* Delete DauSach_TheLoai có liên quan */
    await _database.rawDelete(
      '''
      delete from DongXe_Xe
      where MaDongXe = ?
      ''',
      [maDongXe],
    );

    /* Delete TheLoai */
    await _database.rawDelete(
      '''
      delete from DongXe 
      where MaDongXe = ?
      ''',
      [maDongXe],
    );
  }

  //
  // HÃNG XE
  //

  Future<List<HangXe>> queryHangXes() async {
    List<Map<String, dynamic>> data = await _database.rawQuery(
      '''
      select * from HangXe;
      ''',
    );

    List<HangXe> hangXes = [];

    for (var element in data) {
      hangXes.add(
        HangXe(
          element['MaHangXe'],
          element['TenHangXe'],
        ),
      );
    }

    return hangXes;
  }

  Future<List<HangXeDto>> queryHangXeDtos() async {
    List<Map<String, dynamic>> data = await _database.rawQuery(
      '''
      select * from HangXe;
      ''',
    );

    List<HangXeDto> hangXes = [];

    for (var element in data) {
      final hangXe = HangXeDto(
        element['MaHangXe'],
        element['TenHangXe'],
        0,
      );

      List<Map<String, dynamic>> soLuongXeData = await _database.rawQuery(
        '''
        select count(MaXe) as SoLuong
        from HangXe_Xe
        where MaHangXe = ?
        ''',
        [hangXe.maHangXe],
      );

      if (soLuongXeData.isNotEmpty) {
        hangXe.soLuongXe = soLuongXeData[0]['SoLuong'];
      }

      hangXes.add(hangXe);
    }

    return hangXes;
  }

  Future<int> insertHangXe(HangXe newHangXe) async {
    return await _database.insert(
      'HangXe',
      {
        'TenHangXe': newHangXe.tenHangXe,
      },
    );
  }

  Future<void> updateHangXe(int maHangXe, String tenHangXe) async {
    await _database.rawUpdate(
      '''
      update HangXe
      set TenHangXe = ?
      where MaHangXe = ?
      ''',
      [
        tenHangXe,
        maHangXe,
      ],
    );
  }

  Future<void> deleteHangXeWithMaDongXe(int maHangXe) async {
    /* Delete DauSach_TheLoai có liên quan */
    await _database.rawDelete(
      '''
      delete from HangXe_Xe
      where MaHangXe = ?
      ''',
      [maHangXe],
    );

    /* Delete TheLoai */
    await _database.rawDelete(
      '''
      delete from HangXe 
      where MaHangXe = ?
      ''',
      [maHangXe],
    );
  }
}
