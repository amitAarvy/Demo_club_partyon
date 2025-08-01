import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/coupon_code/model/data/coupon_code_model.dart';
import 'package:club/screens/coupon_code/view/presentation/widget/couple_share_bottomsheet.dart';
import 'package:club/screens/coupon_code/view/presentation/widget/event_coupon_code_view.dart';
import 'package:club/screens/coupon_code/view/presentation/widget/saved_coupons.dart';
import 'package:club/screens/event_management/event_influencer_tabs.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
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

class SharedCouponEventList extends StatefulWidget {
  final bool isOrganiser;
  final bool isPromoter;
  final bool isClub;
  final String? eventId;

  const SharedCouponEventList({
    Key? key,
    this.isOrganiser = false,
    this.isPromoter = false,
    this.isClub = false, this.eventId,
  }) : super(key: key);

  @override
  State<SharedCouponEventList> createState() => _SharedCouponEventList();
}

class _SharedCouponEventList extends State<SharedCouponEventList>
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
    initCall();
    super.initState();
    print('yes check coupon detail ${uid()}');
    getCouponDetails();
  }

  void initCall() async {
    upcomingList.clear();
    pastList.clear();
    currentList.clear();
    var getData = widget.isPromoter
        ? await FirebaseFirestore.instance
            .collection("Events")
            .where('promoterID', arrayContains: uid())
            .orderBy('date', descending: true)
            .get()
        : widget.isOrganiser
            ? await FirebaseFirestore.instance
                .collection("Events")
                .where('organiserID', isEqualTo: uid())
                .orderBy('date', descending: true)
                .get()
            : widget.isClub
                ? await FirebaseFirestore.instance
                    .collection("Events")
                    .where('clubUID', isEqualTo: uid())
                    .orderBy('date', descending: true)
                    .get()
                :await FirebaseFirestore.instance.collection("Events").get();
    var data =  getData.docs;
    if (widget.eventId != null) {
      print('Check: event ID is present');
      data = data.where((e) => e.id == widget.eventId).toList();
    }

    print('check event list is ${data}');
    for (var element in data) {
      DateTime eventDate = element['date'].toDate();
      DateTime timeNow = DateTime.now();
      DateTime todayEnd =
          DateTime(timeNow.year, timeNow.month, timeNow.day );
      DateTime todayStart = DateTime(timeNow.year, timeNow.month, timeNow.day);
      setState(() {
        if (eventDate.millisecondsSinceEpoch >= todayEnd.millisecondsSinceEpoch) {
          upcomingList.add(element);
        } else if (eventDate.millisecondsSinceEpoch >= todayStart.millisecondsSinceEpoch &&
            eventDate.millisecondsSinceEpoch < todayEnd.millisecondsSinceEpoch) {
          currentList.add(element);
        } else if (eventDate.millisecondsSinceEpoch < todayStart.millisecondsSinceEpoch) {
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
                                final organiserID =
                                    queryParams['organiserID'] ?? '';
                                final promoterID =
                                    queryParams['promoterID'] ?? '';
                                final clubUID = queryParams['clubUID'] ?? '';
                                if (eventID.isNotEmpty && promoterID.isEmpty) {
                                  if (uid() != organiserID) {
                                    String url = await FirebaseDynamicLinkEvent
                                        .createDynamicLink(
                                            short: true,
                                            clubUID: clubUID,
                                            eventID: eventID,
                                            organiserID: organiserID,
                                            promoterID: widget.isPromoter
                                                ? uid() ?? ''
                                                : '');
                                    print(url);
                                    print(await FirebaseDynamicLinkEvent
                                        .getParametersFromExistingLink(url));
                                    Clipboard.setData(ClipboardData(text: url));
                                    FirebaseFirestore.instance
                                        .collection('Events')
                                        .doc(eventID)
                                        .set({
                                      'promoterID':
                                          FieldValue.arrayUnion([uid()])
                                    }, SetOptions(merge: true));
                                    EasyLoading.dismiss();
                                    if (isInstagramStory) {
                                      Share.shareXFiles([imageFile!],
                                          text: url);
                                    } else {
                                      Share.share(url);
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Organiser and promoter cannot be same');
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Invalid promotion URL');
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

  void getCouponDetails() async {
    final entryManagementCouponList = await FirebaseFirestore.instance
        .collection("Events")
        .where('entryManagementCouponList', isEqualTo: '')
        .get();

    print('entryManagementCouponList: ${entryManagementCouponList.docs}');
  }

  Widget eventCard(QueryDocumentSnapshot data, DateTime date,
      {bool isCancelled = false,
      int index = 0,
      bool isActive = false,
      bool influencerCollab = false}) {
    List<CouponModel> couponList = [];
    try {
      final eventData = data.data() as Map?;
      if (eventData != null &&
          eventData.containsKey("entryManagementCouponList") &&
          eventData["entryManagementCouponList"] != null) {
        final couponData = eventData["entryManagementCouponList"];
        CouponModel couponListItem = CouponModel.fromJson(couponData);
        couponList.add(couponListItem);
      }
      if (eventData != null &&
          eventData.containsKey("tableManagementCouponList") &&
          eventData["tableManagementCouponList"] != null) {
        final couponData = eventData["tableManagementCouponList"];
        CouponModel couponListItem = CouponModel.fromJson(couponData);
        couponList.add(couponListItem);
      }
    } catch (e) {
      print(e);
    }
    // return GestureDetector(
    //   onTap: () => influencerCollab
    //       ? Get.to(EventInfluencerTabs(eventName: data['title']))
    //       : Get.to(EventPromotionCreate(
    //           isOrganiser: widget.isOrganiser,
    //           isPromoter: widget.isPromoter,
    //           isClub: widget.isClub,
    //           eventId: (data.id).toString(),
    //           eventData: data.data() as Map<String, dynamic>,
    //         )),
    child:
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.black),
      width: Get.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: Get.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(0.0).copyWith(left: 60.w),
                  child: Text(
                    data["title"].toString().capitalizeFirstOfEach,
                    style: GoogleFonts.ubuntu(
                        color: Colors.white, fontSize: 48.sp),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0).copyWith(right: 60.w),
                  child: Text(
                    "${date.day}-${date.month}-${date.year}",
                    style: GoogleFonts.ubuntu(
                        color: Colors.white, fontSize: 48.sp),
                  ),
                ),
              ],
            ).paddingSymmetric(vertical: 60.h),
          ),
          EventCouponCodeView(
              couponList: couponList,
              couponCategory: "Entry Management",
              couponTitle: "Entry Coupon",
              documentSnapshot: data,
              date: date,
              initCall: initCall),
          EventCouponCodeView(
              date: date,
              couponList: couponList,
              couponCategory: "Table Management",
              couponTitle: "Table Coupon",
              documentSnapshot: data,
              initCall: initCall),
          if (isCancelled)
            Row(
              children: [
                Text(
                  'Cancelled',
                  style: GoogleFonts.ubuntu(color: Colors.red, fontSize: 40.sp),
                )
              ],
            )
        ],
      ),
    ).paddingAll(30.w);
// );
  }

  Widget eventList(
          {bool isUpcoming = false,
          bool isCurrent = false,
          bool influencerCollab = false}) =>
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
          : Column(
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
                  ),
                ListView.builder(
                    padding: const EdgeInsets.only(bottom: 1000),
                    itemCount: isUpcoming
                        ? upcomingList.length
                        : isCurrent
                            ? currentList.length
                            : pastList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                            isCancelled: isCancelled,
                            isActive: isActive,
                            influencerCollab: influencerCollab);
                      } catch (e) {
                        return Container();
                      }
                    }),
              ],
            );


  @override
  Widget build(BuildContext context) {
    print('current index is ${currentIndex}');
    return SingleChildScrollView(
      child: Column(
        children: [
          if (currentIndex == 0) eventList(isUpcoming: true),
          if (currentIndex == 1)
            eventList(isUpcoming: true, influencerCollab: true)
        ],
      ),
    );
  }
}
