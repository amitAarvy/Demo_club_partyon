import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../utils/app_utils.dart';
import '../home/home_utils.dart';
import 'Analystics/PromotionEventAnalytics.dart';
import 'create_campaigns.dart';
import 'my Campaigns/my_compaigns.dart';


class CompaniesPage extends StatefulWidget {

  const CompaniesPage({super.key,});

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: appBar(context, title: "Campaigns", ),
        body:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                tile(
                    "Create \nCampaigns",
                    const Icon(
                      FontAwesomeIcons.user,
                      color: Colors.white,
                    ),
                    page:
                    const CreateCampaignsPage()
                ),
                tile(
                    "My Campaigns",
                    const Icon(
                      FontAwesomeIcons.addressBook,
                      color: Colors.white,
                    ),
                    page:
                    const MyCampaigns()
                ),
              ],
            ),
            tile(
                "Analytics",
                const Icon(
                  FontAwesomeIcons.addressBook,
                  color: Colors.white,
                ),
                page: const PromotionEvent()
            ),
          ],
        )
    );
  }



}
