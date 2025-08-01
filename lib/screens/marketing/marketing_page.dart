import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/app_utils.dart';
import '../event_management/model/list_anaylsis_tabs.dart';
import '../home/home_utils.dart';
import 'metaPage.dart';
import 'notification.dart';

class MarketingPage extends StatefulWidget {
  const MarketingPage({super.key});

  @override
  State<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
     appBar: appBar(context, title: "Marketing", ),
      body: Center(
        child: Row(
         children: [
           tile(
               "Notification",
               const Icon(
                 Icons.notifications_active,
                 color: Colors.white,
               ),
               page: const BookingUserList()),
           tile(
               "Meta",
               const Icon(
                 FontAwesomeIcons.meta,
                 color: Colors.white,
               ),
               page: const MetaPage()),
         ],
      ),),
    );
  }
}
