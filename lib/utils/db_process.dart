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
            MaKhachHang INTEGER PRIMARY KEY AUTOINCREMENT,
            CCCD TEXT,
            HoTen TEXT,
            NgaySinh TEXT,
            SoDienThoai TEXT,
            HangGPLX TEXT,
            GhiChu TEXT
          );
          
          CREATE TABLE Xe(
            MaXe INTEGER PRIMARY KEY AUTOINCREMENT,
            BienSoXe TEXT,
            TinhTrang TEXT,
            GiaThue INTEGER,
            HangGPLX TEXT,
            LoaiXe TEXT,
            GiaMua INTEGER,
            NgayMua TEXT,
            SoHanhTrinh INTEGER
          );

          CREATE TABLE DongXe(
            MaDongXe INTEGER PRIMARY KEY AUTOINCREMENT, 
            TenDongXe TEXT
          );

          CREATE TABLE DongXe_Xe(
            MaDongXe INTEGER,
            MaXe INTEGER,
            PRIMARY KEY (MaDongXe, MaXe),

            FOREIGN KEY (MaDongXe) REFERENCES DongXe(MaDongXe) ON DELETE CASCADE,
            FOREIGN KEY (MaXe) REFERENCES Xe(MaXe) ON DELETE CASCADE
          );

          CREATE TABLE HangXe(
            MaHangXe INTEGER PRIMARY KEY AUTOINCREMENT, 
            TenHangXe TEXT
          );

          CREATE TABLE HangXe_Xe(
            MaHangXe INTEGER,
            MaXe INTEGER,
            PRIMARY KEY (MaHangXe, MaXe),

            FOREIGN KEY (MaHangXe) REFERENCES HangXe(MaHangXe) ON DELETE CASCADE,
            FOREIGN KEY (MaXe) REFERENCES Xe(MaXe) ON DELETE CASCADE
          );

          CREATE TABLE BaoHiemXe(
            MaBHX INTEGER PRIMARY KEY AUTOINCREMENT,
            SoBHX TEXT,
            NgayMua TEXT,
            NgayHetHan TEXT,
            SoTien INTEGER
          );

          CREATE TABLE BaoHiemXe_Xe(
            MaBHX INTEGER,
            MaXe INTEGER,
            PRIMARY KEY (MaBHX, MaXe),

            FOREIGN KEY (MaBHX) REFERENCES BaoHiemXe(MaBHX) ON DELETE CASCADE,
            FOREIGN KEY (MaXe) REFERENCES Xe(MaXe) ON DELETE CASCADE
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
            element['CCCD'],
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
          element['CCCD'],
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
          where HoTen like ?
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
      set CCCD = ?, HoTen = ?, NgaySinh = ?, SoDienThoai = ?, 
      HangGPLX = ?, GhiChu = ?
      where MaKhachHang  = ?
      ''',
      [
        updatedKhachHang.cccd,
        updatedKhachHang.hoTen,
        updatedKhachHang.ngaySinh.toVnFormat(),
        updatedKhachHang.soDienThoai,
        updatedKhachHang.hangGPLX,
        updatedKhachHang.ghiChu,
        updatedKhachHang.maKhachHang,
      ],
    );
  }

  Future<void> deleteKhachHang(int maKhachHang) async {
    await _database.rawDelete(
        'delete from KhachHang where MaKhachHang  = ?', [maKhachHang]);
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
        null,
        null,
        element['NgayMua'],
        null,
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
        xe.dongXe = DongXe(
          cur.current['MaDongXe'] as int,
          cur.current['TenDongXe'] as String,
        );
      }

      cur = await _database.rawQueryCursor(
        '''
        select MaHangXe, TenHangXe from HangXe_Xe join HangXe USING(MaHangXe)
        where MaXe = ?
        ''',
        [xe.maXe],
      );

      while (await cur.moveNext()) {
        xe.hangXe = HangXe(
          cur.current['MaHangXe'] as int,
          cur.current['TenHangXe'] as String,
        );
      }
      // BHX
      cur = await _database.rawQueryCursor(
        '''
        select MaBHX from BaoHiemXe_Xe join BaoHiemXe USING(MaBHX)
        where MaXe = ?
        ''',
        [xe.maXe],
      );

      while (await cur.moveNext()) {
        xe.maBHX = cur.current['MaBHX'] as int;
      }

      xes.add(xe);
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
    await _database.insert(
      'DongXe_Xe',
      {
        'MaDongXe': newXeDto.dongXe!.maDongXe,
        'MaXe': returningId,
      },
    );

    // Insert HangXe_Xe
    await _database.insert(
      'HangXe_Xe',
      {
        'MaHangXe': newXeDto.hangXe!.maHangXe,
        'MaXe': returningId,
      },
    );

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
      where MaDauSach = ?
      ''',
      [
        updatedXeDto.bienSoXe,
        updatedXeDto.tinhTrang,
        updatedXeDto.giaThue,
        updatedXeDto.giaMua,
        updatedXeDto.loaiXe,
        updatedXeDto.hangGPLX,
        updatedXeDto.ngayMua,
        updatedXeDto.soHanhTrinh,
        updatedXeDto.maXe,
      ],
    );
    /* Thêm mới các Tác giả */
    await _database.insert(
      'HangXe_Xe',
      {
        'MaHangXe': updatedXeDto.hangXe!.maHangXe,
        'MaXe': updatedXeDto.maXe,
      },
    );
    await _database.insert(
      'DongXe_Xe',
      {
        'MaDongXe': updatedXeDto.dongXe!.maDongXe,
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
