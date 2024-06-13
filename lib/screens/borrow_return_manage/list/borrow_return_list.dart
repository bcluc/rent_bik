import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/dto/phieu_thue_can_tra_dto.dart';
import 'package:rent_bik/dto/thong_tin_khach_hang_dto.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/phieu_tra.dart';
import 'package:rent_bik/screens/borrow_return_manage/list/borrow_list.dart';
import 'package:rent_bik/screens/borrow_return_manage/list/return_list.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class QuanLyMuonTra extends StatefulWidget {
  const QuanLyMuonTra({super.key});

  @override
  State<QuanLyMuonTra> createState() => _QuanLyMuonTraState();
}

class _QuanLyMuonTraState extends State<QuanLyMuonTra> {
  final _searchMaDocGiaController = TextEditingController();
  String _errorText = '';
  String _soDienThoai = '';
  String _hoTenDocGia = '';

  bool _isProcessingMaDocGia = false;

  List<PhieuThueCanTraDTO> _phieuThues = [];
  List<PhieuTra> _phieuTras = [];

  Future<void> _searchMaDocGia() async {
    _errorText = '';
    if (_searchMaDocGiaController.text.isEmpty) {
      _errorText = 'Bạn chưa nhập Căn cước công dân.';
    }

    if (_errorText.isNotEmpty) {
      setState(() {});
      return;
    }

    setState(() {
      _isProcessingMaDocGia = true;
    });

    _hoTenDocGia = '';
    _soDienThoai = '';
    _phieuThues.clear();
    _phieuTras.clear();

    TTKhachHangDTO? khachHang =
        await dbProcess.queryTTKHWithCccd(str: _searchMaDocGiaController.text);
    await Future.delayed(const Duration(milliseconds: 200));

    if (khachHang == null) {
      _errorText = 'Không tìm thấy khách hàng.';
    } else {
      /* 
      Không dùng _maDocGia = _searchMaDocGiaController.text vì
      có khả năng _searchMaDocGiaController.text đã thay đổi không còn giống với giá trị của maDocGiaInteger
      */
      _hoTenDocGia = khachHang.hoTen.capitalizeFirstLetterOfEachWord();
      _soDienThoai = khachHang.sdt;
      _phieuThues = await dbProcess.queryAllPhieuThueWithCccd(
          str: _searchMaDocGiaController.text);
      _phieuTras = await dbProcess.queryPhieuTraWithCccd(
          str: _searchMaDocGiaController.text);
    }

    setState(() {
      _isProcessingMaDocGia = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tìm khách hàng',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchMaDocGiaController,
                            autofocus: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 245, 246, 250),
                              hintText: 'Nhập căn cước công dân',
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(14),
                              isCollapsed: true,
                              errorMaxLines: 2,
                            ),
                            onEditingComplete: _searchMaDocGia,
                          ),
                        ),
                        const Gap(10),
                        _isProcessingMaDocGia
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                height: 44,
                                width: 44,
                                padding: const EdgeInsets.all(12),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton.filled(
                                onPressed: _searchMaDocGia,
                                icon: const Icon(Icons.arrow_forward_rounded),
                                style: myIconButtonStyle,
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(50),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Họ tên:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 44,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: _hoTenDocGia.isEmpty
                            ? const Color(0xffEFEFEF)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _hoTenDocGia,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(50),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số điện thoại:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 44,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: _soDienThoai.isEmpty
                            ? const Color(0xffEFEFEF)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _soDienThoai,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(4),
          if (_errorText.isNotEmpty)
            Text(
              _errorText,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          const Gap(10),
          const Text(
            'DANH SÁCH PHIẾU THUÊ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          Expanded(
            child: _phieuThues.isEmpty
                ? const Text(
                    'Chưa có dữ liệu Phiếu Thuê được tìm thấy',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                  )
                : DanhSachPhieuThue(
                    phieuThues: _phieuThues,
                  ),
          ),
          const Gap(20),
          const Text(
            'DANH SÁCH PHIẾU TRẢ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          Expanded(
            child: _phieuTras.isEmpty
                ? const Text(
                    'Chưa có dữ liệu Phiếu Trả được tìm thấy',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                  )
                : DanhSachPhieuTra(phieuTras: _phieuTras),
          ),
        ],
      ),
    );
  }
}
