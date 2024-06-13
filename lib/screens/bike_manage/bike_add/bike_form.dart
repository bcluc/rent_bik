// ignore_for_file: constant_identifier_names

import 'package:dart_date/dart_date.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/components/label_text_form_field.dart';
import 'package:rent_bik/components/label_text_form_field_date_picker.dart';
import 'package:rent_bik/cubits/selected_dong_xe_cubit.dart';
import 'package:rent_bik/cubits/selected_hang_xe.dart';
import 'package:rent_bik/dto/xe_dto.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/dong_xe.dart';
import 'package:rent_bik/models/hang_xe.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class BikeForm extends StatefulWidget {
  const BikeForm({super.key, this.editXe});

  final XeDTO? editXe;

  @override
  State<BikeForm> createState() => _BikeFormState();
}

enum LoaiXe {
  car('Ô tô'),
  bike('Xe máy');

  const LoaiXe(this.label);
  final String label;
}

//A1, A2, A3, A4, B1, B2, C, D, E, FB2, FD, FE, FC
enum GPLX {
  none('Không có'),
  A1('A1'),
  A2('A2'),
  A3('A3'),
  A4('A4'),
  B1('B1'),
  B2('B2'),
  C('C'),
  D('D'),
  E('E'),
  FB2('FB2'),
  FD('FD'),
  FE('FE'),
  FC('FC');

  const GPLX(this.label);
  final String label;
}

//Tình trạng có sẵn/ không có sẵn
enum TinhTrang {
  available('Có sẵn'),
  nonAvailable('Không có sẵn');

  const TinhTrang(this.label);
  final String label;
}

class _BikeFormState extends State<BikeForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateBuyController = TextEditingController(
    text: DateTime.now().toVnFormat(),
  );
  final _bsxController = TextEditingController();
  final _tinhTrangController = TextEditingController();
  final _loaiXeController = TextEditingController();
  final _hangGPLXController = TextEditingController();
  final _giaThueController = TextEditingController();
  final _giaMuaController = TextEditingController();
  final _soHanhTrinhController = TextEditingController();
  final _soBHXController = TextEditingController();

  TinhTrang? selectedTinhTrang;
  GPLX? selectedGPLX;
  LoaiXe? selectedLoaiXe;

  bool _isProcessing = false;
  void _saveXe() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      await Future.delayed(const Duration(microseconds: 200));

      if (widget.editXe == null) {
        XeDTO newXeDto = XeDTO(
          bienSoXe: _bsxController.text,
          tinhTrang: _tinhTrangController.text,
          giaThue: int.parse(_giaThueController.text),
          hangGPLX: _hangGPLXController.text,
          loaiXe: _loaiXeController.text,
          giaMua: int.parse(_giaMuaController.text),
          dongXes: context.read<SelectedDongXeCubit>().state,
          ngayMua: vnDateFormat.parse(_dateBuyController.text),
          hangXes: context.read<SelectedHangXeCubit>().state,
          soHanhTrinh: int.parse(_soHanhTrinhController.text),
        );

        int returningId = await dbProcess.createXe(newXeDto);
        newXeDto.maXe = returningId;

        if (mounted) {
          Navigator.of(context).pop(newXeDto);
        }
      } else {
        widget.editXe!.bienSoXe = _bsxController.text;
        widget.editXe!.tinhTrang = _tinhTrangController.text;
        widget.editXe!.giaThue = int.parse(_giaThueController.text);
        widget.editXe!.giaMua = int.parse(_giaMuaController.text);
        widget.editXe!.loaiXe = _loaiXeController.text;
        widget.editXe!.hangGPLX = _hangGPLXController.text;
        widget.editXe!.ngayMua = vnDateFormat.parse(_dateBuyController.text);
        widget.editXe!.soHanhTrinh = int.parse(_soHanhTrinhController.text);

        // ignore: use_build_context_synchronously
        widget.editXe!.dongXes = context.read<SelectedDongXeCubit>().state;
        // ignore: use_build_context_synchronously
        widget.editXe!.hangXes = context.read<SelectedHangXeCubit>().state;

        await dbProcess.updateXeDto(widget.editXe!);

        if (mounted) {
          Navigator.of(context).pop('updated');
        }
      }

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editXe == null
                ? 'Tạo thông tin xe thành công.'
                : 'Cập nhật thông tin thành công'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            width: 300,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.editXe != null) {
      _dateBuyController.text = widget.editXe!.ngayMua.toVnFormat();
      _bsxController.text = widget.editXe!.bienSoXe;
      _tinhTrangController.text = widget.editXe!.tinhTrang;
      _loaiXeController.text = widget.editXe!.loaiXe;
      _hangGPLXController.text = widget.editXe!.hangGPLX;
      _giaThueController.text = widget.editXe!.giaThue.toString();
      _giaMuaController.text = widget.editXe!.giaMua.toString();
      _soHanhTrinhController.text = widget.editXe!.soHanhTrinh.toString();
      _soBHXController.text = widget.editXe!.soBHX.toString();
    }
  }

  @override
  void dispose() {
    _dateBuyController.dispose();
    _bsxController.dispose();
    _tinhTrangController.dispose();
    _loaiXeController.dispose();
    _hangGPLXController.dispose();
    _giaThueController.dispose();
    _giaMuaController.dispose();
    _soHanhTrinhController.dispose();
    _soBHXController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 30,
        ),
        child: SizedBox.expand(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.editXe == null
                                ? 'THÊM XE MỚI'
                                : 'SỬA THÔNG TIN XE',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        ],
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LabelTextFormField(
                              controller: _bsxController,
                              labelText: 'Biển số',
                            ),
                            const SizedBox(height: 10),
                            DropdownMenu<TinhTrang>(
                              initialSelection: TinhTrang.available,
                              controller: _tinhTrangController,
                              // requestFocusOnTap is enabled/disabled by platforms when it is null.
                              // On mobile platforms, this is false by default. Setting this to true will
                              // trigger focus request on the text field and virtual keyboard will appear
                              // afterward. On desktop platforms however, this defaults to true.
                              requestFocusOnTap: true,
                              label: const Text('Tình trạng'),
                              onSelected: (TinhTrang? tinhTrang) {
                                setState(() {
                                  selectedTinhTrang = tinhTrang;
                                });
                              },
                              dropdownMenuEntries: TinhTrang.values
                                  .map<DropdownMenuEntry<TinhTrang>>(
                                      (TinhTrang tinhTrang) {
                                return DropdownMenuEntry<TinhTrang>(
                                  value: tinhTrang,
                                  label: tinhTrang.label,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            LabelTextFormField(
                              controller: _giaThueController,
                              labelText: 'Giá thuê',
                            ),
                            const SizedBox(height: 10),
                            LabelTextFormField(
                              controller: _giaMuaController,
                              labelText: 'Giá mua',
                            ),
                            const SizedBox(height: 10),
                            DropdownMenu<LoaiXe>(
                              initialSelection: LoaiXe.bike,
                              controller: _loaiXeController,
                              requestFocusOnTap: true,
                              label: const Text('Loại xe'),
                              onSelected: (LoaiXe? loaiXe) {
                                setState(() {
                                  selectedLoaiXe = loaiXe;
                                });
                              },
                              dropdownMenuEntries: LoaiXe.values
                                  .map<DropdownMenuEntry<LoaiXe>>(
                                      (LoaiXe loaiXe) {
                                return DropdownMenuEntry<LoaiXe>(
                                  value: loaiXe,
                                  label: loaiXe.label,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            DropdownMenu<GPLX>(
                              initialSelection: GPLX.none,
                              controller: _hangGPLXController,
                              requestFocusOnTap: true,
                              label: const Text('GPLX'),
                              onSelected: (GPLX? gplx) {
                                setState(() {
                                  selectedGPLX = gplx;
                                });
                              },
                              dropdownMenuEntries: GPLX.values
                                  .map<DropdownMenuEntry<GPLX>>((GPLX gplx) {
                                return DropdownMenuEntry<GPLX>(
                                  value: gplx,
                                  label: gplx.label,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            LabelTextFieldDatePicker(
                              labelText: 'Ngày mua',
                              controller: _dateBuyController,
                              initialDateInPicker: widget.editXe != null
                                  ? widget.editXe!.ngayMua
                                  : DateTime.now(),
                              lastDate: DateTime.now().addYears(50),
                            ),
                            const SizedBox(height: 10),
                            LabelTextFormField(
                              controller: _soHanhTrinhController,
                              labelText: 'Số hành trình',
                            ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Dòng xe',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            BlocBuilder<SelectedDongXeCubit, List<DongXe>>(
                              builder: (ctx, dongXes) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                    dongXes.length,
                                    (index) {
                                      bool isDongXeHover = false;
                                      return StatefulBuilder(
                                        builder: (ctx, setStateDongXeItem) {
                                          return MouseRegion(
                                            onEnter: (_) => setStateDongXeItem(
                                              () => isDongXeHover = true,
                                            ),
                                            onHover: (_) {
                                              if (isDongXeHover == false) {
                                                setStateDongXeItem(
                                                  () => isDongXeHover = true,
                                                );
                                              }
                                            },
                                            onExit: (_) => setStateDongXeItem(
                                              () => isDongXeHover = false,
                                            ),
                                            child: Ink(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      16, 4, 24, 4),
                                              color: isDongXeHover
                                                  ? Colors.grey.withOpacity(0.1)
                                                  : Colors.transparent,
                                              child: Row(
                                                children: [
                                                  const SizedBox(
                                                    height: 40,
                                                  ),
                                                  Expanded(
                                                    child: Text(dongXes[index]
                                                        .tenDongXe
                                                        .capitalizeFirstLetterOfEachWord()),
                                                  ),
                                                  const Gap(12),
                                                  if (isDongXeHover)
                                                    IconButton(
                                                      onPressed: () {
                                                        context
                                                            .read<
                                                                SelectedDongXeCubit>()
                                                            .remove(
                                                                dongXes[index]);
                                                      },
                                                      icon: const Icon(Icons
                                                          .horizontal_rule),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            const Gap(12),
                            const Text(
                              'Hãng xe',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            BlocBuilder<SelectedHangXeCubit, List<HangXe>>(
                                builder: (ctx, hangXes) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                  hangXes.length,
                                  // (index) => Text(theLoais[index].tenTheLoai.capitalizeFirstLetter()),
                                  (index) {
                                    bool isHangXeHover = false;
                                    return StatefulBuilder(
                                      builder: (ctx, setStateHangXeItem) {
                                        return MouseRegion(
                                          onEnter: (_) => setStateHangXeItem(
                                            () => isHangXeHover = true,
                                          ),
                                          onHover: (_) {
                                            if (isHangXeHover == false) {
                                              setStateHangXeItem(
                                                () => isHangXeHover = true,
                                              );
                                            }
                                          },
                                          onExit: (_) => setStateHangXeItem(
                                            () => isHangXeHover = false,
                                          ),
                                          child: Ink(
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 4, 24, 4),
                                            color: isHangXeHover
                                                ? Colors.grey.withOpacity(0.1)
                                                : Colors.transparent,
                                            child: Row(
                                              children: [
                                                const SizedBox(
                                                  height: 40,
                                                ),
                                                Expanded(
                                                  child: Text(hangXes[index]
                                                      .tenHangXe
                                                      .capitalizeFirstLetter()),
                                                ),
                                                const Gap(12),
                                                if (isHangXeHover)
                                                  IconButton(
                                                    onPressed: () {
                                                      context
                                                          .read<
                                                              SelectedHangXeCubit>()
                                                          .remove(
                                                              hangXes[index]);
                                                    },
                                                    icon: const Icon(
                                                        Icons.horizontal_rule),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      _isProcessing
                          ? const SizedBox(
                              height: 44,
                              width: 44,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              ),
                            )
                          : FilledButton(
                              onPressed: _saveXe,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 30,
                                ),
                              ),
                              child: const Text(
                                'Lưu',
                                textAlign: TextAlign.center,
                              ),
                            ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
