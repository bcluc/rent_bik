import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/cubits/selected_hang_xe.dart';
import 'package:rent_bik/dto/hang_xe_dto.dart';
import 'package:rent_bik/main.dart';
import 'package:rent_bik/models/hang_xe.dart';
import 'package:rent_bik/utils/extesion.dart';

class HangXeForm extends StatefulWidget {
  const HangXeForm({super.key});

  @override
  State<HangXeForm> createState() => _HangXeFormState();
}

class _HangXeFormState extends State<HangXeForm> {
  late final List<HangXe> _hangXes;
  late List<HangXe> _filteredHangXes;

  late final Future<void> _futureHangXes = _getHangXes();
  Future<void> _getHangXes() async {
    _hangXes = await dbProcess.queryHangXes();
  }

  final _themHangXeController = TextEditingController();
  final _timHangXeController = TextEditingController();

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
          future: _futureHangXes,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            String searchText = _timHangXeController.text.toLowerCase();
            if (searchText.isEmpty) {
              _filteredHangXes = List.of(_hangXes);
            } else {
              _filteredHangXes = _hangXes
                  .where((element) =>
                      element.tenHangXe.toLowerCase().contains(searchText))
                  .toList();
            }

            return Column(
              children: [
                const Text(
                  'HÃNG XE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Gap(20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _themHangXeController,
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
                      hintText: 'Thêm Hãng Xe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    ),
                    onEditingComplete: () async {
                      // Thêm Dòng Xe mới vào Database
                      HangXe newHangXe = HangXe(
                        null,
                        _themHangXeController.text,
                      );
                      int returningId = await dbProcess.insertHangXe(newHangXe);
                      newHangXe.maHangXe = returningId;

                      /* Cập nhật lại danh sách Dòng Xe */
                      setState(() {
                        _hangXes.insert(0, newHangXe);
                        _themHangXeController.clear();
                      });
                    },
                  ),
                ),
                /* Tìm kiếm Dòng Xe */
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _timHangXeController,
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
                      hintText: 'Tìm tên Hãng Xe',
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
                      _filteredHangXes.length,
                      (index) {
                        final HangXe = _filteredHangXes[index];
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
                                    Text(_filteredHangXes[index]
                                        .tenHangXe
                                        .capitalizeFirstLetter()),
                                    const Spacer(),
                                    if (isHover)
                                      BlocBuilder<SelectedHangXeCubit,
                                          List<HangXe>>(
                                        builder: (ctx, selectedHangXes) {
                                          bool isSelected = false;
                                          for (var selectedHangXe
                                              in selectedHangXes) {
                                            if (selectedHangXe.maHangXe ==
                                                HangXe.maHangXe) {
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
                                                              SelectedHangXeCubit>()
                                                          .add(HangXe);

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
                                                              SelectedHangXeCubit>()
                                                          .remove(HangXe);
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
