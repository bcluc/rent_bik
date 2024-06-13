import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/dto/ket_qua_tra_phieu_dto.dart';
import 'package:rent_bik/dto/phieu_thue_can_tra_dto.dart';
import 'package:rent_bik/dto/thong_tin_khach_hang_dto.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/screens/borrow_return_manage/return/return_billing_section.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class ReturnManage extends StatefulWidget {
  const ReturnManage({super.key});

  @override
  State<ReturnManage> createState() => ReturnManageState();
}

class ReturnManageState extends State<ReturnManage> {
  final _searchCCCDController = TextEditingController();
  final _soTienController = TextEditingController();
  final _soHanhTrinhController = TextEditingController();
  final _ghiChuController = TextEditingController();
  final ngayTraController = TextEditingController(
    text: DateTime.now().toVnFormat(),
  );

  String _errorText = '';
  String _sdt = '';
  String _hoTen = '';

  bool _isProcessingCCCD = false;

  int _selectedPhieuThue = -1;

  List<PhieuThueCanTraDTO> _phieuThues = [];

  Future<void> _searchBSX() async {
    _errorText = '';
    if (_searchCCCDController.text.isEmpty) {
      _errorText = 'Bạn chưa nhập Căn cước công dân.';
    }

    if (_errorText.isNotEmpty) {
      setState(() {});
      return;
    }

    setState(() {
      _isProcessingCCCD = true;
    });

    _hoTen = '';
    _sdt = '';

    String cccd = _searchCCCDController.text;

    TTKhachHangDTO? khachHang =
        await dbProcess.queryTTKHPTWithString(str: cccd);
    await Future.delayed(const Duration(milliseconds: 200));

    if (khachHang == null) {
      _errorText = 'Không tìm thấy Khách hàng.';
    } else {
      _phieuThues = await dbProcess.queryPhieuThueChuaTTWithString(str: cccd);
      _sdt = khachHang.sdt;
      _hoTen = khachHang.hoTen;
      _selectedPhieuThue = -1;
    }

    setState(() {
      _isProcessingCCCD = false;
    });
  }

  @override
  void dispose() {
    _searchCCCDController.dispose();
    _soTienController.dispose();
    _soHanhTrinhController.dispose();
    _ghiChuController.dispose();
    super.dispose();
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
                      'Tìm Khách hàng',
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
                            controller: _searchCCCDController,
                            autofocus: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 245, 246, 250),
                              hintText: 'Nhập Căn cước công dân',
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(14),
                              isCollapsed: true,
                              errorMaxLines: 2,
                            ),
                            onEditingComplete: _searchBSX,
                          ),
                        ),
                        const Gap(10),
                        _isProcessingCCCD
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
                                onPressed: _searchBSX,
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
                        color: _hoTen.isEmpty
                            ? const Color(0xffEFEFEF)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _hoTen,
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
                        color: _sdt.isEmpty
                            ? const Color(0xffEFEFEF)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _sdt,
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
          const Gap(20),
          const Text(
            'DANH SÁCH PHIẾU THUÊ CẦN TRẢ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          _isProcessingCCCD
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : _sdt.isEmpty
                  ? Text(
                      _errorText.isEmpty
                          ? 'Bạn cần nhập căn cước công dân để hiển thị danh sách'
                          : _errorText,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        color: _errorText.isEmpty
                            ? null
                            : Theme.of(context).colorScheme.error,
                      ),
                    )
                  : _phieuThues.isEmpty
                      ? Text(
                          'Khách hàng $_hoTen chưa có phiếu thuê nào.',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                          ),
                        )
                      : Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: Theme.of(context).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: const Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 20, right: 15),
                                          child: Text(
                                            'Mã Phiếu thuê',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Text(
                                            'Biển số xe',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Text(
                                            'Hãng xe',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Text(
                                            'Dòng xe',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Text(
                                            'Giá cọc',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Text(
                                            'Ngày mượn',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Text(
                                            'Hạn trả',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...List.generate(
                                  _phieuThues.length,
                                  (index) {
                                    bool isMaPhieuMuonHover = false;
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 150,
                                              child: StatefulBuilder(builder:
                                                  (ctx, setStateMaPhieuMuon) {
                                                return InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedPhieuThue =
                                                          index;
                                                    });
                                                  },
                                                  onHover: (value) =>
                                                      setStateMaPhieuMuon(
                                                    () => isMaPhieuMuonHover =
                                                        value,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        20, 15, 15, 15),
                                                    child: SizedBox(
                                                      height: 24,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            isMaPhieuMuonHover
                                                                ? 'Trả'
                                                                : _phieuThues[
                                                                        index]
                                                                    .maPhieuThue
                                                                    .toString(),
                                                          ),
                                                          const Gap(6),
                                                          if (isMaPhieuMuonHover)
                                                            const Icon(Icons
                                                                .arrow_downward_rounded),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        _phieuThues[index]
                                                            .bienSoXe,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                ),
                                                child: Text(
                                                  _phieuThues[index].tenHangXe,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                ),
                                                child: Text(
                                                  _phieuThues[index].tenDongXe,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                ),
                                                child: Text(
                                                  _phieuThues[index]
                                                      .giaCoc
                                                      .toString(),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                ),
                                                child: Text(
                                                  _phieuThues[index]
                                                      .ngayThue
                                                      .toVnFormat(),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                ),
                                                child: Text(
                                                  _phieuThues[index]
                                                      .ngayTra
                                                      .toVnFormat(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                          height: 0,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const Spacer(),
                                TraPhieuThueSection(
                                  maPhieuThue: _selectedPhieuThue == -1
                                      ? null
                                      : _phieuThues[_selectedPhieuThue]
                                          .maPhieuThue,
                                  onTra: () => setState(() {
                                    /* Xóa phiếu mượn và Update UI */
                                    _phieuThues.removeAt(_selectedPhieuThue);
                                    _selectedPhieuThue = -1;
                                  }),
                                ),
                                const Gap(30)
                              ],
                            ),
                          ),
                        ),
        ],
      ),
    );
  }
}
