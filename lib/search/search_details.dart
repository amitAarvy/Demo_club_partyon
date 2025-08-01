import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/search/search_club_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchDetails extends StatefulWidget {
  final String title, uid;

  const SearchDetails(this.title, this.uid, {Key? key}) : super(key: key);

  @override
  State<SearchDetails> createState() => _SearchDetailsState();
}

class _SearchDetailsState extends State<SearchDetails> {
  List clubs = [];

  void getData() async {
    await FirebaseFirestore.instance.collection("Club").get().then((value) {
      setState(() {
        clubs = [...value.docs];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: matte(),
      appBar: appBar(context, title: "Search List"),
      body: Column(
        children: [
          SizedBox(
            height: 100.h,
          ),
          FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection("Club").get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                      child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                    ),
                  ));
                }
                if (snapshot.data?.docs.isEmpty == true) {
                  return Expanded(
                      child: Center(
                          child: Text("No clubs found",
                              style: GoogleFonts.ubuntu(fontSize: 60.sp))));
                }
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data?.docs[index];
                      return GestureDetector(
                        onTap: () => Get.to(
                            SearchClubDetails(widget.uid, data?["clubName"])),
                        child: Container(
                          height: 350.h,
                          width: Get.width - 100.w,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 1.h),
                                    spreadRadius: 5.h,
                                    blurRadius: 20.h,
                                    color: Colors.deepPurple)
                              ],
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 250.h,
                                width: 250.h,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      "assets/newLogo.png",
                                      fit: BoxFit.fill,
                                    )),
                              ),
                              SizedBox(
                                width: 50.w,
                              ),
                              SizedBox(
                                width: Get.width - 400.h,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      data?["clubName"],
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Text(
                                      data?["city"],
                                      style: GoogleFonts.ubuntu(
                                        color: Colors.white70,
                                        fontSize: 35.sp,
                                      ),
                                    ).paddingOnly(right: 30.w),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Text(
                                      data?["state"],
                                      style: GoogleFonts.ubuntu(
                                        color: Colors.white70,
                                        fontSize: 35.sp,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ).marginOnly(left: 40.w),
                        ).marginOnly(
                            left: 20.w, right: 20.w, top: 30.w, bottom: 30.w),
                      );
                    });
              })
        ],
      ),
    );
  }
}
