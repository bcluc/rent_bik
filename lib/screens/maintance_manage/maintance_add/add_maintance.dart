import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/dto/xe_dto.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/screens/maintance_manage/maintance_add/add_maintance_section.dart';
import 'package:rent_bik/utils/common_variables.dart';

class PhieuBaoTriSpect extends StatefulWidget {
  const PhieuBaoTriSpect({super.key});

  @override
  State<PhieuBaoTriSpect> createState() => _PhieuBaoTriSpectState();
}

class _PhieuBaoTriSpectState extends State<PhieuBaoTriSpect> {
  final _searchBSXController = TextEditingController();

  String _errorText = '';
  String _soBaoHiemXe = '';
  String _hangXe = '';
  String _dongXe = '';
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

    _hangXe = '';
    _dongXe = '';
    _soBaoHiemXe = '';
    _bienSoXe = '';

    String bienSoXe = _searchBSXController.text;

    String? resGetBHX = await dbProcess.getStatusXeWithBSX(bienSoXe);
    await Future.delayed(const Duration(milliseconds: 200));

    if (resGetBHX == 'success') {
      _bienSoXe = bienSoXe;
      XeDTO xe = await dbProcess.getXeWithString(str: bienSoXe);
      await Future.delayed(const Duration(milliseconds: 200));
      _soBaoHiemXe = xe.soBHX.toString();
      _hangXe = xe.hangXes.last.tenHangXe;
      _dongXe = xe.dongXes.last.tenDongXe;
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
            'TRA CỨU THÔNG TIN XE',
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
                      'Hãng xe:',
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
                        color: _hangXe.isEmpty
                            ? const Color(0xffEFEFEF)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _hangXe,
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
                      'Dòng xe:',
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
                        color: _dongXe.isEmpty
                            ? const Color(0xffEFEFEF)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _dongXe,
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
              : AddMaintanceSection(
                  bienSoXe: _bienSoXe,
                )
        ],
      ),
    );
  }
}
