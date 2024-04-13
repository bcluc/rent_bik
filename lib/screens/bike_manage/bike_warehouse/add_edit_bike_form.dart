import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:rent_bik/components/label_text_form_field.dart';
import 'package:rent_bik/components/label_text_form_field_date_picker.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/xe.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class AddEditBikeForm extends StatefulWidget {
  const AddEditBikeForm({super.key, this.editXe});

  final Xe? editXe;

  @override
  State<AddEditBikeForm> createState() => _AddEditBikeFormState();
}

class _AddEditBikeFormState extends State<AddEditBikeForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  // Biển số xe
  final _plateController = TextEditingController();

  final _conditionController = TextEditingController();

  final _rentCostController = TextEditingController();

  final _noteController = TextEditingController();

  final _lincenseController = TextEditingController();

  void saveXe(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      if (widget.editXe == null) {
        try {
          Xe newXe = Xe(
            _plateController.text.toLowerCase(),
            _conditionController.text.toLowerCase(),
            int.parse(_rentCostController.text),
            _lincenseController.text.toLowerCase(),
            _noteController.text,
          );

          int returningId = await dbProcess.insertXe(newXe);

          if (mounted) {
            Navigator.of(context).pop(newXe);
          } else {
            widget.editXe!.maXe = _plateController.text;
            widget.editXe!.tinhTrang = _conditionController.text;
            widget.editXe!.hangGPLX = _lincenseController.text.toLowerCase();
            widget.editXe!.ghiChu = _noteController.text;

            await dbProcess.updateXe(widget.editXe!);

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
                    ? 'Thêm khách hàng thành công.'
                    : 'Cập nhật thông tin thành công'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                width: 300,
              ),
            );
          }
        } catch (e) {}
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.editXe != null) {
      /*
      Nếu là chỉnh sửa khách hàng
      thì phải fill thông tin vào của khách hàng cần chỉnh sửa vào form
      */
      _plateController.text = widget.editXe!.maXe;
      _conditionController.text =
          widget.editXe!.hoTen.capitalizeFirstLetterOfEachWord();
      _rentCostController.text = widget.editXe!.ngaySinh.toVnFormat();
      _phoneController.text = widget.editXe!.soDienThoai;
      _lincenseController.text = widget.editXe!.hangGPLX!.toUpperCase();
      _noteController.text = widget.editXe!.ghiChu!;
    }
    // else {
    //   /*
    //   Nếu là thêm mới khách hàng, thì thiết lập sẵn Creation và ExpriationDate
    //   CreationDate là DateTime.now()
    //   ExpriationDate là DateTime.now() + 6 tháng
    //   */
    //   setCreationExpriationDate(DateTime.now());
    // }
  }

  @override
  void dispose() {
    /* dispose các controller để tránh lãng phí bộ nhớ */
    _conditionController.dispose();
    _rentCostController.dispose();
    _plateController.dispose();
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
                      widget.editXe == null
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
                  controller: _plateController,
                ),
                //
                const SizedBox(height: 10),
                LabelTextFormField(
                  labelText: 'Họ Tên',
                  controller: _conditionController,
                ),
                //
                const SizedBox(height: 10),
                LabelTextFieldDatePicker(
                  labelText: 'Ngày sinh',
                  controller: _rentCostController,
                  initialDateInPicker: widget.editXe != null
                      ? widget.editXe!.ngaySinh
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

                //
                const SizedBox(height: 10),
                LabelTextFormField(
                  labelText: 'Ghi chú',
                  controller: _noteController,
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
                          onPressed: () => saveXe(context),
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
