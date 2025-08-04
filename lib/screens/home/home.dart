import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/model/list_anaylsis_tabs.dart';
import 'package:club/screens/event_management/offers_and_promotions.dart';
import 'package:club/screens/event_management/promotion_event_list.dart';
import 'package:club/screens/home/add_club.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:club/screens/event_management/menu_create.dart';
import 'package:club/screens/purchase_plan/purchase_plan.dart';

import '../../search/search_artist.dart';
import '../../utils/image_uplod.dart';
import '../event_management/event_list.dart';
import '../event_management/pendingEventList.dart';
import '../marketing/marketing_page.dart';
import '../refer/presentation/views/referal_earning.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ClubHome extends StatefulWidget {
  const ClubHome({Key? key}) : super(key: key);

  @override
  State<ClubHome> createState() => _ClubHomeState();
}

class _ClubHomeState extends State<ClubHome> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final homeController = Get.put(HomeController());
  int favCount = 0;
  int pendingRequest = 0;
  String? businessCategory;

  @override
  void initState() {
    super.initState();
    init();
  }

  init()async{
    isLoading.value = true;
    await Future.wait([
    getCurrentClub(),
    setBusinessCatPref(),
    getFavCount(),
    // checkPendingRequest(),
    // fetchPlan(),
    // fetchOfferPromotionList(),
    ]);
    isLoading.value= false;
  }

  Future setBusinessCatPref() async {
    QuerySnapshot businessData = await FirebaseFirestore.instance
        .collection("Club")
        .where("clubUID", isEqualTo: uid())
        .get();
    if (businessData.docs.isNotEmpty) {
      await const FlutterSecureStorage().write(
          key: "clubUids",
          value:
              "${(businessData.docs[0].data() as Map<String, dynamic>)['clubUID'] ?? 1}");
      await const FlutterSecureStorage().write(
          key: "businessCategory",
          value:
              "${(businessData.docs[0].data() as Map<String, dynamic>)['businessCategory'] ?? 1}");
    } else {
      await const FlutterSecureStorage()
          .write(key: "businessCategory", value: "1");
    }
    businessCategory =
        await const FlutterSecureStorage().read(key: "businessCategory");
    setState(() {});
  }

  Future getFavCount() async {
    await FirebaseFirestore.instance
        .collection("Favorites")
        .doc(uid())
        .get()
        .then((value) {
      if (value.exists) {
        var data = value.data();
        List favList = data?["favorites"];

        setState(() {
          favCount = favList.length;
        });
      }
    });
  }


  // Future checkPendingRequest()async{
  //   QuerySnapshot data = await  FirebaseFirestore.instance
  //       .collection("Events")
  //       .where('clubUID',
  //       isEqualTo: uid())
  //       .orderBy('date', descending: true)
  //       .get();
  //
  //   // QuerySnapshot data1 = await   FirebaseFirestore.instance
  //   //     .collection("Events")
  //   //     .where('clubUID',
  //   //     isEqualTo: uid())
  //   //     .orderBy('date', descending: true)
  //   //     .get();
  //
  //   List pendingData = data.docs.where((e)=>e['status'].toString()=='P').toList();
  //     print('pending list is ${data.docs}');
  //     print('pending list is ${pendingData.length}');
  //       setState(() {
  //         pendingRequest = pendingData.length;
  //       });
  // }



  // List eventPromotionList = [];

  // Future fetchOfferPromotionList()async{
  //   QuerySnapshot data=  await FirebaseFirestore.instance
  //       .collection('EventPromotion')
  //       .where('clubUID', isEqualTo: uid())
  //       // .where('isOrganiser',isNotEqualTo:'Organiser')
  //       .get();
  //   eventPromotionList = data.docs;
  //   setState(() {
  //   });
  //   print('event promotion lsit is ${eventPromotionList}');
  // }

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
        key: _key,
        backgroundColor: matte(),
        appBar: appBar(context,
            title: "Home", showLogo: true, key: _key, showBack: false),
        drawer: drawer(context: context),
        body: ValueListenableBuilder(
          valueListenable: isLoading,
          builder: (context, bool loading, child) {
            if(loading){
              return Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
            return Stack(
              children: [
                Opacity(
                    opacity: 0.2,
                    child: SizedBox(
                      height: Get.height,
                      width: Get.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/newLogo.png"),
                          SizedBox(
                            height: 200.h,
                          ),
                        ],
                      ),
                    )),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if(pendingRequest != 0)
                          InkWell(
                            onTap: (){
                              Get.to(PendingEventList(
                                isPendingRequest: true,
                              ));
                            },
                            child: Row(children: [
                              const Icon(
                                Icons.pending,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 30.w,
                              ),
                              Text(
                                "$pendingRequest",
                                style: GoogleFonts.ubuntu(
                                    color: Colors.white, fontSize: 50.sp),
                              ),
                              SizedBox(width: 30,),

                            ],),),

                        const Icon(
                          FontAwesomeIcons.solidHeart,
                          color: Colors.pink,
                        ),
                        SizedBox(
                          width: 30.w,
                        ),
                        Text(
                          "$favCount",
                          style: GoogleFonts.ubuntu(
                              color: Colors.white, fontSize: 50.sp),
                        )
                      ],
                    ).paddingSymmetric(horizontal: 50.w,vertical: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (businessCategory == "1")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              tile(
                                "Events \n Management",
                                const Icon(
                                  FontAwesomeIcons.calendar,
                                  color: Colors.white,
                                ),
                                isEVM: true,
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('Bookings').where('clubUID',isEqualTo: uid()).where('newNotification',isEqualTo: true).snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  int notificationCount = 0;
                                  if (snapshot.hasError) {
                                    notificationCount = 0;
                                    // return Center(child: Text('Error: ${snapshot.error}'));
                                  }
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    notificationCount = 0;
                                    // return Center(child: CircularProgressIndicator());
                                  }
                                  notificationCount= snapshot.data==null?0:snapshot.data!.docs.length;
                                  return tile(
                                    "Booking Management",
                                    notificationIcon: snapshot.data==null?[].isNotEmpty:snapshot.data!.docs.isNotEmpty,
                                    eventNotificationCount: notificationCount,
                                    const Icon(
                                      FontAwesomeIcons.calendarCheck,
                                      color: Colors.white,
                                    ),
                                    page: const PromotionEventList(isClub: true),
                                  );
                                },
                              ),

                            ],
                          ),

                        if (businessCategory == "1")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // tile("Search Artist",Icon(FontAwesomeIcons.search,color: Colors.white,),page: SearchArtist()),

                              tile(
                                  "Create Menu",
                                  const Icon(
                                    FontAwesomeIcons.chartBar,
                                    color: Colors.white,
                                  ),
                                  page: const MenuCreate()),
                              // tile(
                              //     "Go Live",
                              //     const Icon(
                              //       FontAwesomeIcons.video,
                              //       color: Colors.white,
                              //     ),
                              //     isLive: true),


                              //void fetchPromotorData() async {
                              //     QuerySnapshot data = await FirebaseFirestore.instance
                              //         .collection('PromotionRequest')
                              //         .where('eventPromotionId', isEqualTo: widget.eventPromotionId)
                              //         .where(Filter.or(
                              //             Filter('status', isEqualTo: 2), Filter('status', isEqualTo: 4)))
                              //         .get();
                              //     promoterList = [];
                              //     for (var element in data.docs) {
                              //       DocumentSnapshot influencerData = await FirebaseFirestore.instance
                              //           .collection('Influencer')
                              //           .doc(element['influencerPromotorId'])
                              //           .get();
                              //       DocumentSnapshot promotionData = await FirebaseFirestore.instance
                              //           .collection('EventPromotion')
                              //           .doc(element['eventPromotionId'])
                              //           .get();
                              //       if (influencerData.data() != null) {
                              //         Map<String, dynamic> ele = element.data() as Map<String, dynamic>;
                              //         ele['id'] = element.id;
                              //         ele['userData'] = influencerData.data();
                              //         ele['promotionData'] = promotionData.data();
                              //         promoterList!.add(ele);
                              //       }
                              //     }
                              //     setState(() {});
                              //   }
                              StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance.collection('PromotionRequest').where('venueId',isEqualTo: uid()).snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    int notificationCount = 0;
                                    if (snapshot.hasError) {
                                      notificationCount = 0;
                                      // return Center(child: Text('Error: ${snapshot.error}'));
                                    }
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      notificationCount = 0;
                                      // return Center(child: CircularProgressIndicator());
                                    }
                                    notificationCount = snapshot.data == null
                                        ? 0
                                        : snapshot.data!.docs
                                        .where((doc) {
                                      var data1 = doc.data() as Map<String, dynamic>;
                                      return data1.containsKey('venueId') &&
                                          data1.containsKey('notification') &&
                                          doc['notification'].toString() == 'true';
                                    })
                                        .toList()
                                        .length;
                                    return tile(
                                      "Offers & \n Promotion",
                                      notificationIcon: notificationCount==0?false:true,
                                      eventNotificationCount: notificationCount,
                                      const Icon(
                                        Icons.add_business_outlined,
                                        color: Colors.white,
                                      ),
                                      page: const OffersAndPromotions(),
                                    );
                                  })

                              // StreamBuilder(
                              //   stream: FirebaseFirestore.instance
                              //       .collection('PromotionRequest')
                              //       .where(
                              //     Filter.or(
                              //       Filter('status', isEqualTo: 2),
                              //       Filter('status', isEqualTo: 4),
                              //     ),
                              //   )
                              //       .snapshots(),
                              //   builder: (context, snapshot) {
                              //     // if (!snapshot.hasData) {
                              //     //   return const CircularProgressIndicator(); // or a placeholder widget
                              //     // }
                              //
                              //     var docs = snapshot.data as QuerySnapshot;
                              //     print('check docs is ${docs}');
                              //
                              //     // List data =[];
                              //     // for (var doc in docs.docs) {
                              //     //   final data = doc.data() as Map<String, dynamic>; // Cast it safely
                              //     //
                              //     //   if (data.containsKey('eventPromotionId')) {
                              //     //     data = doc.
                              //     //     print('eventPromotionId: ${data['eventPromotionId']}');
                              //     //   } else {
                              //     //     print('Missing eventPromotionId in doc: ${doc.id}');
                              //     //   }
                              //     // }
                              //
                              //     List data = docs.docs
                              //         .map((ele) => eventPromotionList
                              //         .where((e) => e.id.toString() == ele['eventPromotionId'].toString())
                              //         .toList())
                              //         .expand((e) => e) // Flatten the list of lists
                              //         .toList();
                              //
                              //     print('check length is ${data.length}');
                              //
                              //     return tile(
                              //       "Offers & \n Promotion",
                              //       const Icon(
                              //         Icons.add_business_outlined,
                              //         color: Colors.white,
                              //       ),
                              //       page: const OffersAndPromotions(),
                              //     );
                              //   },
                              // ),
                            ],
                          ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // tile(
                            //     "Search Artist",
                            //     const Icon(
                            //       Icons.search,
                            //       color: Colors.white,
                            //     ),
                            //     page: const SearchArtistView()),
                            // tile(
                            //     "Pending \nRequests",
                            //     const Icon(
                            //       FontAwesomeIcons.calendar,
                            //       color: Colors.white,
                            //     ),
                            //     page: const EventList(
                            //       isPendingRequest: true,
                            //     )),
                            // tile(
                            //     "Images Upload",
                            //     const Icon(
                            //       FontAwesomeIcons.images,
                            //       color: Colors.white,
                            //     ),
                            //     page: const ImageUpload()),
                          ],
                        ),
                        if (businessCategory != "1")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              tile(
                                  "Offers & \n Promotion",
                                  const Icon(
                                    Icons.add_business_outlined,
                                    color: Colors.white,
                                  ),
                                  page: const OffersAndPromotions()),
                              // tile(
                              //     "Plan's",
                              //     const Icon(
                              //       Icons.next_plan_outlined,
                              //       color: Colors.white,
                              //     ),
                              //     page: const OffersAndPromotions()),
                            ],
                          ),
                        if (businessCategory != "1")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              tile(
                                "Promotional \n Analysis",
                                const Icon(
                                  FontAwesomeIcons.chartBar,
                                  color: Colors.white,
                                ),
                                page: const ListAnalysisTabs(),
                              ),
                            ],
                          ),
                        if (businessCategory == "1")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // tile(
                              //     "Plan",
                              //     const Icon(
                              //       FontAwesomeIcons.solidNoteSticky,
                              //       color: Colors.white,
                              //     ),
                              //     page: const PurchasePlan()),
                              tile(
                                  "Promotional \n Analysis",
                                  const Icon(
                                    FontAwesomeIcons.chartBar,
                                    color: Colors.white,
                                  ),
                                  page: const ListAnalysisTabs()),
                              tile(
                                  "Marketing",
                                  const Icon(
                                    FontAwesomeIcons.mapMarkerAlt,
                                    color: Colors.white,
                                  ),
                                  page: const MarketingPage()),

                              // tile(
                              //   "Refers\n&\nEarnings",
                              //   const Icon(
                              //     FontAwesomeIcons.share,
                              //     color: Colors.white,
                              //   ),
                              //   page: const ReferralEarning(),
                              // ),
                            ],
                          ),
                        // SizedBox(
                        //   height: 200.h,
                        // ),

                      ],
                    )
                  ],

                ),
              ],
            );
          },

        ),
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.only(bottom: 40),
        //   child: IconButton(
        //     onPressed: () {
        //       addClub(context);
        //       // Fluttertoast.showToast(
        //       //     msg:
        //       //         "Your club is currently under review and is not visible to users.");
        //     },
        //     icon: Icon(
        //       Icons.message,
        //       size: 100.sp,
        //       color: Colors.amber,
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
