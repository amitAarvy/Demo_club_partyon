import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_const.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/search/search_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchClub extends StatefulWidget {
  const SearchClub({Key? key}) : super(key: key);

  @override
  State<SearchClub> createState() => _SearchClubState();
}

class _SearchClubState extends State<SearchClub> {
  String query = "";
  String _radioVal = "clubName";
  int _radioSelected = 1;
  final TextEditingController _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Search Club"),
      backgroundColor: matte(),
      body: Column(
        children: [
          SizedBox(
            height: 50.h,
          ),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.0)),
            ),
            onChanged: (val) {
              if (val == "") {
                Provider.of<SearchController>(context, listen: false)
                    .updateSearch(val);
              }
            },
            controller: _search,
          ).paddingSymmetric(horizontal: AppConst.defaultHorizontalPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio(
                value: 1,
                groupValue: _radioSelected,
                fillColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.orange),
                focusColor: Colors.white,
                onChanged: (value) {
                  setState(() {
                    _radioSelected = int.parse(value.toString());
                    _radioVal = 'clubName';
                  });
                },
              ),
              Text(
                'Name',
                style: GoogleFonts.ubuntu(color: Colors.white),
              ),
              Radio(
                value: 2,
                groupValue: _radioSelected,
                activeColor: Colors.blue,
                fillColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.orange),
                focusColor: Colors.white,
                onChanged: (value) {
                  setState(() {
                    _radioSelected = int.parse(value.toString());
                    _radioVal = 'city';
                  });
                },
              ),
              Text(
                'City',
                style: GoogleFonts.ubuntu(color: Colors.white),
              ),
              Radio(
                value: 3,
                groupValue: _radioSelected,
                fillColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.orange),
                focusColor: Colors.white,
                onChanged: (value) {
                  setState(() {
                    _radioSelected = int.parse(value.toString());
                    _radioVal = 'state';
                  });
                },
              ),
              Text(
                'State',
                style: GoogleFonts.ubuntu(color: Colors.white),
              ),
            ],
          ),
          SizedBox(
            height: 100.h,
          ),
          ElevatedButton(
              onPressed: () {
                Provider.of<SearchController>(context, listen: false)
                    .updateSearch(_search.text);
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.orange)),
              child: const Text("Search")),
          SizedBox(
            height: 100.h,
          ),
          Consumer<SearchController>(builder: (context, searchData, child) {
            return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection("Club").get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Column(children: [
                      SizedBox(
                        height: 200.h,
                      ),
                      Center(
                        child: Text(
                          "Something went wrong.",
                          style:
                              TextStyle(color: Colors.white, fontSize: 70.sp),
                        ),
                      )
                    ]);
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(children: [
                      SizedBox(
                        height: 200.h,
                      ),
                      Center(
                        child: Text(
                          "Loading...",
                          style:
                              TextStyle(color: Colors.white, fontSize: 70.sp),
                        ),
                      )
                    ]);
                  }
                  if (searchData.search == "") {
                    return Text(
                      "Search Club",
                      style: TextStyle(color: Colors.white, fontSize: 60.sp),
                    );
                  } else if (snapshot.data!.docs
                      .where((QueryDocumentSnapshot<Object?> element) =>
                          element[_radioVal]
                              .toString()
                              .toLowerCase()
                              .contains(searchData.search.toLowerCase()))
                      .isEmpty) {
                    return const Text(
                      "No Club found",
                      style: TextStyle(color: Colors.white),
                    );
                  } else {
                    return Expanded(
                        child: ListView(
                      shrinkWrap: true,
                      children: [
                        ...snapshot.data!.docs
                            .where((QueryDocumentSnapshot<Object?> element) =>
                                element[_radioVal]
                                    .toString()
                                    .toLowerCase()
                                    .contains(searchData.search.toLowerCase()))
                            .map((QueryDocumentSnapshot<Object?> data) {
                          return GestureDetector(
                            onTap: () => Get.to(SearchDetails(
                                data["clubName"], data["clubUID"])),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          data["clubName"],
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        SizedBox(
                                          height: 50.h,
                                        ),
                                        Text(
                                          data["city"],
                                          style: GoogleFonts.ubuntu(
                                            color: Colors.white70,
                                            fontSize: 35.sp,
                                          ),
                                        ).paddingOnly(right: 30.w),
                                        SizedBox(
                                          height: 50.h,
                                        ),
                                        Text(
                                          data["state"],
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
                                left: 20.w,
                                right: 20.w,
                                top: 30.w,
                                bottom: 30.w),
                          );
                        })
                      ],
                    ));
                  }
                });
          }),
        ],
      ),
    );
  }
}


class SearchController extends ChangeNotifier {
  var search = "";

  updateSearch(String val) {
    search = val;
    notifyListeners();
  }
}
