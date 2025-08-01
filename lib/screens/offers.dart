import 'package:club/utils/app_utils.dart';
import 'package:club/utils/provider_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Offers extends StatefulWidget {
  const Offers({Key? key}) : super(key: key);

  @override
  State<Offers> createState() => _OffersState();
}

class _OffersState extends State<Offers> {
  @override
  Widget build(BuildContext context) {
    Widget eventList() => Container(
          height: 300.h,
          width: Get.width,
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              SizedBox(
                height: 270.h,
                width: 350.w,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      "assets/featEvent.png",
                      fit: BoxFit.fill,
                    )),
              ).paddingSymmetric(horizontal: 15.w, vertical: 5.w),
              Container(
                height: 270.h,
                width: 450.w,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Event Name",
                      style: GoogleFonts.lato(color: Colors.white),
                    ),
                    Text(
                      "Event Date",
                      style: GoogleFonts.lato(color: Colors.white),
                    ),
                    Text(
                      "Event Time",
                      style: GoogleFonts.lato(color: Colors.white),
                    )
                  ],
                ),
              ).paddingSymmetric(horizontal: 15.w, vertical: 5.w),
              Container(
                height: 270.h,
                width: 100.w,
                alignment: Alignment.centerRight,
                child: Checkbox(
                  fillColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.orange),
                  value: true,
                  onChanged: (bool? value) {},
                ),
              ).paddingSymmetric(horizontal: 15.w, vertical: 5.w),
            ],
          ),
        );
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: matte(),
          appBar: appBar(context, title: "Offers & Promotions", isOffers: true),
          body: TabBarView(
            children: [
              Stack(
                children: [
                  ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return eventList()
                            .paddingSymmetric(horizontal: 30.w, vertical: 20.h);
                      }),
                  Consumer<AnimationProvider>(
                    builder: (context, data, child) {
                      return Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTapDown: (_) => data.changeFloating(true),
                            onTapUp: (_) => data.changeFloating(false),
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height:
                                    data.floatingButton == true ? 175.h : 150.h,
                                width:
                                    data.floatingButton == true ? 175.h : 150.h,
                                decoration: BoxDecoration(
                                    color: data.floatingButton == false
                                        ? Colors.deepPurple
                                        : Colors.purple,
                                    shape: BoxShape.circle),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                )),
                          )).paddingAll(30.w);
                    },
                  )
                ],
              ),
              Container()
            ],
          )),
    );
  }
}
