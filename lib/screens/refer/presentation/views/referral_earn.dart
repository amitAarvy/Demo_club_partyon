import 'package:club/screens/refer/data/models/refer_model.dart';
import 'package:club/screens/refer/presentation/const/refer_const.dart';
import 'package:club/screens/refer/presentation/controller/refer_controller.dart';
import 'package:club/screens/refer/presentation/views/widgets/refer_info_card.dart';
import 'package:club/screens/refer/presentation/views/widgets/refer_info_row.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class ReferralEarn extends StatefulWidget {
  const ReferralEarn({super.key});

  @override
  State<ReferralEarn> createState() => _ReferralEarnState();
}

class _ReferralEarnState extends State<ReferralEarn>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<ReferModel> referralList = [];

  @override
  void initState() {
    tabController =
        TabController(length: ReferConst.referTabList.length, vsync: this);
    getReferralList();
    super.initState();
  }

  void getReferralList() async {
    referralList = await ReferController.getReferList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: ReferConst.referTabList.length,
      child: Scaffold(
        backgroundColor: matte(),
        appBar: appBar(context,
            title: "Refer", showBack: true, showLogo: true, tabController: tabController),
        body: Column(
          children: [
            TabBar(
                controller: tabController,
                labelColor: Colors.white,
                tabs: ReferConst.referTabList
                    .map((String e) => Tab(text: e))
                    .toList()),
            Expanded(
              child: TabBarView(
                  controller: tabController,
                  children: ReferConst.referTabList.map((String e) {
                    List<ReferModel> selectedReferList = referralList
                        .where((data) => data.type == e.toLowerCase())
                        .toList();
                    if (selectedReferList.isNotEmpty) {
                      return Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(color: Colors.purple),
                            padding: const EdgeInsets.all(8.0),
                            child: const Row(
                              children: [
                                ReferInfoRow(text: 'Name'),
                                ReferInfoRow(text: 'Date'),
                                ReferInfoRow(text: 'Transaction'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: selectedReferList.length,
                              itemBuilder: (context, index) => ReferEarnCard(
                                title: selectedReferList[index].name ?? 'NA',
                                uid:  '0',
                                date: selectedReferList[index].date?? '',
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: Text(
                          'No referrals found for $e',
                          style: TextStyle(color: Colors.white, fontSize: 50.sp),
                        ),
                      );
                    }
                  }).toList()),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FloatingActionButton(
                  onPressed: () {
                    ReferController.onTapReferButton();
                  },
                  child: const Icon(FontAwesomeIcons.share),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
