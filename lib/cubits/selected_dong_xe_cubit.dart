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

// class SelectedDongXeCubit extends Cubit<DongXeState> {
//   SelectedDongXeCubit() : super(DongXeState(dongXeList: []));

//   // Secondary constructor
//   SelectedDongXeCubit.of(List<DongXe> dongXes)
//       : super(DongXeState(dongXeList: dongXes));

//   // Method to add a DongXe to the list
//   void add(DongXe dongXe) {
//     emit(state.copyWith(dongXeList: [...state.dongXeList, dongXe]));
//   }

//   // Method to remove a DongXe from the list
//   void remove(DongXe dongXe) {
//     List<DongXe> updatedList = List.from(state.dongXeList)
//       ..removeWhere((element) => element.maDongXe == dongXe.maDongXe);
//     emit(state.copyWith(dongXeList: updatedList));
//   }

//   // Method to select a DongXe
//   void select(DongXe dongXe) {
//     emit(state.copyWith(selectedDongXe: dongXe));
//   }

//   // Method to clear the selection
//   void clearSelection() {
//     emit(state.copyWith(selectedDongXe: null));
//   }

//   // Method to check if a DongXe is selected
//   bool contains(DongXe needCheckDongXe) {
//     return state.selectedDongXe?.maDongXe == needCheckDongXe.maDongXe;
//   }
// }
