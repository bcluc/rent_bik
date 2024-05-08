import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_bik/models/dong_xe.dart';

class SelectedDongXeCubit extends Cubit<List<DongXe>> {
  SelectedDongXeCubit() : super([]);
  /* secondary constructor */
  SelectedDongXeCubit.of(List<DongXe> dongXes) : super(dongXes);

  void add(DongXe dongXe) => emit([...state, dongXe]);
  void remove(DongXe dongXe) {
    state.removeWhere(
      (element) => element.maDongXe == dongXe.maDongXe,
    );
    emit([...state]);
  }

  bool contains(DongXe needCheckDongXe) {
    for (var dongXe in state) {
      if (dongXe.maDongXe == needCheckDongXe.maDongXe) {
        return true;
      }
    }
    return false;
  }
}
