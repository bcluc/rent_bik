import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/dto/phieu_bao_tri_can_tra_dto.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/screens/maintance_manage/maintance_billing/maintance_billing_section.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class BillingMaintance extends StatefulWidget {
  const BillingMaintance({super.key});

  @override
  State<BillingMaintance> createState() => BillingMaintanceState();
}

class BillingMaintanceState extends State<BillingMaintance> {
  final _searchBienSoXeController = TextEditingController();

  final ngayTraController = TextEditingController(
    text: DateTime.now().toVnFormat(),
  );

  String _errorText = '';
  String _maXe = '';
  String _soBHX = '';

  bool _isProcessingMaDocGia = false;

  int _selectedPhieuBaoTri = -1;

  List<PhieuBaoTriCanTraDTO> _phieuBaoTris = [];

  Future<void> _searchBSX() async {
    _errorText = '';
    if (_searchBienSoXeController.text.isEmpty) {
      _errorText = 'Bạn chưa nhập Biển số xe.';
    }

    if (_errorText.isNotEmpty) {
      setState(() {});
      return;
    }

    setState(() {
      _isProcessingMaDocGia = true;
    });

    _soBHX = '';
    _maXe = '';

    String bienSoXe = _searchBienSoXeController.text;

    int countResult =
        await dbProcess.countPhieuBaoTriChuaTTWithString(str: bienSoXe);
    await Future.delayed(const Duration(milliseconds: 200));

    if (countResult == 0) {
      _errorText = 'Không tìm thấy Xe.';
    } else {
      _phieuBaoTris =
          await dbProcess.queryPhieuBaoTriChuaTTWithString(str: bienSoXe);
      _maXe = _phieuBaoTris.first.maXe.toString();
      _soBHX = _phieuBaoTris.first.soBHX;
      _selectedPhieuBaoTri = -1;
    }

    setState(() {
      _isProcessingMaDocGia = false;
    });
  }

  @override
  void dispose() {
    _searchBienSoXeController.dispose();
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
                      'Tìm Xe',
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
                            controller: _searchBienSoXeController,
                            autofocus: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 245, 246, 250),
                              hintText: 'Nhập Biển số xe',
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
                      'Mã Xe:',
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
                        color: _maXe.isEmpty
                            ? const Color(0xffEFEFEF)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _maXe,
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
                      'Số bảo hiểm xe:',
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
                        color: _soBHX.isEmpty
                            ? const Color(0xffEFEFEF)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _soBHX,
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
            'DANH SÁCH PHIẾU BẢO TRÌ CẦN THANH TOÁN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          _isProcessingMaDocGia
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : _maXe.isEmpty
                  ? Text(
                      _errorText.isEmpty
                          ? 'Bạn cần nhập biển số xe để hiển thị danh sách'
                          : _errorText,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        color: _errorText.isEmpty
                            ? null
                            : Theme.of(context).colorScheme.error,
                      ),
                    )
                  : _phieuBaoTris.isEmpty
                      ? Text(
                          'Xe có biển số $_soBHX chưa có phiếu bảo trì nào.',
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
                                            'Mã bảo trì',
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
                                            'Ngày bảo trì',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Text(
                                            'Số bảo hiểm xe',
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
                                            'Tên hãng',
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
                                            'Tên dòng',
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
                                  _phieuBaoTris.length,
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
                                                      _selectedPhieuBaoTri =
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
                                                                ? 'Thanh toán'
                                                                : _phieuBaoTris[
                                                                        index]
                                                                    .maPhieuBaoTri
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
                                                child: Text(
                                                  _phieuBaoTris[index].bienSoXe,
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
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        _phieuBaoTris[index]
                                                            .ngayBaoTri
                                                            .toVnFormat(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                ),
                                                child: Text(
                                                  _phieuBaoTris[index].soBHX,
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
                                                  _phieuBaoTris[index]
                                                      .tenHangXe,
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
                                                  _phieuBaoTris[index]
                                                      .tenDongXe,
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
                                ThanhToanBaoTriSection(
                                  maPhieuBaoTri: _selectedPhieuBaoTri == -1
                                      ? null
                                      : _phieuBaoTris[_selectedPhieuBaoTri]
                                          .maPhieuBaoTri,
                                  ngayThanhToan: _selectedPhieuBaoTri == -1
                                      ? null
                                      : _phieuBaoTris[_selectedPhieuBaoTri]
                                          .ngayBaoTri,
                                  onThanhToan: () => setState(() {
                                    /* Xóa phiếu mượn và Update UI */
                                    _phieuBaoTris
                                        .removeAt(_selectedPhieuBaoTri);
                                    _selectedPhieuBaoTri = -1;
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
