import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/bookings/booking_details.dart';
import 'package:club/screens/event_management/promotion_list.dart';
import 'package:club/screens/event_management/venue_promotion_create.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/bookings/booking_list.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:club/utils/qr_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:club/dynamic_link/dynamic_link.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../organiser/event_management/list_promotion_in_organiser.dart';
import '../organiser/event_management/promoter_page.dart';
import '../organiser/event_management/promotion_detail.dart';
import '../profile/user_profile.dart';
import 'model/promoter_model.dart';

class AcceptedPromoterList extends StatefulWidget {
  final String eventPromotionId;

  const AcceptedPromoterList({required this.eventPromotionId, Key? key})
      : super(key: key);

  @override
  State<AcceptedPromoterList> createState() => _AcceptedPromoterListState();
}

class _AcceptedPromoterListState extends State<AcceptedPromoterList>
    with SingleTickerProviderStateMixin {
  final homeController = Get.put(HomeController());
  List? promoterList;
  bool isLoading = true;
  DateTime todayDate = DateTime.now();
  late TabController tabController;

  String imageurl = "";

  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 3, vsync: this);
    // initCall();
    fetchInfluencerData();
    print("udshfhudfdhjgd ${widget.eventPromotionId}");
    super.initState();
    notificationClear();
  }

  void fetchInfluencerData()async{
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('PromotionRequest')
        .where('eventPromotionId', isEqualTo: widget.eventPromotionId)
        .where(Filter.or(Filter('status', isEqualTo: 2), Filter('status', isEqualTo: 4)))
        .get();
    promoterList = [];
    for(var element in data.docs){
      DocumentSnapshot promotorData = await FirebaseFirestore.instance
          .collection('Organiser')
          .doc(element['influencerPromotorId'])
          .get();
      DocumentSnapshot promotionData = await FirebaseFirestore.instance
          .collection('EventPromotion')
          .doc(element['eventPromotionId'])
          .get();
      // DocumentSnapshot organiserDetail = await FirebaseFirestore.instance
      //     .collection('EventPromotion')
      //     .doc(element['eventPromotionId'])
      //     .get();
      if(promotorData.data() != null){
          Map<String, dynamic> ele = element.data() as Map<String, dynamic>;
          print('check id Is ${promotorData.data()}');
          ele['id'] = element.id;
          ele['userData'] = promotorData.data();
          ele['promotionData'] = promotionData.data();
          promoterList!.add(ele);
      }
    }
    // promoterList = data.docs;
    setState(() {});
  }

  void notificationClear()async{
    final querySnapshot = await FirebaseFirestore.instance.collection('PromotionRequest')
        .where('eventPromotionId', isEqualTo: widget.eventPromotionId)
        .get();
    List data = querySnapshot.docs.where((e)=>e.data().containsKey('notification') ==true).toList();
    for (var doc in data) {
      await doc.reference.update({'notification': false});
    }
  }

  // void initCall() async {
  //   final getData = FirebaseFirestore.instance
  //       .collection('EventPromotionDetail')
  //       .where('eventPromotionId',isEqualTo: widget.eventPromotionId)
  //       .where('status', isGreaterThanOrEqualTo: 2)
  //       .orderBy('status',descending: true)
  //       .get();
  //   final data = await getData;
  //   for (var element in data.docs) {
  //
  //     // DateTime eventDate = element['startTime'].toDate();
  //
  //     print("udshfhudfdhjgd ${element['promoterId']}");
  //     FirebaseFirestore.instance
  //         .collection("Organiser")
  //         .doc(element['promoterId'])
  //         .get()
  //         .then((doc) async {
  //       if (doc.exists) {
  //         // categoryName.add(doc.docs[i]["title"].toString());
  //         // doc.docs.first.id
  //         setState(() {
  //           promoterList.add(new PromoterModel(
  //               eventPromotionId: element['eventPromotionId'],
  //               promoterId: element['promoterId'],
  //               eventPromotionDetailId: element.id.toString(),
  //               status: element['status'].toString(),
  //               name: getKeyValueFirestore(doc, 'instaUserName') ?? '',
  //               follower: getKeyValueFirestore(doc, 'follower') ?? '',
  //               company: getKeyValueFirestore(doc, 'companyMame') ?? '',
  //               galleryImages:
  //                   getKeyValueFirestore(doc, 'profileImages') ?? []));
  //           // promoterList.add(new PromoterModel(eventPromotionId: element['eventPromotionId'],promoterId: element['promoterId']",eventPromotionDetailId: "element.id.toString()",status: "element['status'].toString()",name: "getKeyValueFirestore(doc, 'instaUserName') ?? ''",follower: "getKeyValueFirestore(doc, 'follower') ?? ''",company: "getKeyValueFirestore(doc, 'companyMame') ?? ''"));
  //
  //           print(
  //               "udshfhudfdhjgd ${getKeyValueFirestore(doc, 'profileImages') ?? []}");
  //         });
  //       }
  //     });
  //
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  Widget eventCard(List data, DateTime date,
          {bool isCancelled = false, int index = 0, int isActive = 0}){
    print('promoter detail is ${data}');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black,
              ),
              width: Get.width,
              child: Row(children: [
                Container(
                  height: 400.h,
                  width: Get.width / 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  child: data[index]['userData']['profile_image'] != null && data[index]['userData']['profile_image'].isNotEmpty
                      ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        fadeInDuration: const Duration(milliseconds: 100),
                        fadeOutDuration:
                        const Duration(milliseconds: 100),
                        useOldImageOnUrlChange: true,
                        filterQuality: FilterQuality.low,
                        imageUrl: data[index]['userData']['profile_image'],
                        placeholder: (context, url) =>
                            SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator()),
                      ))
                      : const Text(
                    "No Image Available",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.black),
                  ).paddingOnly(left: 10),
                ),
                SizedBox(
                  width: Get.width / 1.8,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data[index]['userData']['name'] ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ).paddingOnly(left: 10),
                        Text(
                          data[index]['userData']['companyMame'] ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ubuntu(color: Colors.white),
                        ).paddingOnly(left: 10),
                        // Text(
                        //   "Rating : 0022",
                        //   maxLines: 3,
                        //   overflow: TextOverflow.ellipsis,
                        //   style: GoogleFonts.ubuntu(color: Colors.white),
                        // ).paddingOnly(left: 10),
                        if(data[index]['userData']['instaUserName'] != null && data[index]['userData']['instaUserName'] != '')
                        Text(
                          "Insta Username : ${data[index]['userData']['instaUserName'] ?? ''}",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ubuntu(color: Colors.white),
                        ).paddingOnly(left: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if(data[index]['status'] == 2)
                              GestureDetector(
                                  onTap: () => Get.defaultDialog(
                                      title: "Please Confirm",
                                      content: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              IconButton(
                                                  onPressed: () {

                                                    FirebaseFirestore.instance
                                                        .collection("PromotionRequest")
                                                        .doc(data[index]['id'])
                                                        .set({

                                                      "status": 4
                                                    },
                                                        SetOptions(merge: true)).whenComplete(
                                                            () async{
                                                          await FirebaseFirestore.instance
                                                              .collection("EventPromotion")
                                                              .doc(data[index]['eventPromotionId'])
                                                              .set({"acceptedBy": data[index]['promotionData']['acceptedBy'] + 1},
                                                              SetOptions(merge: true));
                                                          Get.back();
                                                          Fluttertoast.showToast(
                                                              msg:
                                                              "Active Successfully")
                                                              .whenComplete(() =>

                                                              setState(
                                                                      () {
                                                                    promoterList!.clear();
                                                                    // initCall();
                                                                    fetchInfluencerData();
                                                                  }));

                                                        });
                                                  },
                                                  icon: const Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                  )),
                                              const Text("Yes"),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                  )),
                                              const Text("No"),
                                            ],
                                          )
                                        ],
                                      )),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Accept',
                                      style: GoogleFonts.ubuntu(
                                          fontSize: 30.sp,
                                          color: Colors.white),
                                    ).paddingAll(10.0),
                                  )).marginOnly(left: 10.0)
                            else
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.blue,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Accepted',
                                  style: GoogleFonts.ubuntu(
                                      fontSize: 40.sp, color: Colors.white),
                                ).paddingAll(5.0),
                              ).marginOnly(left: 5.0),
                          ],
                        ).marginOnly(top: 10.0)
                      ]),
                ),
              ])),
        )
      ],
    ).paddingAll(30.w);
  }


  Widget eventList({bool isUpcoming = false, bool isCurrent = false}) =>
      promoterList == null
          ? SizedBox(
              height: Get.height - 500.h,
              width: Get.width,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  if ((isUpcoming
                          ? promoterList!.length
                          : isCurrent
                              ? promoterList!.length
                              : promoterList!.length) ==
                      0)
                    SizedBox(
                      height: Get.height - 500.h,
                      width: Get.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No Promotors found",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                        itemCount: isUpcoming
                            ? promoterList!.length
                            : isCurrent
                                ? promoterList!.length
                                : promoterList!.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          // try {
                            // var data = isUpcoming
                            //     ? promoterList[index]
                            //     : isCurrent
                            //         ? promoterList[index]
                            //         : promoterList[index];
                            // final bool isActive = data?['isActive'] ?? false;
                            final int status = 0 ?? 0;
                            DateTime date = todayDate;
                            return GestureDetector(
                              onTap: (){
                                Get.to(PromoterInfProfile(pr: true, id: promoterList![index]['userData']['uid'],));
                              },
                              child: eventCard(promoterList!, date,
                                  index: index,
                                  isCancelled: false,
                                  isActive: status),
                            );
                          // } catch (e) {
                          //   return Container();
                          // }
                        }).paddingOnly(top: 50.h),
                ],
              ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(context,
            title: "Request Accepted from Promoters", showLogo: true),
        drawer: drawer(context: context),
        body: eventList());
  }
}
