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
          _identityController.text,
          _fullnameController.text.toLowerCase(),
          vnDateFormat.parse(_dobController.text),
          _phoneController.text,
          _lincenseController.text.toUpperCase(),
          _noteController.text,
        );

        int returningId = await dbProcess.insertKhachHang(newKhachHang);

        if (mounted) {
          Navigator.of(context).pop(newKhachHang);
        }
      } else {
        widget.editKhachHang!.hoTen = _fullnameController.text.toLowerCase();
        widget.editKhachHang!.ngaySinh =
            vnDateFormat.parse(_dobController.text);
        widget.editKhachHang!.maKhachHang = _identityController.text;
        widget.editKhachHang!.soDienThoai = _phoneController.text;
        widget.editKhachHang!.hangGPLX = _lincenseController.text.toUpperCase();
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
      /*
      Nếu là chỉnh sửa độc giả
      thì phải fill thông tin vào của độc giả cần chỉnh sửa vào form
      */
      _identityController.text = widget.editKhachHang!.maKhachHang;
      _fullnameController.text =
          widget.editKhachHang!.hoTen.capitalizeFirstLetterOfEachWord();
      _dobController.text = widget.editKhachHang!.ngaySinh.toVnFormat();
      _phoneController.text = widget.editKhachHang!.soDienThoai;
      _lincenseController.text = widget.editKhachHang!.hangGPLX!;
      _noteController.text = widget.editKhachHang!.ghiChu!;
    } 
    // else {
    //   /* 
    //   Nếu là thêm mới Độc Giả, thì thiết lập sẵn Creation và ExpriationDate 
    //   CreationDate là DateTime.now()
    //   ExpriationDate là DateTime.now() + 6 tháng 
    //   */
    //   setCreationExpriationDate(DateTime.now());
    // }
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
                  lastDate: DateTime.now().subYears(18),
                ),
                //
                const SizedBox(height: 10),
                LabelTextFormField(
                  labelText: 'Địa chỉ',
                  controller: _identityController,
                ),
                //
                const SizedBox(height: 10),
                LabelTextFormField(
                  labelText: 'Số điện thoại',
                  controller: _phoneController,
                ),
                //
                const SizedBox(height: 10),
                const Text(
                  'Ngày lập thẻ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () async {
                    DateTime? chosenDate = await showDatePicker(
                      context: context,
                      initialDate: widget.editKhachHang != null
                          ? widget.editKhachHang!.ngayLapThe
                          : DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (chosenDate != null) {
                      setCreationExpriationDate(chosenDate);
                    }
                  },
                  child: TextFormField(
                    controller: _creationDateController,
                    enabled: false,
                    mouseCursor: SystemMouseCursors.click,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 245, 246, 250),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                      isCollapsed: true,
                      suffixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(
                          Icons.calendar_today,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                //
                const SizedBox(height: 10),
                LabelTextFormField(
                  labelText: 'Ngày hết hạn',
                  isEnable: false,
                  controller: _expirationDateController,
                ),
                if (widget.editKhachHang == null) ...[
                  const SizedBox(height: 10),
                  Text(
                    '*Thu tiền tạo thẻ ${ThamSoQuyDinh.phiTaoThe.toVnCurrencyFormat()}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  )
                ],
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
