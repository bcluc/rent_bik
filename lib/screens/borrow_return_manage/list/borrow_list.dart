import 'package:flutter/material.dart';
import 'package:rent_bik/dto/phieu_thue_can_tra_dto.dart';
import 'package:rent_bik/utils/extesion.dart';

class DanhSachPhieuThue extends StatelessWidget {
  const DanhSachPhieuThue({super.key, required this.phieuThues});

  final List<PhieuThueCanTraDTO> phieuThues;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 150,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30, right: 15),
                    child: Text(
                      'Mã phiếu thuê',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Text(
                      'Biển số xe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Text(
                      'Giá cọc',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Text(
                      'Ngày mượn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Text(
                      'Hạn trả',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, right: 30),
                    child: Text(
                      'Tình trạng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: List.generate(
                phieuThues.length,
                (index) {
                  final tinhTrangColor = switch (phieuThues[index].tinhTrang) {
                    'Đã trả' => const Color.fromARGB(255, 184, 228, 164),
                    'Chưa trả' => const Color.fromARGB(255, 240, 92, 127),
                    String() => null,
                  };
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 150,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(30, 15, 15, 15),
                              child: Text(
                                phieuThues[index].maPhieuThue.toString(),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                phieuThues[index].bienSoXe,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                phieuThues[index].giaCoc.toString(),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                phieuThues[index].ngayThue.toVnFormat(),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                phieuThues[index].ngayTra.toVnFormat(),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 30),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: tinhTrangColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  phieuThues[index].tinhTrang,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 0,
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
