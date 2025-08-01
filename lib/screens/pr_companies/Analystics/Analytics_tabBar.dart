import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'myPromotionDetail.dart';

class AnalyticsTabBar extends StatefulWidget {
final String eventId;
final data;
  const AnalyticsTabBar({super.key, required this.eventId,required this.data});

  @override
  State<AnalyticsTabBar> createState() => _CampaignsTabBarState();
}

class _CampaignsTabBarState extends State<AnalyticsTabBar>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setBusinessCategory();
    });
  }

  setBusinessCategory() async {
    controller = TabController(length: 2, vsync: this);
    setState(() {});
  }

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, bool loading, child) {
        if(loading){
          return Center(child: CircularProgressIndicator(color: Colors.orangeAccent,),);
        }
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar:  PreferredSize(
            preferredSize: Size.fromHeight(220.h),
            child: AppBar(
              automaticallyImplyLeading: true,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "PartyOn",
                    style: GoogleFonts.dancingScript(
                      color: Colors.red,
                      fontSize: 70.sp,
                    ),
                  ),
                ],
              ),
              bottom: TabBar(
                controller: controller,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: "My Promotion"),
                  // Tab(text: "Influencer"),
                  Tab(text: "Total"),
                ],
              ),
              backgroundColor: Colors.black,
              shadowColor: Colors.grey,
            ),
          ),
          body:  DefaultTabController(
            length:  2,
            child: TabBarView(
              controller: controller,
              children: [
                MyPromotionDetail(eventId: widget.eventId,eventData:widget.data),
                // Container(),
                Container(),
              ],
            ),
          ),
        );
      },

    );
  }
}