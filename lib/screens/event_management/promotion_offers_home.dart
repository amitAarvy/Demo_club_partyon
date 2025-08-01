import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/bookings/booking_details.dart';
import 'package:club/screens/event_management/barter_collab.dart';
import 'package:club/screens/event_management/event_influencer_tabs.dart';
import 'package:club/screens/event_management/promotion_list.dart';
import 'package:club/screens/event_management/venue_promotion_create.dart';
import 'package:club/screens/pr_companies/widget/VenueCampaigns.dart';
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

import '../../widgets/plan_message.dart';
import 'create_event_promotion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromotionOfferHome extends StatefulWidget {
  final bool isOrganiser;
  final bool isPromoter;
  final bool isClub;

  const PromotionOfferHome(
      {Key? key,
      this.isOrganiser = false,
      this.isPromoter = false,
      this.isClub = false,})
      : super(key: key);

  @override
  State<PromotionOfferHome> createState() => _PromotionOfferHomeState();
}

class _PromotionOfferHomeState extends State<PromotionOfferHome>
    with SingleTickerProviderStateMixin {
  final homeController = Get.put(HomeController());
  List upcomingList = [];
  List currentList = [];
  List pastList = [];
  bool isLoading = true;
  late TabController tabController;
  int currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 2, vsync: this);
    initCall();
    super.initState();
    fetchPromotional();
    print("uid : ${uid()}");

  }

  void initCall() async {
    print("uid : ${uid()}");
    final getData = widget.isPromoter
        ? FirebaseFirestore.instance
            .collection("Events")
            .where('promoterID', arrayContains: uid())
            .orderBy('date', descending: true)
            .get()
        : widget.isOrganiser
            ? FirebaseFirestore.instance
                .collection("Events")
                .where('organiserID', isEqualTo: uid())
                .orderBy('date', descending: true)
                .get()
            : widget.isClub
                ? FirebaseFirestore.instance
                    .collection("Events")
                    .where('clubUID', isEqualTo: uid())
                    .orderBy('date', descending: true)
                    .get()
                : FirebaseFirestore.instance.collection("Events").get();
    final data = await getData;
    for (var element in data.docs) {
      DateTime eventDate = element['date'].toDate();
      DateTime timeNow = DateTime.now();
      DateTime todayEnd =
          DateTime(timeNow.year, timeNow.month, timeNow.day );
      DateTime todayStart = DateTime(timeNow.year, timeNow.month, timeNow.day);
      setState(() {
        if (eventDate.millisecondsSinceEpoch >=
            todayEnd.millisecondsSinceEpoch) {
          upcomingList.add(element);
        } else if (eventDate.millisecondsSinceEpoch >=
                todayStart.millisecondsSinceEpoch &&
            eventDate.millisecondsSinceEpoch <
                todayEnd.millisecondsSinceEpoch) {
          currentList.add(element);
        } else if (eventDate.millisecondsSinceEpoch <
            todayStart.millisecondsSinceEpoch) {
          pastList.add(element);
        }
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void onTapShareOptions(
      {bool isPromotion = false,
      bool isClub = false,
      QueryDocumentSnapshot? data}) {
    Get.bottomSheet(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                      title: const Text(
                        'Instagram Story',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: const Icon(
                        FontAwesomeIcons.instagram,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        Get.back();
                        await ImagePicker()
                            .pickImage(source: ImageSource.gallery)
                            .then((value) {
                          if (value != null) {
                            if (isPromotion) {
                              onTapSharePromotion(
                                  isInstagramStory: true, imageFile: value);
                            } else if (isClub) {
                              onTapShareBooking(data,
                                  isInstagramStory: true, imageFile: value);
                            }
                          }
                        });
                      }),
                  ListTile(
                      title: const Text(
                        'Others',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: const Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Get.back();
                        isPromotion
                            ? onTapSharePromotion()
                            : onTapShareBooking(data, isClub: true);
                      })
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black);
  }

  void onTapShareBooking(final data,
      {bool isPromoter = false,
      bool isClub = false,
      bool isInstagramStory = false,
      XFile? imageFile}) async {
    EasyLoading.show();
    String url = await FirebaseDynamicLinkEvent.createDynamicLink(
        short: true,
        clubUID: isClub ? uid() : data['clubUID'] ?? '',
        eventID: (data.id).toString(),
        organiserID: isClub ? '' : uid().toString());
    TextEditingController customisedURLText = TextEditingController();
    EasyLoading.dismiss();
    Get.dialog(
        Stack(
          children: [
            Container(
              width: Get.width,
              height: Get.height,
              color: Colors.grey.withOpacity(0.4),
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: matte()),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              FontAwesomeIcons.xmark,
                              color: Colors.white,
                            )),
                      ],
                    ),
                    textField(
                      'Enter text for URL (Optional)',
                      customisedURLText,
                    ),
                    ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.resolveWith(
                                        (states) => Colors.orange)),
                            onPressed: () {
                              Get.back();
                              Clipboard.setData(ClipboardData(text: url));
                              if (isInstagramStory) {
                                if (imageFile != null) {
                                  Share.shareXFiles([imageFile],
                                      text:
                                          "${customisedURLText.text.isNotEmpty ? "${customisedURLText.text} " : ""}$url");
                                }
                              } else {
                                Share.share(
                                    "${customisedURLText.text.isNotEmpty ? "${customisedURLText.text} " : ""}$url");
                              }
                            },
                            child: const Text('Generate URL'))
                        .paddingSymmetric(vertical: 20.h)
                  ],
                ),
              ).paddingSymmetric(horizontal: 50.w),
            ),
          ],
        ),
        barrierColor: Colors.transparent);
  }

  void onTapSharePromotion(
      {bool isInstagramStory = false, XFile? imageFile}) async {
    TextEditingController customisedURLText = TextEditingController();
    Get.dialog(
        Stack(
          children: [
            Container(
              width: Get.width,
              height: Get.height,
              color: Colors.grey.withOpacity(0.4),
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: matte()),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              FontAwesomeIcons.xmark,
                              color: Colors.white,
                            )),
                      ],
                    ),
                    textField('Enter promotion URL', customisedURLText,
                        isInfo: true),
                    ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.resolveWith(
                                        (states) => Colors.orange)),
                            onPressed: () async {
                              final Map<String, String> queryParams =
                                  await FirebaseDynamicLinkEvent
                                      .getParametersFromExistingLink(
                                          customisedURLText.text);
                              if (queryParams.isNotEmpty) {
                                final eventID = queryParams['eventID'] ?? '';
                                final organiserID = queryParams['organiserID'] ?? '';
                                final promoterID = queryParams['promoterID'] ?? '';
                                final clubUID = queryParams['clubUID'] ?? '';
                                if (eventID.isNotEmpty && promoterID.isEmpty) {
                                  if (uid() != organiserID) {
                                    String url = await FirebaseDynamicLinkEvent.createDynamicLink(
                                            short: true, clubUID: clubUID, eventID: eventID,
                                            organiserID: organiserID, promoterID: widget.isPromoter ? uid() ?? '' : '');
                                    print(url);
                                    print(await FirebaseDynamicLinkEvent
                                        .getParametersFromExistingLink(url));
                                    Clipboard.setData(ClipboardData(text: url));
                                    FirebaseFirestore.instance
                                        .collection('Events')
                                        .doc(eventID)
                                        .set({
                                        'promoterID': FieldValue.arrayUnion([uid()])
                                    }, SetOptions(merge: true));
                                    EasyLoading.dismiss();
                                    if (isInstagramStory) {
                                      Share.shareXFiles([imageFile!], text: url);
                                    } else {
                                      Share.share(url);
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'Organiser and promoter cannot be same');
                                  }
                                } else {
                                  Fluttertoast.showToast(msg: 'Invalid promotion URL');
                                }
                              }
                            },
                            child: const Text('Generate URL'))
                        .paddingSymmetric(vertical: 20.h)
                  ],
                ),
              ).paddingSymmetric(horizontal: 50.w),
            ),
          ],
        ),
        barrierColor: Colors.transparent);
  }

  Widget eventCard(QueryDocumentSnapshot data, DateTime date,
          {bool isCancelled = false, int index = 0, bool isActive = false, bool influencerCollab = false,bool isVenue = false}) =>
      GestureDetector(
        onTap: () async {
          var prList = await FirebaseFirestore.instance.collection(
              'EventPromotion').get();
          List promotionList = prList.docs
              .where((element) =>
          element.data()['eventId'].toString() == (data.id).toString(),)
              .toList();
          if (influencerCollab) {
            Get.to(EventInfluencerTabs(eventName: data['title'],
              isOrganiser: widget.isOrganiser,
              eventId: data.id.toString(),));
          } else if (isVenue) {
            Get.to(VenueCampaigns(eventId: (data.id).toString(),
              data: data.data() as Map<String, dynamic>,));
          } else {
            if (promotionList.isNotEmpty) {
              Fluttertoast.showToast(
                  msg: 'Single promotion per event.');
              return;
            }
            Get.to(
                EventPromotionCreate(
                  isOrganiser: widget.isOrganiser,
                  isPromoter: widget.isPromoter,
                  isClub: widget.isClub,
                  eventId: (data.id).toString(),
                  eventData: data.data() as Map<String, dynamic>,
                ));
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.black),
              width: Get.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: Get.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                              child: Center(
                                  child: Text(
                            "${index + 1}",
                            style: GoogleFonts.ubuntu(color: Colors.white),
                          ))),
                        ),
                        Expanded(
                          child: SizedBox(
                              child: Center(
                                  child: Text(
                            data["title"].toString().capitalizeFirstOfEach,
                            style: GoogleFonts.ubuntu(color: Colors.white),
                          ))),
                        ),
                        Expanded(
                          child: SizedBox(
                              child: Center(
                                  child: Text(
                            "${date.day}-${date.month}-${date.year}",
                            style: GoogleFonts.ubuntu(color: Colors.white),
                          ))),
                        ),
                        if (widget.isOrganiser || widget.isClub)
                          Expanded(
                            child: Center(
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.share,
                                  color: Colors.white,
                                  size: 60.h,
                                ),
                                onPressed: () async => isActive
                                    ? onTapShareOptions(
                                        data: data, isClub: true)
                                    : Fluttertoast.showToast(
                                        msg: 'Event is not active yet'),
                              ),
                            ),
                          ),
                      ],
                    ).paddingSymmetric(vertical: 60.h),
                  ),
                  if (isCancelled)
                    Row(
                      children: [
                        Text(
                          'Cancelled',
                          style: GoogleFonts.ubuntu(
                              color: Colors.red, fontSize: 40.sp),
                        )
                      ],
                    )
                ],
              ),
            ),
          ],
        ),
      ).paddingAll(30.w);

  Widget eventList({bool isUpcoming = false, bool isCurrent = false, bool influencerCollab = false,bool isVenue= false}) =>
      isLoading
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
                  const SizedBox(height: 10),
                  if ((isUpcoming
                          ? upcomingList.length
                          : isCurrent
                              ? currentList.length
                              : pastList.length) ==
                      0)
                    SizedBox(
                      height: Get.height - 500.h,
                      width: Get.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No events found",
                            style:
                                TextStyle(color: Colors.white, fontSize: 70.sp),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "List of Upcoming Events",
                          style:
                          TextStyle(color: Colors.white, fontSize: 70.sp),
                        ),
                      ],
                    ),
                    ListView.builder(
                        itemCount: isUpcoming
                            ? upcomingList.length
                            : isCurrent
                                ? currentList.length
                                : pastList.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          try {
                            var data = isUpcoming
                                ? upcomingList[index]
                                : isCurrent
                                    ? currentList[index]
                                    : pastList[index];
                            final bool isActive = data?['isActive'] ?? false;
                            final bool isCancelled = data?['status'] == 'C';
                            DateTime date = data?["date"].toDate();
                            return eventCard(data!, date,
                                index: index,
                                isVenue: isVenue,
                                isCancelled: isCancelled,
                                isActive: isActive, influencerCollab: influencerCollab);
                          } catch (e) {
                            return Container();
                          }
                        }).paddingOnly(top: 50.h),
                ],
              ));


  fetchPromotional()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    QuerySnapshot promoterList = await   FirebaseFirestore.instance
        .collection('EventPromotion')
        .where('collabType', isEqualTo: 'promotor')
        .where(widget.isOrganiser ==true?'organiserId':'clubUID', isEqualTo: uid())
        .get();
    QuerySnapshot infList = await   FirebaseFirestore.instance
        .collection('EventPromotion')
        .where('collabType', isEqualTo: 'influencer')
        .where(widget.isOrganiser ==true?'organiserId':'clubUID', isEqualTo: uid())
        .get();
    // print('check to entry is ${promoterList.docs.length}');
    // print('check to entry is ${infList.docs.length}');

    String planData = pref.getString('planData') ?? '{}';
    if(planData =='{}'){
      // checkPromoter.value = false;
      checkPromoter.value = true;
      checkInf.value = true;
    }else{
      print('check to entry is ${planData}');
      Map<String, dynamic> jsonConvert = jsonDecode(planData);
      List PromoterListPlan = promoterList.docs
          .where((e) {
        var data = e.data() as Map<String, dynamic>?;  // Safely cast to Map<String, dynamic>
        return data != null && data.containsKey('planId') && jsonConvert['planId'].toString() == data['planId'].toString();
      })
          .toList();

      List PromoterListInf = infList.docs
          .where((e) {
        var data = e.data() as Map<String, dynamic>?;
        return data != null && data.containsKey('planId') && jsonConvert['planId'].toString() == data['planId'].toString();
      })
          .toList();
      checkPromoter.value = int.parse(jsonConvert['promotionPRSend']['noOfPrSend'].toString()) <= PromoterListPlan.length?true:false;
      checkInf.value = int.parse(jsonConvert['promotionInfSend']['noOfInfSend'].toString()) <= PromoterListInf.length?true:false;
    }

  }
  ValueNotifier<bool> checkPromoter = ValueNotifier(false);
  ValueNotifier<bool> checkInf = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(context: context),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = 3;
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: currentIndex == 3 ? Colors.yellow.withOpacity(0.4) : Colors.transparent,
                        ),
                        child: const Text("My Promotion", style: TextStyle(color: Colors.white),)),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = 0;
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: currentIndex == 0 ? Colors.yellow.withOpacity(0.4) : Colors.transparent,
                        ),
                        child: const Text("Promoter Collab's", style: TextStyle(color: Colors.white),)),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     setState(() {
                  //       currentIndex = 1;
                  //     });
                  //   },
                  //   child: Container(
                  //       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(100),
                  //         color: currentIndex == 1 ? Colors.yellow.withOpacity(0.4) : Colors.transparent,
                  //       ),
                  //       child: const Text("Influencer Collab's", style: TextStyle(color: Colors.white),)),
                  // ),
                ],
              ),
            ),
          ),
          if(currentIndex == 0)
          ValueListenableBuilder(
            valueListenable: checkPromoter,
            builder: (context, bool isPromoter, child) {
              // if(isPromoter){
              //   return Column(
              //     children: [
              //       SizedBox(height: 50,),
              //       planMessage(),
              //     ],
              //   );
              // }
              return  Expanded(
                key: ValueKey(currentIndex),
                child: eventList(isUpcoming: true,),
              );
            },

          ),
          // if(currentIndex == 1)
          // ValueListenableBuilder(
          // valueListenable: checkInf,
          //     builder: (context, bool isInf, child) {
          //     if(isInf){
          //     return Column(
          //       children: [
          //         SizedBox(height: 50,),
          //         planMessage(),
          //       ],
          //     );
          //     }
          //     return Expanded(
          //       key: ValueKey(currentIndex),
          //       child: eventList(isUpcoming: true, influencerCollab: true),
          //     );
          //     }
          //
          // ),

          if(currentIndex == 3)
            ValueListenableBuilder(
                valueListenable: checkInf,
                builder: (context, bool isInf, child) {
                  // if(isInf){
                  //   return Column(
                  //     children: [
                  //       SizedBox(height: 50,),
                  //       planMessage(),
                  //     ],
                  //   );
                  // }
                  return Expanded(
                    key: ValueKey(currentIndex),
                    child: eventList(isUpcoming: true, isVenue: true),
                  );
                }

            ),
          // const Expanded(child: EventInfluencerTabs())
        ],
      ),
      // floatingActionButton: widget.isPromoter
      //     ? SizedBox(
      //         width: 350.w,
      //         child: FloatingActionButton(
      //           backgroundColor: Colors.orange,
      //           shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(15)),
      //           child: const Text('Promoter Link'),
      //           onPressed: () => onTapShareOptions(isPromotion: true),
      //         ))
      //     : widget.isClub
      //         ? FloatingActionButton(
      //             onPressed: () async {
      //               // final homeController = Get.put(HomeController());
      //               final scanResult = await barCodeScannerResult();
      //               List<String> scanResultData = scanResult.split('|');
      //               final bookingId = scanResultData[0];
      //               final clubUID = scanResultData[1];
      //               //final clubId = scanResultData[2];
      //               if (scanResult.isNotEmpty && scanResult != '-1') {
      //                 if (clubUID == uid()) {
      //                   Get.to(BookingDetails(bookingID: bookingId));
      //                 } else {
      //                   Fluttertoast.showToast(
      //                       msg: 'Booking is not made for this place');
      //                 }
      //               } else {
      //                 Fluttertoast.showToast(msg: 'Booking Id not found');
      //               }
      //             },
      //             backgroundColor: Colors.red,
      //             child: const Icon(Icons.document_scanner_outlined),
      //           )
      //         : const SizedBox(),
    );
  }
}
