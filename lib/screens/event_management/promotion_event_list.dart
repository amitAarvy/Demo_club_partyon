import 'package:cloud_firestore/cloud_firestore.dart';
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

class PromotionEventList extends StatefulWidget {
  final bool isOrganiser;
  final bool isPromoter;
  final bool isClub;

  const PromotionEventList(
      {Key? key,
      this.isOrganiser = false,
      this.isPromoter = false,
      this.isClub = false})
      : super(key: key);

  @override
  State<PromotionEventList> createState() => _PromotionEventListState();
}

class _PromotionEventListState extends State<PromotionEventList>
    with SingleTickerProviderStateMixin {
  final homeController = Get.put(HomeController());
  List upcomingList = [];
  List currentList = [];
  List pastList = [];
  bool isLoading = true;
  late TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 3, vsync: this);
    initCall();
    super.initState();
  }

  void initCall() async {
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
  List bookingList = [];

  fetchEventBookingList()async{
    var snapshot = await FirebaseFirestore.instance
        .collection('Bookings')
        .where(widget.isOrganiser ? 'organiserID' : 'clubUID', isEqualTo: uid())
        .where('newNotification', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'newNotification': false});
    }

    // bookingList = snapshot.docs;
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

  Widget eventCard(QueryDocumentSnapshot data, DateTime date,
          {bool isCancelled = false, int index = 0, bool isActive = false}) =>
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Bookings').where('eventID',isEqualTo: (data.id).toString()).where('newNotification',isEqualTo: true).snapshots(),
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
          // final users = snapshot.data!.docs;

          notificationCount= snapshot.data==null?0:snapshot.data!.docs.length;

        return GestureDetector(
          onTap: () => Get.to(PromotionBookingList(
            isOrganiser: widget.isOrganiser,
            isPromoter: widget.isPromoter,
            isClub: widget.isClub,
            eventID: (data.id).toString(),
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
                          if(notificationCount != 0)
                          Expanded(child: Container(height: 20,width: 20,decoration: BoxDecoration(color: Colors.green,shape: BoxShape.circle),child: Center(child: Text(notificationCount.toString(),style: TextStyle(color: Colors.white),),),))
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
        ).paddingAll(30.w);}
      );

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
                                isCancelled: isCancelled,
                                isActive: isActive);
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
            title: "Event List", isBooking: true, tabController: tabController),
        drawer: drawer(context: context),
        body: TabBarView(
          controller: tabController,
          children: [
            eventList(isCurrent: true),
            eventList(isUpcoming: true),
            eventList()
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
            final uuid = Uuid();
            final uniqueId = uuid.v4().substring(0, 4);

            final scanResult = await barCodeScannerResult();
            print('Scan result: $scanResult');

            if (scanResult.isEmpty || scanResult == '-1') {
              Fluttertoast.showToast(msg: 'Booking ID not found');
              return;
            }

            // Initialize variables
            String bookingId = '';
            String clubUID = '';
            String eventId = '';
            String oldUid = '';

            try {
              print('check list is ${scanResult}');
              List<String> scanResultData = scanResult.split('|');

              if (scanResultData[0] == 'UA') {
                // UA format: UA|bookingId|clubUID|eventId|oldUid
                if (scanResultData.toString().length >= 5) {
                  bookingId = scanResultData[1];
                  eventId = scanResultData[2];
                  oldUid = scanResultData[3];
                  // oldUid = scanResultData[4];
                } else {
                  Fluttertoast.showToast(msg: 'Invalid QR Code format.');
                  return;
                }
              } else {
                // Legacy format: bookingId|clubUID||eventId
                if (scanResult.contains('||')) {
                  List<String> legacySplit = scanResult.split('||');
                  List<String> ids = legacySplit[0].split('|');

                  if (ids.length >= 2 && legacySplit.length >= 2) {
                    bookingId = ids[0];
                    clubUID = ids[1];
                    eventId = legacySplit[1];
                  } else {
                    Fluttertoast.showToast(msg: 'Invalid legacy QR Code format.');
                    return;
                  }
                } else {
                  Fluttertoast.showToast(msg: 'Unsupported QR Code format.');
                  return;
                }
              }
            } catch (e) {
              Fluttertoast.showToast(msg: 'Error parsing QR Code: $e');
              return;
            }

            // if (clubUID != uid()) {
            //   Fluttertoast.showToast(msg: 'Booking is not made for this place');
            //   return;
            // }

            final docRef = FirebaseFirestore.instance.collection('CheckInOut').doc(eventId);
            final snapshot = await docRef.get();

            String finalUid = uniqueId;

            if (snapshot.exists && snapshot.data()!.containsKey('checkInList')) {
              List userList = List.from(snapshot.data()!['checkInList']);
              var match = userList.firstWhere(
                    (e) => e['bookingId'].toString() == bookingId,
                orElse: () => null,
              );

              if (match != null) {
                print('check uid is ${match['uid'].toString()}');
                finalUid = match['uid'].toString();
              }
            }

            await checkInOut(eventId, bookingId, finalUid, (scanResult.startsWith('UA')).toString());
            await updateStatus(eventId, bookingId);

            Get.to(BookingDetails(
              bookingID: bookingId,
              eventId: eventId,
              uuid: finalUid,
              clubUid: clubUID,
            ));
          },

          backgroundColor: Colors.red,
                    child: const Icon(Icons.document_scanner_outlined),
                  )
                : const SizedBox(),
      ),
    );
  }

  Future<void> checkInOut(String eventId, String bookingId, String uuid, String functionCall) async {
    final docRef = FirebaseFirestore.instance.collection('CheckInOut').doc(eventId);
    final snapshot = await docRef.get();
    print('Function call: $functionCall');

    List<dynamic> userList = [];

    if (snapshot.exists && snapshot.data()!.containsKey('checkInList')) {
      userList = List.from(snapshot.data()!['checkInList']);

      bool userFound = false;

      for (int i = 0; i < userList.length; i++) {
        if (userList[i]['uid'].toString() == uuid.toString()) {
          userFound = true;

          if (functionCall == 'true' && (userList[i]['checkOut'] == '' )) {
            userList[i]['checkOut'] = DateTime.now();
          }
          break;
        }
      }

      // If user not found, add a new entry (new check-in)
      if (!userFound) {
        print('check it is ');
        userList.add({
          'eventId': eventId,
          'bookingId': bookingId,
          'checkIn': DateTime.now(),
          'checkOut': '',
          'uid': uuid,
        });
      }

      // Update the document
      await docRef.update({'checkInList': userList});
      print('Check-in/out updated for user: $uuid');
    } else {
      await docRef.set({
        'checkInList': [
          {
            'eventId': eventId,
            'bookingId': bookingId,
            'checkIn': DateTime.now(),
            'checkOut': '',
            'uid': uuid,
          }
        ]
      });
      print('Check-in document created for event: $eventId');
    }
  }
  Future<void> updateStatus(String eventId, String bookingId) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('PrAnalytics')
          .where('eventId', isEqualTo: eventId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No documents found for eventId: $eventId');
        return;
      }

      for (var doc in querySnapshot.docs) {
        List<dynamic> userList = List.from(doc['userList']);

        bool updated = false;

        for (int i = 0; i < userList.length; i++) {
          if (userList[i]['bookingId'].toString() == bookingId.toString()) {
            userList[i]['noShow'] = false;
            updated = true;
            break;
          }
        }

        if (updated) {
          await FirebaseFirestore.instance
              .collection('PrAnalytics')
              .doc(doc.id)
              .update({'userList': userList});
          print('userList updated successfully for document: ${doc.id}');
        } else {
          print('BookingId not found in document: ${doc.id}');
        }
      }
    } catch (e) {
      print('Error updating userList: $e');
    }
  }

}
