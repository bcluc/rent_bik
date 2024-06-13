import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/dto/bao_hiem_xe_dto.dart';
import 'package:rent_bik/dto/bao_hiem_xe_new_dto.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/screens/bike_manage/insurance_manage/buy_insurance_section.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class BaoHiemSpect extends StatefulWidget {
  const BaoHiemSpect({super.key});

  @override
  State<BaoHiemSpect> createState() => _BaoHiemSpectState();
}

class _BaoHiemSpectState extends State<BaoHiemSpect> {
  final _searchBSXController = TextEditingController();

  String _errorText = '';
  String _soBaoHiemXe = '';
  String _ngayHetHan = '';
  String _ngayMua = '';
  int _maXe = -1;
  String _bienSoXe = '';

  bool _isProcessingBSX = false;

  Future<void> _searchBSX() async {
    _errorText = '';
    if (_searchBSXController.text.isEmpty) {
      _errorText = 'Bạn chưa nhập Biển số xe.';
    }

    if (_errorText.isNotEmpty) {
      setState(() {});
      return;
    }

    setState(() {
      _isProcessingBSX = true;
    });

    _ngayHetHan = '';
    _ngayMua = '';

    _soBaoHiemXe = '';
    _maXe = -1;
    _bienSoXe = '';

    String bienSoXe = _searchBSXController.text;

    String? resGetBHX = await dbProcess.queryStatusBHXWithBSX(bienSoXe);
    await Future.delayed(const Duration(milliseconds: 200));

    if (resGetBHX == 'success') {
      BaoHiemXeDTO bhx =
          await dbProcess.queryBaoHiemXeFullnameWithBSX(str: bienSoXe);
      await Future.delayed(const Duration(milliseconds: 200));
      _soBaoHiemXe = bhx.soBHX.toString();
      _ngayHetHan = bhx.ngayHetHan.toVnFormat();
      _ngayMua = bhx.ngayMua.toVnFormat();
      _maXe = bhx.maXe;
      _bienSoXe = bhx.bienSoXe;
    } else if (resGetBHX == "submit") {
      _errorText = 'Xe chưa có bảo hiểm.';
      BaoHiemXeNewDTO bhxNew =
          await dbProcess.queryNewBaoHiemXeSubmitedWithBSX(str: bienSoXe);
      await Future.delayed(const Duration(milliseconds: 200));
      _bienSoXe = bhxNew.bienSoXe;
      _maXe = bhxNew.maXe;
    } else {
      _errorText = 'Không tìm thấy Xe.';
    }

    setState(() {
      _isProcessingBSX = false;
    });
  }

  @override
  void dispose() {
    _searchBSXController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRA CỨU BẢO HIỂM XE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Gap(10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Biển số xe',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchBSXController,
                              autofocus: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 245, 246, 250),
                                hintText: 'Nhập biển số xe',
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
                          _isProcessingBSX
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                        color: _soBaoHiemXe.isEmpty
                            ? const Color(0xffEFEFEF)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _soBaoHiemXe,
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
                      'Ngày hết hạn:',
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
                        color: _ngayHetHan.isEmpty
                            ? const Color(0xffEFEFEF)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _ngayHetHan,
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
          _isProcessingBSX
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : _bienSoXe.isEmpty
                  ? Text(
                      _errorText.isEmpty
                          ? 'Bạn cần nhập biển số xe để tra cứu'
                          : _errorText,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        color: _errorText.isEmpty
                            ? null
                            : Theme.of(context).colorScheme.error,
                      ),
                    )
                  : const Text(
                      '',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                    ),
          _isProcessingBSX
              ? const Text(
                  '',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                )
              : BuyInsuranceSection(
                  onAdd: () => setState(() {}),
                  soBHX: _soBaoHiemXe == "" ? null : _soBaoHiemXe,
                  maXe: _maXe == -1 ? null : _maXe,
                  bienSoXe: _bienSoXe,
                  ngayHetHan: _ngayHetHan == ''
                      ? null
                      : vnDateFormat.parse(_ngayHetHan),
                  ngayMua: _ngayMua == '' ? null : vnDateFormat.parse(_ngayMua),
                )
        ],
      ),
    );
  }
}
