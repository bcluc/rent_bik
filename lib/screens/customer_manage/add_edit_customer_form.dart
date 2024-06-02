// ignore_for_file: use_build_context_synchronously

import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:rent_bik/components/label_text_form_field.dart';
import 'package:rent_bik/components/label_text_form_field_date_picker.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/khach_hang.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class AddEditCustomerForm extends StatefulWidget {
  const AddEditCustomerForm({super.key, this.editKhachHang});

  final KhachHang? editKhachHang;

  @override
  State<AddEditCustomerForm> createState() => _AddEditCustomerFormState();
}

class _AddEditCustomerFormState extends State<AddEditCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  final _identityController = TextEditingController();

  final _fullnameController = TextEditingController();

  final _dobController = TextEditingController();

  final _phoneController = TextEditingController();

  final _noteController = TextEditingController();

  final _lincenseController = TextEditingController();

  final _totalTiabilitiesController = TextEditingController();

  void saveKhachHang(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      if (widget.editKhachHang == null) {
        KhachHang newKhachHang = KhachHang(
          maKhachHang: null,
          cccd: _identityController.text,
          hoTen: _fullnameController.text.toLowerCase(),
          ngaySinh: vnDateFormat.parse(_dobController.text),
          soDienThoai: _phoneController.text,
          hangGPLX: _lincenseController.text.toLowerCase(),
          ghiChu: _noteController.text,
        );

        int returningId = await dbProcess.insertKhachHang(newKhachHang);
        newKhachHang.maKhachHang = returningId;

        if (mounted) {
          Navigator.of(context).pop(newKhachHang);
        }
      } else {
        widget.editKhachHang!.hoTen = _fullnameController.text.toLowerCase();
        widget.editKhachHang!.ngaySinh =
            vnDateFormat.parse(_dobController.text);
        widget.editKhachHang!.cccd = _identityController.text;
        widget.editKhachHang!.soDienThoai = _phoneController.text;
        widget.editKhachHang!.hangGPLX = _lincenseController.text.toLowerCase();
        widget.editKhachHang!.ghiChu = _noteController.text;

        await dbProcess.updateKhachHang(widget.editKhachHang!);

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
            content: Text(widget.editKhachHang == null
                ? 'Thêm khách hàng thành công.'
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
    if (widget.editKhachHang != null) {
      //print(widget.editKhachHang.toString());
      /*
      Nếu là chỉnh sửa khách hàng
      thì phải fill thông tin vào của khách hàng cần chỉnh sửa vào form
      */
      _identityController.text = widget.editKhachHang!.cccd;
      _fullnameController.text =
          widget.editKhachHang!.hoTen.capitalizeFirstLetterOfEachWord();
      _dobController.text = widget.editKhachHang!.ngaySinh.toVnFormat();
      _phoneController.text = widget.editKhachHang!.soDienThoai;
      _lincenseController.text = widget.editKhachHang!.hangGPLX!.toUpperCase();
      _noteController.text = widget.editKhachHang!.ghiChu == null
          ? ""
          : widget.editKhachHang!.ghiChu!;
    }
  }

  @override
  void dispose() {
    /* dispose các controller để tránh lãng phí bộ nhớ */
    _fullnameController.dispose();
    _dobController.dispose();
    _identityController.dispose();
    _phoneController.dispose();
    _lincenseController.dispose();
    _noteController.dispose();
    _totalTiabilitiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 30,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.editKhachHang == null
                          ? 'THÊM KHÁCH HÀNG'
                          : 'SỬA THÔNG TIN KHÁCH HÀNG',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                LabelTextFormField(
                  labelText: 'Căn cước công dân',
                  controller: _identityController,
                ),
                //
                const SizedBox(height: 10),
                LabelTextFormField(
                  labelText: 'Họ Tên',
                  controller: _fullnameController,
                ),
                //
                const SizedBox(height: 10),
                LabelTextFieldDatePicker(
                  labelText: 'Ngày sinh',
                  controller: _dobController,
                  initialDateInPicker: widget.editKhachHang != null
                      ? widget.editKhachHang!.ngaySinh
                      : DateTime.now().subYears(18),
                  lastDate: DateTime.now(),
                ),
                //
                const SizedBox(height: 10),
                LabelTextFormField(
                  labelText: 'Số điện thoại',
                  controller: _phoneController,
                ),
                //
                const SizedBox(height: 10),
                LabelTextFormField(
                  labelText: 'Giấy phép lái xe',
                  controller: _lincenseController,
                  customValidator: (value) {
                    final RegExp regex = RegExp(r'^[A-Z]\d+(,\s*[A-Z]\d+)*$');
                    if (!regex.hasMatch(value!)) {
                      return 'Định dạng nhập sai, vui lòng nhập theo dạng A1, B2,...';
                    }
                    return null; // Return null if the input is valid
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  '*Theo định dạng Ax, Bx,... ',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 4),
                LabelTextFormField(
                  labelText: 'Ghi chú',
                  controller: _noteController,
                  customValidator: (value) {
                    return null;
                  },
                ),
                //
                const SizedBox(height: 50),
                Align(
                  alignment: Alignment.center,
                  child: _isProcessing
                      ? const SizedBox(
                          height: 44,
                          width: 44,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : FilledButton(
                          onPressed: () => saveKhachHang(context),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
