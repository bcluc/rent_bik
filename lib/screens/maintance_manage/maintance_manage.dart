import 'package:flutter/material.dart';
import 'package:rent_bik/screens/maintance_manage/maintance_add/add_maintance.dart';
import 'package:rent_bik/screens/maintance_manage/maintance_billing/maintance_billing.dart';
import 'package:rent_bik/screens/maintance_manage/maintance_list/maintance_list.dart';

class MaintanceManage extends StatefulWidget {
  const MaintanceManage({super.key});

  @override
  State<MaintanceManage> createState() => _MaintanceManageState();
}

class _MaintanceManageState extends State<MaintanceManage>
    with TickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 25, 30, 20),
            child: Ink(
              width: 750,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: TabBar(
                indicatorPadding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 6,
                ),
                controller: tabController,
                tabs: const [
                  Tab(text: "Bảo trì xe"),
                  Tab(text: "Thanh toán bảo trì xe"),
                  Tab(text: 'Phiếu bảo trì'),
                ],
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                splashBorderRadius: BorderRadius.circular(8),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
                unselectedLabelColor: Colors.white,
                overlayColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.white.withOpacity(0.3);
                  }
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.white.withOpacity(0.5);
                  }
                  return Colors.transparent;
                }),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                PhieuBaoTriSpect(),
                BillingMaintance(),
                MaintainceList()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
