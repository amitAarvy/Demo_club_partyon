import 'dart:ui';

import 'package:club/screens/refer/data/models/refer_model.dart';
import 'package:club/screens/refer/presentation/const/refer_const.dart';
import 'package:club/screens/refer/presentation/controller/refer_controller.dart';
import 'package:club/screens/refer/presentation/views/refer_page.dart';
import 'package:club/screens/refer/presentation/views/referral_earn.dart';
import 'package:club/screens/refer/presentation/views/widgets/refer_info_card.dart';
import 'package:club/screens/refer/presentation/views/widgets/refer_info_row.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../home/home_utils.dart';


class ReferralEarning extends StatefulWidget {
  final String? isInf;
  const ReferralEarning({super.key, this.isInf});

  @override
  State<ReferralEarning> createState() => _ReferralEarningState();
}

class _ReferralEarningState extends State<ReferralEarning>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('check inf is ${uid()}');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: ReferConst.referTabList.length,
      child: Scaffold(
        backgroundColor: matte(),
        appBar: widget.isInf=='yes'?PreferredSize(preferredSize:Size.fromHeight(0), child: AppBar()): appBar(context,
            title: "Refers Earnings", showBack: true, ),
        body: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              tile(
                  "Referral",
                  const Icon(
                    Icons.view_day_outlined,
                    color: Colors.white,
                  ),
                  page:
                  widget.isInf == 'yes'?ReferralEarning():
                  ReferView(),
              ),
              // tile(
              //     "My Earning",
              //     const Icon(
              //       Icons.money,
              //       color: Colors.white,
              //     ),
              //   page: ReferralEarn()
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
