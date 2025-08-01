import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/bookings/booking_details.dart';
import 'package:club/screens/event_management/promotion_list.dart';
import 'package:club/screens/event_management/venue_promotion_create.dart';
import 'package:club/authentication/phyllo_integration/pyllo_init.dart';
import 'package:club/core/app_const/hive_const.dart';
import 'package:club/screens/insta-analytics/view_file/phyllo_view.dart';
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
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phyllo_connect/phyllo_connect.dart';
import 'package:share_plus/share_plus.dart';

import '../../event_management/create_event_promotion.dart';
import 'list_promotion_in_organiser.dart';
import 'promoter_page.dart';
import 'promotion_detail.dart';

class OfferPromotionListInPromotor extends StatefulWidget {
  final bool isOrganiser;
  final bool isPromoter;
  final bool isClub;
  const OfferPromotionListInPromotor(
      {Key? key,
        this.isOrganiser = false,
        this.isPromoter = false,
        this.isClub = false
      }
      )
      : super(key: key);

  @override
  State<OfferPromotionListInPromotor> createState() =>
      _OfferPromotionListInPromotorState();
}

class _OfferPromotionListInPromotorState
    extends State<OfferPromotionListInPromotor>
    with SingleTickerProviderStateMixin {
  final homeController = Get.put(HomeController());
  List upcomingList = [];
  List currentList = [];
  List pastList = [];
  bool isLoading = true;
  DateTime todayDate = DateTime.now();
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    initCall();
    super.initState();
  }

  void initCall() async {
    final getData = FirebaseFirestore.instance
        .collection("EventPromotionDetail")
        .where('status', isEqualTo: 2)
        .where('promoterId', isEqualTo: uid())
        .get();
    final data = await getData;
    for (var element in data.docs) {
      DateTime eventDate = element['startTime'].toDate();
      DateTime timeNow = DateTime.now();
      DateTime todayEnd =
      DateTime(timeNow.year, timeNow.month, timeNow.day + 1);
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

  Widget eventCard(QueryDocumentSnapshot data, DateTime date,
      {bool isCancelled = false, int index = 0, int isActive = 0, required String collabType}) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: Colors.black),
            width: Get.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.to(  PromotionDetails(
                    isOrganiser: false,
                    isPromoter:false,
                    isEditEvent:true,
                    isClub: data["isClub"],
                    collabType: collabType,
                    eventPromotionId: data["eventPromotionId"],
                    clubId: data["clubId"],
                  )),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black),
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
                                              "${date.day}-${date.month}-${date.year}",
                                              style: GoogleFonts.ubuntu(
                                                  color: Colors.white),
                                            ))),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                        child: Center(
                                            child: Text(
                                              data["name"].toString().capitalizeFirstOfEach,
                                              style: GoogleFonts.ubuntu(
                                                  color: Colors.white),
                                            ))),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                        child: Center(
                                            child: Text(
                                              "${date.day}-${date.month}-${date.year} onward",
                                              style: GoogleFonts.ubuntu(
                                                  color: Colors.white),
                                            ))),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                        child: Center(
                                          child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [

                                                if (date.compareTo(todayDate) >= 0)
                                                  GestureDetector(
                                                      onTap: () => Get.to(
                                                        PromoterPage(
                                                          eventPromotionId: data["eventPromotionId"],
                                                          clubId: data["clubId"],
                                                        ),

                                                      ),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.yellow,
                                                          ),
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: Text(
                                                          'Promotion',
                                                          style: GoogleFonts
                                                              .ubuntu(
                                                                  fontSize:
                                                                      30.sp,
                                                                  color: Colors
                                                                      .white),
                                                        ).paddingSymmetric(
                                                            vertical: 20.h,
                                                            horizontal: 20.w),
                                                      ),
                                                    ).marginOnly(bottom: 10),
                                                  if (isActive == 1)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Pending',
                                                          style: GoogleFonts
                                                              .ubuntu(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      40.sp),
                                                        ),
                                                      ],
                                                    )
                                                  else
                                                    Text(
                                                      'Accept',
                                                      style: GoogleFonts.ubuntu(
                                                          color: Colors.green,
                                                          fontSize: 40.sp),
                                                    ),
                                                ]),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).paddingSymmetric(vertical: 20.h),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).paddingSymmetric(horizontal: 12.w)
                  ],
                ),
            //     Align(
            //       alignment: Alignment.center,
            //       child: TextButton.icon(
            //         icon: const Icon(Icons.analytics, color: Colors.white),
            //         onPressed: () async {
            //           await Phyllo.init();
            //           Get.to(const PhylloView());
            //
            //           // Box box = await Hive.openBox(HiveConst.phylloBox);
            //           // String? accountId = box.get(HiveConst.phylloAccountId);
            //           // if (accountId != null) {
            //           //   print('phylloAccountId is not empty $accountId');
            //           //   Get.to(const PhylloView());
            //           // } else {
            //           //   await Phyllo.init();
            //           //   print('going to phylloinit');
            //           //
            //           //     Get.to(const PhylloView());
            //           // }
            //         },
            //         label: Text(
            //           'View Analytics',
            //           style: GoogleFonts.ubuntu(
            //               color: Colors.blue, fontSize: 40.sp),
            //         ),
            //                                               style: GoogleFonts.ubuntu(
            //                                                   fontSize: 30.sp,
            //                                                   color: Colors.white),
            //                                             ).paddingAll(10.0),)
            //                                       ).marginOnly(bottom: 10),
            //
            //                                     if (isActive==1)
            //                                       Row(
            //                                         children: [
            //                                           Text(
            //                                             'Pending',
            //                                             style: GoogleFonts.ubuntu(
            //                                                 color: Colors.white, fontSize: 40.sp),
            //                                           ),
            //
            //                                         ],
            //
            //                                       )
            //                                     else  Text(
            //                                       'Accept',
            //                                       style: GoogleFonts.ubuntu(
            //                                           color: Colors.green,fontSize: 40.sp),
            //                                     )
            //
            //                                   ]),
            //                             )),
            //                       ),
            //                     ],
            //                   ).paddingSymmetric(vertical: 60.h),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ).paddingAll(10.w),
            //
            //   ],
            // ),
          ),
        ],
      ).paddingAll(30.w);

  Widget eventList({bool isUpcoming = false, bool isCurrent = false}) =>
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
                SizedBox(
                  width: Get.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                            child: Center(
                                child: Text(
                                  "Post Date",
                                  style: GoogleFonts.ubuntu(color: Colors.white),
                                ))),
                      ),
                      Expanded(
                        child: SizedBox(
                            child: Center(
                                child: Text(
                                  "Event Name",
                                  style: GoogleFonts.ubuntu(color: Colors.white),
                                ))),
                      ),
                      Expanded(
                        child: SizedBox(
                            child: Center(
                                child: Text(
                                  "Event Date",
                                  style: GoogleFonts.ubuntu(color: Colors.white),
                                ))),
                      ),
                      Expanded(
                        child: SizedBox(
                            child: Center(
                                child: Text(
                                  "Status",
                                  style: GoogleFonts.ubuntu(color: Colors.white),
                                ))),
                      ),
                    ],
                  ).paddingSymmetric(vertical: 60.h),
                ),
              ListView.builder(
                  itemCount: isUpcoming
                      ? upcomingList.length
                      : isCurrent
                      ? currentList.length
                      : pastList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    try {
                      var data = isUpcoming
                          ? upcomingList[index]
                          : isCurrent
                          ? currentList[index]
                          : pastList[index];
                      // final bool isActive = data?['isActive'] ?? false;
                      final int status = data?['status'] ?? 0;
                      DateTime date = data?["startTime"].toDate();
                      print("the user final data is : ${data.data().toString()}");
                      String collabType = data?['collabType'];
                      return eventCard(data!, date,
                          index: index,
                          isCancelled: false,
                          isActive: status,
                          collabType: collabType);
                    } catch (e) {
                      return Container();
                    }
                  }).paddingOnly(top: 50.h),
            ],
          ));

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: appBar(context,
            title: "Event List",
            isOrganiser: true,
            tabController: tabController),
        drawer: drawer(context: context),
        body: TabBarView(
          controller: tabController,
          children: [
            PromotionListOrganiser(status: 0),
            // eventList(isUpcoming: true),
            // eventList(),
            PromotionListOrganiser(status: 4),
            PromotionListOrganiser(status: 4,type: 'past',),
          ],
        ),
        floatingActionButton: widget.isPromoter
            ? SizedBox(
            width: 350.w,
            child: FloatingActionButton(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: const Text('Promoter Link'),
              onPressed: () => onTapShareOptions(isPromotion: true),
            ))
            : widget.isClub
            ? FloatingActionButton(
          onPressed: () async {
            // final homeController = Get.put(HomeController());
            final scanResult = await barCodeScannerResult();
            List<String> scanResultData = scanResult.split('|');
            final bookingId = scanResultData[0];
            final clubUID = scanResultData[1];
            //final clubId = scanResultData[2];
            if (scanResult.isNotEmpty && scanResult != '-1') {
              if (clubUID == uid()) {
                Get.to(BookingDetails(bookingID: bookingId));
              } else {
                Fluttertoast.showToast(
                    msg: 'Booking is not made for this place');
              }
            } else {
              Fluttertoast.showToast(msg: 'Booking Id not found');
            }
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.document_scanner_outlined),
        )
            : const SizedBox(),
      ),
    );
  }
}
