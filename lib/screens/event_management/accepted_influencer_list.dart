import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../insta-analytics/controller/phyllo_controller.dart';
import '../insta-analytics/models/retrieve_all_content_items.dart';
import '../insta-analytics/presentation/widgets/creator_view.dart';
import '../insta-analytics/presentation/widgets/search_creator.dart';
import '../organiser/event_management/list_promotion_in_organiser.dart';
import '../organiser/event_management/promoter_page.dart';
import '../organiser/event_management/promotion_detail.dart';
import '../profile/user_profile.dart';
import 'model/promoter_model.dart';

class AcceptedInfluencerList extends StatefulWidget {
  final String eventPromotionId;
  final RetrieveAllContentItems? contentData;


  const AcceptedInfluencerList({required this.eventPromotionId, Key? key, this.contentData})
      : super(key: key);

  @override
  State<AcceptedInfluencerList> createState() => _AcceptedInfluencerListState();
}

class _AcceptedInfluencerListState extends State<AcceptedInfluencerList>
    with SingleTickerProviderStateMixin {
  final PhylloController phylloController = Get.put(PhylloController());

  final homeController = Get.put(HomeController());
  List? promoterList;
  bool isLoading = true;
  DateTime todayDate = DateTime.now();
  late TabController tabController;

  String imageurl = "";
  String userName = "Unknown";
  int followers = 0;
  int followingCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 3, vsync: this);
    fetchPromotorData();
    print("udshfhudfdhjgd ${widget.eventPromotionId}");
    fetchInfluencerData().then((data) {
      if (data != null) {
        setState(() {
            userName = data['userName'];
          followers = data['followers'];
          followingCount = data['followingCount'];
        });
        print('fetchinfluencerdata called');
        initLoadingData();
      }
    });
    super.initState();
    notificationClear();
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

  void initLoadingData() async {
    try {
      phylloController.contentData =
          await PhylloController.retrieveAllContentItems();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error Is This: $e');
    }
  }

  void fetchPromotorData() async {
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('PromotionRequest')
        .where('eventPromotionId', isEqualTo: widget.eventPromotionId)
        .where(Filter.or(
            Filter('status', isEqualTo: 2), Filter('status', isEqualTo: 4)))
        .get();
    promoterList = [];
    for (var element in data.docs) {
      DocumentSnapshot influencerData = await FirebaseFirestore.instance
          .collection('Influencer')
          .doc(element['influencerPromotorId'])
          .get();
      DocumentSnapshot promotionData = await FirebaseFirestore.instance
          .collection('EventPromotion')
          .doc(element['eventPromotionId'])
          .get();
      if (influencerData.data() != null) {
        Map<String, dynamic> ele = element.data() as Map<String, dynamic>;
        ele['id'] = element.id;
        ele['userData'] = influencerData.data();
        ele['promotionData'] = promotionData.data();
        promoterList!.add(ele);
      }
    }
    setState(() {});
  }

  Future<Map?> fetchInfluencerData() async {
    try {
      DocumentSnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection("Influencer")
          .doc(uid())
          .get();

      if (postsSnapshot.exists) {
        Map<String, dynamic>? data =
            postsSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          Map map = {
            'imageurl': data['imageurl'] ?? "",
            'userName': data['instaUserName'] ?? "Unknown",
            "followers": data['followerCount'] ?? 0,
            "followingCount": data['followingCount'] ?? 0
          };
          print("Name: ${map['userName']}");
          print("Followers: ${map['followerCount']}");
          print("followingCount: ${map['followingCount']}");
          return map;
        } else {
          print("Document data is null.");
        }
      } else {
        print("Document A does not exist.");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    return null;
  }

  Widget eventCard(List data, DateTime date,
          {bool isCancelled = false, int index = 0, int isActive = 0}) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                    child: phylloController.creatorProfile?.imageUrl !=null
                    // data[index]['userData']['image'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              fadeInDuration: const Duration(milliseconds: 100),
                              fadeOutDuration:
                                  const Duration(milliseconds: 100),
                              useOldImageOnUrlChange: true,
                              filterQuality: FilterQuality.low,
                              imageUrl: data[index].galleryImages?[0],
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: Get.width / 1.8,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Username : $userName',
                            // data[index]['userData']['companyMame'].toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ).paddingOnly(left: 10, bottom: 6),
                          Text(
                            'Followers : $followers',
                            // "Followers : ${data[index]['userData']['follower'] ?? 0}",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ubuntu(color: Colors.white),
                          ).paddingOnly(left: 10, bottom: 6),
                          Text(
                            'Following Count : $followingCount',
                            // "Followers : ${data[index]['userData']['follower'] ?? 0}",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ubuntu(color: Colors.white),
                          ).paddingOnly(left: 10, bottom: 6),
                          Text(
                            "Post Cost : ${data[index]['userData']['postCost'] ?? 0}",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ubuntu(color: Colors.white),
                          ).paddingOnly(left: 10, bottom: 6),
                          Text(
                            "Reel Cost : ${data[index]['userData']['reelCost'] ?? 0}",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ubuntu(color: Colors.white),
                          ).paddingOnly(left: 10, bottom: 6),
                          Text(
                            "Story Cost : ${data[index]['userData']['storyCost'] ?? 0}",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ubuntu(color: Colors.white),
                          ).paddingOnly(left: 10, bottom: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (data[index]['status'] == 2)
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
                                                          .collection(
                                                              "PromotionRequest")
                                                          .doc(
                                                              data[index]['id'])
                                                          .set(
                                                              {"status": 4},
                                                              SetOptions(
                                                                  merge:
                                                                      true)).whenComplete(
                                                              () async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "EventPromotion")
                                                            .doc(data[index][
                                                                'eventPromotionId'])
                                                            .set(
                                                                {
                                                              "acceptedBy": data[
                                                                              index]
                                                                          [
                                                                          'promotionData']
                                                                      [
                                                                      'acceptedBy'] +
                                                                  1
                                                            },
                                                                SetOptions(
                                                                    merge:
                                                                        true));

                                                        Get.back();
                                                        Fluttertoast.showToast(
                                                                msg:
                                                                    "Active Successfully")
                                                            .whenComplete(() =>
                                                                setState(() {
                                                                  promoterList!
                                                                      .clear();
                                                                  // initCall();
                                                                  fetchPromotorData();
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
                                            fontSize: 34.sp,
                                            color: Colors.white),
                                      ).paddingAll(6.0),
                                    ).marginOnly(left: 5.0),
                            ],
                          ).marginOnly(top: 10.0)
                        ]),
                  ),
                ])),
          )
        ],
      ).paddingAll(30.w);

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
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No Influencer found",
                            // "Promotion Request in Process",
                            style: TextStyle(color: Colors.white, fontSize: 16),
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
                          const int status = 0 ?? 0;
                          DateTime date = todayDate;
                          return GestureDetector(
                            onTap: (){
                              print('check inf detail ${promoterList![index]['userData']}');
                              Get.to(PromoterInfProfile(pr: false, data: promoterList![index]['userData'],));
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
          title: "Request Accepted from Influencers", showLogo: true),
      drawer: drawer(context: context),
      body: eventList(),
    );
  }
}
