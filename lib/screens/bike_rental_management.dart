import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:rent_bik/screens/bike_manage/bike_manage.dart';
import 'package:rent_bik/screens/borrow_return_manage/borrow_manage.dart';
import 'package:rent_bik/screens/customer_manage/customer_manage.dart';
import 'package:rent_bik/screens/maintance_manage/maintance_manage.dart';
import 'package:rent_bik/screens/report/report.dart';
import '../components/doi_ma_pin.dart';
import '../components/khoa_man_hinh_dialog.dart';

class BikeRentalManagement extends StatefulWidget {
  const BikeRentalManagement({super.key});

  @override
  State<BikeRentalManagement> createState() => _BikeRentalManagementState();
}

class _BikeRentalManagementState extends State<BikeRentalManagement>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var windowButtonColors = WindowButtonColors(
      mouseOver: Theme.of(context).colorScheme.primary,
    );
    return Scaffold(
      body: Column(
        children: [
          Ink(
            color: Theme.of(context).colorScheme.background,
            child: Column(
              children: [
                WindowTitleBarBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: MoveWindow(),
                      ),
                      MinimizeWindowButton(colors: windowButtonColors),
                      MaximizeWindowButton(colors: windowButtonColors),
                      CloseWindowButton(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      const Gap(30),
                      SvgPicture.asset(
                        'assets/logo/imgLogo.svg',
                        width: 200,
                      ),
                      const Gap(80),
                      Expanded(
                        child: TabBar(
                          controller: _tabController,
                          labelStyle: const TextStyle(fontSize: 16),
                          tabs: const [
                            Tab(
                              text: "Khách hàng",
                              height: 60,
                            ),
                            Tab(
                              text: "Quản lý Xe",
                              height: 60,
                            ),
                            Tab(
                              text: "Bảo trì Xe",
                              height: 60,
                            ),
                            Tab(
                              text: "Thuê trả",
                              height: 60,
                            ),
                            Tab(
                              text: "Báo cáo",
                              height: 60,
                            ),
                          ],
                          indicator: BoxDecoration(
                            // color: Colors.white,
                            // borderRadius: BorderRadius.vertical(
                            //   top: Radius.circular(8),
                            // ),
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          splashBorderRadius: BorderRadius.circular(8),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          overlayColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2);
                            }
                            if (states.contains(MaterialState.pressed)) {
                              return Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2);
                            }
                            return Colors.transparent;
                          }),
                          labelColor: Colors.white,
                        ),
                      ),
                      const Gap(70),
                      PopupMenuButton(
                        icon: const Image(
                          image: AssetImage('assets/images/profile_user.png'),
                          width: 32,
                        ),
                        position: PopupMenuPosition.under,
                        offset: const Offset(0, 8),
                        itemBuilder: (ctx) => <PopupMenuEntry>[
                          PopupMenuItem(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) => const KhoaManHinhDialog(),
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.lock_rounded),
                                Gap(12),
                                Text('Khóa màn hình'),
                              ],
                            ),
                          ),
                        ],
                        surfaceTintColor: Colors.transparent,
                        tooltip: '',
                      ),
                      const Gap(30),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                CustomerManage(),
                BikeManage(),
                MaintanceManage(),
                BorrowReturnManage(),
                Report(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
