import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
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
import 'package:rent_bik/models/xe.dart';
import 'package:rent_bik/screens/bike_manage/bike_add/bike_form.dart';
import 'package:rent_bik/screens/bike_manage/bike_add/dong_xe_form.dart';
import 'package:rent_bik/screens/bike_manage/bike_add/hang_xe_form.dart';
import 'package:rent_bik/utils/common_variables.dart';
import 'package:rent_bik/utils/extesion.dart';

class AddEditBikeForm extends StatefulWidget {
  const AddEditBikeForm({super.key, this.editXe});

  final XeDTO? editXe;

  @override
  State<AddEditBikeForm> createState() => _AddEditBikeFormState();
}

class _AddEditBikeFormState extends State<AddEditBikeForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 180),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => widget.editXe == null
                ? SelectedDongXeCubit()
                : SelectedDongXeCubit.of(
                    widget.editXe!.dongXes as List<DongXe>),
          ),
          BlocProvider(
            create: (_) => widget.editXe == null
                ? SelectedHangXeCubit()
                : SelectedHangXeCubit.of(
                    widget.editXe!.hangXes as List<HangXe>),
          ),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: BikeForm(
                editXe: widget.editXe,
              ),
            ),
            const Gap(12),
            const Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: DongXeForm(),
                  ),
                  Gap(12),
                  Expanded(
                    child: HangXeForm(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
