import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_bik/models/hang_xe.dart';

class SelectedHangXeCubit extends Cubit<List<HangXe>> {
  SelectedHangXeCubit() : super([]);
  /* secondary constructor */
  SelectedHangXeCubit.of(List<HangXe> hangXes) : super(hangXes);

  void add(HangXe hangXe) => emit([...state, hangXe]);
  void remove(HangXe hangXe) {
    state.removeWhere(
      (element) => element.maHangXe == hangXe.maHangXe,
    );
    emit([...state]);
  }

  bool contains(HangXe needCheckHangXe) {
    for (var dongXe in state) {
      if (dongXe.maHangXe == needCheckHangXe.maHangXe) {
        return true;
      }
    }
    return false;
  }
}
