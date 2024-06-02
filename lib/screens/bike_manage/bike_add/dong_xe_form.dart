import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/cubits/selected_dong_xe_cubit.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/dong_xe.dart';
import 'package:rent_bik/utils/extesion.dart';

class DongXeForm extends StatefulWidget {
  const DongXeForm({super.key});

  @override
  State<DongXeForm> createState() => _DongXeFormState();
}

class _DongXeFormState extends State<DongXeForm> {
  late final List<DongXe> _dongXes;
  late List<DongXe> _filteredDongXes;

  late final Future<void> _futureDongXes = _getDongXes();
  Future<void> _getDongXes() async {
    _dongXes = await dbProcess.queryDongXes();
  }

  final _themDongXeController = TextEditingController();
  final _timDongXeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 30,
        ),
        child: FutureBuilder(
          future: _futureDongXes,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            String searchText = _timDongXeController.text.toLowerCase();
            if (searchText.isEmpty) {
              _filteredDongXes = List.of(_dongXes);
            } else {
              _filteredDongXes = _dongXes
                  .where((element) =>
                      element.tenDongXe.toLowerCase().contains(searchText))
                  .toList();
            }

            return Column(
              children: [
                const Text(
                  'DÒNG XE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Gap(20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _themDongXeController,
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(
                          right: 8,
                        ),
                        child: Icon(Icons.add_rounded),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        maxWidth: 32,
                      ),
                      hintText: 'Thêm Dòng Xe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    ),
                    onEditingComplete: () async {
                      // Thêm Dòng Xe mới vào Database
                      DongXe newDongXe = DongXe(
                        tenDongXe: _themDongXeController.text,
                      );
                      int returningId = await dbProcess.insertDongXe(newDongXe);
                      newDongXe.maDongXe = returningId;

                      /* Cập nhật lại danh sách Dòng Xe */
                      setState(() {
                        _dongXes.insert(0, newDongXe);
                        _themDongXeController.clear();
                      });
                    },
                  ),
                ),
                /* Tìm kiếm Dòng Xe */
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _timDongXeController,
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(
                          right: 8,
                        ),
                        child: Icon(Icons.search),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        maxWidth: 32,
                      ),
                      hintText: 'Tìm tên Dòng Xe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    ),
                    onEditingComplete: () {
                      setState(() {});
                    },
                    onChanged: (value) async {
                      if (value.isEmpty) {
                        await Future.delayed(const Duration(milliseconds: 50));
                        setState(() {});
                      }
                    },
                  ),
                ),
                /* Danh sách Dòng Xe */
                Expanded(
                  child: ListView(
                    children: List.generate(
                      _filteredDongXes.length,
                      (index) {
                        final dongXe = _filteredDongXes[index];
                        bool isHover = false;

                        return StatefulBuilder(
                          builder: (ctx, setStateListItem) {
                            return MouseRegion(
                              onEnter: (event) => setStateListItem(
                                () => isHover = true,
                              ),
                              onHover: (_) {
                                if (isHover == false) {
                                  setStateListItem(
                                    () => isHover = true,
                                  );
                                }
                              },
                              onExit: (_) => setStateListItem(
                                () => isHover = false,
                              ),
                              child: Ink(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 4, 24, 4),
                                color: isHover
                                    ? Colors.grey.withOpacity(0.1)
                                    : Colors.transparent,
                                child: Row(
                                  children: [
                                    /* Thêm SizedBox height = 40 để cho mọi ListItem có chiều cao bằng nhau */
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    Text(_filteredDongXes[index]
                                        .tenDongXe
                                        .capitalizeFirstLetter()),
                                    const Spacer(),
                                    if (isHover)
                                      BlocBuilder<SelectedDongXeCubit,
                                          List<DongXe>>(
                                        builder: (ctx, selectedDongXes) {
                                          bool isSelected = false;
                                          for (var selectedDongXe
                                              in selectedDongXes) {
                                            if (selectedDongXe.maDongXe ==
                                                dongXe.maDongXe) {
                                              isSelected = true;
                                              break;
                                            }
                                          }
                                          return AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            transitionBuilder:
                                                (child, animation) =>
                                                    ScaleTransition(
                                              scale: animation,
                                              child: child,
                                            ),
                                            child: !isSelected
                                                ? IconButton(
                                                    key: const ValueKey(
                                                        'check-button'),
                                                    onPressed: () {
                                                      context
                                                          .read<
                                                              SelectedDongXeCubit>()
                                                          .add(dongXe);

                                                      setStateListItem(() {});
                                                    },
                                                    icon:
                                                        const Icon(Icons.check),
                                                  )
                                                : IconButton(
                                                    key: const ValueKey(
                                                        'remove-button'),
                                                    onPressed: () {
                                                      context
                                                          .read<
                                                              SelectedDongXeCubit>()
                                                          .remove(dongXe);
                                                      setStateListItem(() {});
                                                    },
                                                    icon: const Icon(
                                                        Icons.horizontal_rule),
                                                  ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
