import 'dart:io';

import 'package:rent_bik/models/khach_hang.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DbProcess {
  late Database _database;

  Future<void> connect() async {
    final currentFolder = Directory.current.path;
    _database = await openDatabase(
      '$currentFolder/database/rent_bik.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE KhachHang(
            MaKhachHang TEXT PRIMARY KEY,
            HoTen TEXT,
            NgaySinh TEXT,
            SoDienThoai TEXT,
            HangGPLX TEXT,
            GhiChu TEXT
          );


          ''',
        );
      },
    );
  }

  //
  // CODING PIN HERE
  //

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
    /* Lấy 8 dòng dữ liệu Khách hàng được thêm gần đây */
    List<Map<String, dynamic>> data = await _database.rawQuery(
      '''
      select * from KhachHang 
      limit ?, 8
      ''',
      [numberRowIgnore],
    );

    List<KhachHang> danhSachKhachHang = [];

    for (var element in data) {
      danhSachKhachHang.add(
        KhachHang(
            element['MaKhachHang'],
            element['HoTen'],
            vnDateFormat.parse(element['NgaySinh'] as String),
            element['SoDienThoai'],
            element['HangGPLX'],
            element['GhiChu']),
      );
    }

    return danhSachKhachHang;
  }

  Future<List<KhachHang>> queryKhachHangFullnameWithString({
    required String str,
    required int numberRowIgnore,
  }) async {
    /* Lấy 10 dòng dữ liệu Độc Giả được thêm gần đây */
    List<Map<String, dynamic>> data = await _database.rawQuery(
      '''
      select * from DocGia 
      where HoTen like ? or SoDienThoai like ?
      limit ?, 8
      ''',
      ['%$str%', '%$str%', numberRowIgnore],
    );
    List<KhachHang> danhSachKhachHang = [];

    for (var element in data) {
      danhSachKhachHang.add(
        KhachHang(
          element['MaKhachHang'],
            element['HoTen'],
            vnDateFormat.parse(element['NgaySinh'] as String),
            element['SoDienThoai'],
            element['HangGPLX'],
            element['GhiChu'],
        ),
      );
    }

    return danhSachKhachHang;
  }

  Future<int> queryCountKhachHang() async {
    return firstIntValue(
        await _database.rawQuery('select count(MaKhachHang) from KhachHang'))!;
  }

  Future<int> queryCountKhachHangFullnameWithString(String str) async {
    return firstIntValue(
      await _database.rawQuery(
        '''
          select count(MaKhachHang) from KhachHang 
          where Hoten like ?
          ''',
        ['%${str.toLowerCase()}%'],
      ),
    )!;
  }

  Future<int> insertKhachHang(KhachHang newKhachHang) async {
    return await _database.insert('KhachHang', newKhachHang.toMap());
  }

  Future<void> updateKhachHang(KhachHang updatedKhachHang) async {
    await _database.rawUpdate(
      '''
      update KhachHang 
      set HoTen = ?, NgaySinh = ?, SoDienThoai = ?, 
      HangGPLX = ?, GhiChu = ?
      where MaKhachHang  = ?
      ''',
      [
        updatedKhachHang.hoTen,
        updatedKhachHang.ngaySinh.toVnFormat(),
        updatedKhachHang.soDienThoai,
        updatedKhachHang.hangGPLX,
        updatedKhachHang.ghiChu,
        updatedKhachHang.maKhachHang,
      ],
    );
  }

  Future<void> deleteKhachHang(String maKhachHang) async {
    await _database.rawDelete('delete from KhachHang where MaKhachHang  = ?', [maKhachHang]);
  }

}
