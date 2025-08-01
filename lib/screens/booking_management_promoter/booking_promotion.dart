import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/booking_management_promoter/promotionBooking.dart';
import 'package:club/screens/bookings/booking_details.dart';
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
import 'package:uuid/uuid.dart';

class BookingPromotion extends StatefulWidget {
  final bool isOrganiser;
  final bool isPromoter;
  final bool isClub;

  const BookingPromotion(
      {Key? key,
        this.isOrganiser = false,
        this.isPromoter = false,
        this.isClub = false})
      : super(key: key);

  @override
  State<BookingPromotion> createState() => _BookingPromotionState();
}

class _BookingPromotionState extends State<BookingPromotion>
    with SingleTickerProviderStateMixin {
  final homeController = Get.put(HomeController());
  List upcomingList = [];
  List currentList = [];
  List pastList = [];
  late TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 3, vsync: this);
    fetchEventList();
    super.initState();
  }

  List currentEvent = [];
  List upComingEvent = [];
  List pastEvent = [];
  ValueNotifier<bool> isLoading = ValueNotifier(false);


  void fetchEventList() async{
    isLoading.value = true;
    QuerySnapshot data =  await FirebaseFirestore.instance
        .collection("EventPromotion")
        .where('collabType', isEqualTo: 'promotor')
        .get();

    List saveData = [];
    for(var element in data.docs){
      // DateTime startTime = element['startTime'].toDate();
      // if(startTime.isAfter(DateTime.now())) {
        saveData.add(element);
      // }
    }
    bookingList = [];
    for(var element in saveData){
      QuerySnapshot reqData = await FirebaseFirestore.instance
          .collection("PromotionRequest")
          .where('eventPromotionId', isEqualTo: element['id'])
          .where('influencerPromotorId', isEqualTo: uid())
          .get();

      if(4 == 4 && reqData.docs.isNotEmpty && reqData.docs[0]['status'] == 4){
        Map ele = {...element.data(), ...{'promotionId': element.id ,'status': reqData.docs.isEmpty ? 0 : reqData.docs[0]['status']}};
        bookingList.add(ele);
      }
    }
    log('pending request is ${bookingList}');
    List<Future<void>> fetchEvents =bookingList.map((data) async {
      String? eventId = data['eventId'];
      print('event list is ${eventId}');
      if (eventId != null) {
        DocumentSnapshot eventDoc = await FirebaseFirestore.instance
            .collection("Events")
            .doc(eventId)
            .get();

        var eventData = eventDoc.data() as Map<String, dynamic>;
        if (eventData != null) {
          eventListData.add({
            ...eventData,
            "eventId":eventDoc.id
          });
          currentEvent = eventListData.where((element) {
            final eventDate = (element['date'] as Timestamp).toDate();
            return eventDate.year == DateTime.now().year &&
                eventDate.month == DateTime.now().month &&
                eventDate.day == DateTime.now().day;
          }).toList();
          upComingEvent = eventListData.where((element) =>(element['date'] as Timestamp).toDate().isAfter(DateTime.now())).toList();
          pastEvent = eventListData.where((element) =>(element['date'] as Timestamp).toDate().isBefore(DateTime.now())).toList();

        }
      }
    }).toList();
    await Future.wait(fetchEvents);
    setState(() {});
    log('pending request is event list ${upComingEvent}');
    log('pending request is event list ${currentEvent}');
    log('pending request is event list ${pastEvent}');
    isLoading.value = false;
  }

  List eventListData = [];

  // void initCall() async {
  //   final getData = widget.isPromoter
  //       ? FirebaseFirestore.instance
  //       .collection("Events")
  //       .where('promoterID', arrayContains: uid())
  //       .orderBy('date', descending: true)
  //       .get()
  //       : widget.isOrganiser
  //       ? FirebaseFirestore.instance
  //       .collection("Events")
  //       .where('organiserID', isEqualTo: uid())
  //       .orderBy('date', descending: true)
  //       .get()
  //       : widget.isClub
  //       ? FirebaseFirestore.instance
  //       .collection("Events")
  //       .where('clubUID', isEqualTo: uid())
  //       .orderBy('date', descending: true)
  //       .get()
  //       : FirebaseFirestore.instance.collection("Events").get();
  //   final data = await getData;
  //   for (var element in data.docs) {
  //     DateTime eventDate = element['date'].toDate();
  //     DateTime timeNow = DateTime.now();
  //     DateTime todayEnd =
  //     DateTime(timeNow.year, timeNow.month, timeNow.day + 1);
  //     DateTime todayStart = DateTime(timeNow.year, timeNow.month, timeNow.day);
  //     setState(() {
  //       if (eventDate.millisecondsSinceEpoch >=
  //           todayEnd.millisecondsSinceEpoch) {
  //         upcomingList.add(element);
  //       } else if (eventDate.millisecondsSinceEpoch >=
  //           todayStart.millisecondsSinceEpoch &&
  //           eventDate.millisecondsSinceEpoch <
  //               todayEnd.millisecondsSinceEpoch) {
  //         currentList.add(element);
  //       } else if (eventDate.millisecondsSinceEpoch <
  //           todayStart.millisecondsSinceEpoch) {
  //         pastList.add(element);
  //       }
  //     });
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  // }
  List bookingList = [];


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

                                print( await FirebaseDynamicLinkEvent
                                    .getParametersFromExistingLink(
                                    url));
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

  Widget eventCard( data, DateTime date,
      {bool isCancelled = false, int index = 0, bool isActive = false}) =>
      GestureDetector(
        onTap: () => Get.to(PromotionBooking(
          eventId: (data['eventId']).toString(),
        )),
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

  Widget eventList({required List eventList}) {
    eventList.sort((a, b) => b['date'].toDate().compareTo(a['date'].toDate()));
    return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              if(eventList.isEmpty)
                SizedBox(height: 0.5.sh,),
              if(eventList.isEmpty)
                Center(child: Text('No event available',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,),),),
                ListView.builder(
                    itemCount: eventList.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      // try {
                        var data = eventList[index];
                        print('check event data is ${data}');
                        final bool isActive = data['isActive'] ?? false;
                        final bool isCancelled = data['status'] == 'C';
                        DateTime date = data["date"].toDate();
                        return eventCard(
                            data, date,
                            index: index,
                            isCancelled: isCancelled,
                            isActive: isActive);
                      // } catch (e) {
                      //   print('show erro $e');
                      //   return Container();
                      // }
                    }).paddingOnly(top: 50.h),
            ],
          ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: appBar(context,
            title: "Event List", isBooking: true, tabController: tabController),
        drawer: drawer(context: context),
        body: ValueListenableBuilder(
          valueListenable: isLoading,
          builder: (context, bool loading, child) {
            if(loading){
              return Center(child: CircularProgressIndicator(color: Colors.orangeAccent,),);
            }
            return TabBarView(
              controller: tabController,
              children: [
                eventList(eventList: currentEvent),
                eventList(eventList: upComingEvent),
                eventList(eventList: pastEvent)
              ],
            );
          }
        ),
      ),
    );
  }


}
