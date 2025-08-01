import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/dynamic_link/dynamic_link.dart';
import 'package:club/screens/event_management/event_list.dart';
import 'package:club/screens/event_management/event_management.dart';
import 'package:club/screens/live/live_status.dart';
import 'package:club/screens/organiser/event_management/barter_promotion_detail.dart';
import 'package:club/screens/organiser/event_management/organiser_event_management.dart';
import 'package:club/screens/pr_companies/widget/message_preview.dart';
import 'package:club/utils/app_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:club/screens/event_management/promotion_event_list.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../coupon_code/controller/coupon_code_controller.dart';
import '../coupon_code/model/data/coupon_code_model.dart';
import '../organiser/event_management/accept_influencer_promotion_list.dart';
import '../organiser/event_management/influencer_promotion_list.dart';
import '../organiser/event_management/offer_promotion_list.dart';
import '../organiser/home/organiser_homeBar.dart';
import 'package:http/http.dart' as http;


class InfluencerPromotion extends StatefulWidget {
  final String eventPromotionId;
  final String clubId;
  final data;
  final String? couponId;

  const InfluencerPromotion(
      {Key? key, required this.eventPromotionId, required this.clubId,required this.data, this.couponId})
      : super(key: key);

  @override
  State<InfluencerPromotion> createState() => _InfluencerPromotionState();
}

class _InfluencerPromotionState extends State<InfluencerPromotion> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final HomeController homeController = Get.put(HomeController());
  int favCount = 0;
  String menuId = const Uuid().v4();


  dynamic mainData = "";
  dynamic currentUserData = "";
  String clubName = "";
  String url = "";
  bool showUrl = false;

  List<TextEditingController> deliverable = [TextEditingController()];
  TextEditingController scriptController = TextEditingController();
  TextEditingController infComissionController = TextEditingController();
  TextEditingController infComissionTableController = TextEditingController();

  @override
  void initState() {
    // homeController
    //     .updateOrganiserName((FirebaseAuth.instance.currentUser?.displayName)!);
    super.initState();
    fetchEventPromotionData();
    fetchCurrentPromotorData();
    fetchEditClubsData();
    // createUrl();

    log('check is ${widget.data}');
    url = widget.data['pomotionData']['eventLink'].toString();
    // createUrl();
    sharedCoupon();
    updateCouponCodePr();
    print('check image is ${widget.data}');
  }



  updateCouponCodePr()async{
    final data = await FirebaseFirestore.instance.collection('Organiser').doc(uid()).get();
    log('check event list is ${data.data()!['companyMame']}');

    final promoData = widget.data['pomotionData']  ?? {};
    String discount = promoData['offeredCommissionPr']??jsonDecode(promoData['entryCoupon'] ?? '{}')['discount']?.toString() ?? '';
    String tableDiscount = promoData['offeredCommissionTablePr']??jsonDecode(promoData['tableCoupon'] ?? '{}')['discount']?.toString() ?? '';
    String companyName = widget.couponId.toString();
    String finalCode = 'PARTYON' + companyName + discount;
    String tableCode  = companyName + 'PARTYON' + tableDiscount;

    log('tesing check ${promoData}');
    print('tesing check ${promoData.containsKey('tableCoupon')}');
    entryCoupon.text = promoData['entryCoupon'].toString() != 'null'
        ? finalCode
        : '';
    tableCoupon.text = promoData['tableCoupon'].toString() != 'null' ? tableCode
        : '';
    setState(() {
    });
  }
  List promotionalData = [];
  List<String> platformForPosting = [];

  bool showEventDetail = false,
      showDeliverables = false,
      showMenu = false,
      showAiData = false;

  bool showPromotionDropdowns = false;
  bool showPromotionalImage = false,
      showPostsImage = false,
      showReelImage = false;

  void fetchEventPromotionData() async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection('EventPromotion')
        .doc(widget.eventPromotionId)
        .get();
    mainData = data.data() as Map<String, dynamic>;
    setState(() {});
  }

  void fetchCurrentPromotorData() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('Organiser')
        .doc(uid())
        .get();
    currentUserData = userData;
    setState(() {});
  }

  // void createUrl() async {
  //   url = await FirebaseDynamicLinkEvent.createDynamicLink(
  //     short: true,
  //     // clubUID: isClub ? uid() : data['clubUID'] ?? '',
  //     clubUID: widget.clubId,
  //     eventID: widget.eventPromotionId,
  //     organiserID: uid().toString(),
  //   );
  //   setState(() {});
  // }

  void fetchEditClubsData() async {
    await FirebaseFirestore.instance
        .collection("Club")
        .doc(widget.clubId)
        .get()
        .then((doc) async {
      if (doc.exists) {
        clubName = getKeyValueFirestore(doc, 'clubName') ?? '';
        setState(() {});
      }
    });
  }

  ValueNotifier<String> selectOption = ValueNotifier('exploreAll');


  Widget optionWidget(String groupValue,String currentValue,String title){
    return Row(
      children: [
        Radio(
          value: currentValue,
          activeColor: Colors.blue,
          focusColor: Colors.white,
          groupValue: groupValue,
          hoverColor: Colors.red,
          onChanged: (value) {
            selectOption.value = groupValue;
          },
        ),
        GestureDetector(
            onTap: (){
              selectOption.value = groupValue;
            },
            child: Text(title,style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),))
      ],
    );
  }




  //// New page create

  late Future<List<CouponModel>> sharedCouponList;
  MethodChannel channel = const MethodChannel('instagramshare');

  Future<void> shareToInstagram(String filePath, String fileType) async {
    try {
      await channel.invokeMethod('share', {'filePath': filePath, 'fileType': fileType});
    } catch (e) {
      print('Error sharing to Instagram: $e');
    }
  }

  Future<void> shareMultipleToInstagram(List<String> filePaths) async {
    try {
      await channel.invokeMethod('shareMultiple', {'filePaths': filePaths});
    } catch (e) {
      print('Error sharing to Instagram: $e');
    }
  }
  void sharedCoupon() async {
    sharedCouponList = (CouponCodeController.savedCouponCodes(venueId: widget.data['clubUID'].toString()));
  }

  // Future<String> downloadFile(String url, String fileName, {String defaultExtension = 'jpg'}) async {
  //   try {
  //     final dir = await getTemporaryDirectory();
  //     final filePath = '${dir.path}/$fileName.$defaultExtension'; // Add a default extension if missing
  //
  //     // Force content type detection and append extension dynamically
  //     final response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
  //     final fileType = response.headers['content-type']?.first ?? 'application/octet-stream';
  //
  //     String actualExtension;
  //     if (fileType.startsWith('image')) {
  //       actualExtension = 'jpg'; // You can refine this further
  //     } else if (fileType.startsWith('video')) {
  //       actualExtension = 'mp4'; // Default for videos
  //     } else {
  //       actualExtension = defaultExtension; // Fallback
  //     }
  //
  //     // Update file path with the detected extension
  //     final updatedFilePath = '${dir.path}/$fileName.$actualExtension';
  //
  //     // Write the file
  //     final file = File(updatedFilePath);
  //     await file.writeAsBytes(response.data);
  //
  //     return updatedFilePath;
  //   } catch (e) {
  //     print('Error downloading file: $e');
  //     rethrow;
  //   }
  // }


  TextEditingController entryCoupon = TextEditingController();
  TextEditingController tableCoupon = TextEditingController();

  Widget editCoupon(String type){
    return AlertDialog(
      backgroundColor: Colors.grey,
      title: Text('Edit Coupon',style: TextStyle(fontSize: 14,color:Colors.white),),
      content:  textField('$type', type=='Entry'?entryCoupon:tableCoupon,),
      actions: [
        InkWell(
          onTap: ()async{

            if(type =='Entry'){
              var data = jsonDecode(widget.data['pomotionData']['entryCoupon']);
              data['couponCode'] = entryCoupon.text;
              // await FirebaseFirestore.instance
              //     .collection('EventPromotion')
              //     .doc(widget.data['pomotionData']['id'])
              //     .update({
              //   'entryCoupon': jsonEncode(data),
              // }).whenComplete(() {
              // });
              Navigator.pop(context);
              setState(() {


              },);
            }else{
              var data = jsonDecode(widget.data['pomotionData']['tableCoupon']);
              data['couponCode'] = tableCoupon.text;
              // await FirebaseFirestore.instance
              //     .collection('EventPromotion')
              //     .doc(widget.data['pomotionData']['id'])
              //     .update({
              //   'entryCoupon': jsonEncode(data),
              // }).whenComplete(() {   });
              Navigator.pop(context);
              setState(() {

              },
              );
            }

          },
          child: Container(
            width: 1.sw,
            decoration: BoxDecoration(
                color: Colors.orangeAccent,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(11))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text('Update',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: matte(),
      // appBar: appBar(context,
      //     title: mainData is String || currentUserData is String
      //         ? ''
      //         : mainData['eventName'],
      //     showLogo: true,
      //     key: _key),
      body: mainData is String || currentUserData is String
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          :  SingleChildScrollView(
            child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20,),
                ValueListenableBuilder(
                  valueListenable: selectOption,
                  builder: (context, String value, child) =>
                      Row(
                        children: [
                          optionWidget('inviteOnly',value,'Invite Only'),
                          optionWidget('exploreAll',value,'Explore All'),
                        ],
                      ),
                ),
            
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 120.h,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${clubName.capitalize}",
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white70,
                                  fontSize: 45.sp),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 120.h,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            if (mainData['amountPaid'].isNotEmpty)
                              Text(
                                "Amount Paid: ${mainData['amountPaid']}",
                                style: GoogleFonts.ubuntu(
                                    color: Colors.white70,
                                    fontSize: 45.sp),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                if (!((mainData['promotionImages'] == null ||
                    mainData['promotionImages'].isEmpty) &&
                    (mainData['postImages'] == null ||
                        mainData['postImages'].isEmpty) &&
                    (mainData['reelsImages'] == null ||
                        mainData['reelsImages'].isEmpty)))
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      overlayColor: WidgetStateProperty.resolveWith(
                              (states) => Colors.transparent),
                      onTap: () {
                        setState(() {
                          showPromotionDropdowns =
                          !showPromotionDropdowns;
                        });
                      },
                      child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Promotional Data (Received from venue)",
                              style: GoogleFonts.ubuntu(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPromotionDropdowns =
                                    !showPromotionDropdowns;
                                  });
                                },
                                icon: Icon(
                                  !showPromotionDropdowns
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                  color: Colors.white,
                                ))
                          ]),
                    ),
                  ),
                if (showPromotionDropdowns)
                  Column(
                    children: [
                      if (mainData['promotionImages'] != null &&
                          mainData['promotionImages'].isNotEmpty)
                        Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                "Story",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange),
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showPromotionalImage =
                                      !showPromotionalImage;
                                    });
                                  },
                                  icon: Icon(
                                    showPromotionalImage == false
                                        ? Icons.arrow_drop_down
                                        : Icons.arrow_drop_up,
                                    color: Colors.white,
                                  ))
                            ]),
                      if (showPromotionalImage &&
                          mainData['promotionImages'] != null &&
                          mainData['promotionImages'].isNotEmpty)
                        AspectRatio(
                          aspectRatio: 9 / 16,
                          child: PageView.builder(
                            reverse: false,
                            scrollDirection: Axis.horizontal,
                            itemCount:
                            mainData['promotionImages'].length,
                            itemBuilder: (context, index) {
                              Uri url = Uri.parse(
                                  mainData['promotionImages']
                                  [index]);
                              if (lookupMimeType(url.path)!
                                  .contains("image/")) {
                                return Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Center(
                                      child: Image.network(
                                        mainData['promotionImages']
                                        [index],
                                        errorBuilder: (context,
                                            error, stackTrace) {
                                          return const Center(
                                              child: Text(
                                                  "some error occurred",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .white)));
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        FileDownloader.downloadFile(
                                            url: mainData[
                                            'promotionImages']
                                            [index],
                                            onDownloadCompleted:
                                                (path) {
                                              debugPrint(
                                                  "download complete hua: ${path}");
                                            },
                                            onDownloadError:
                                                (errorMessage) {
                                              debugPrint(
                                                  "download complete nhi hua error: ${errorMessage}");
                                            },
                                            onProgress: (fileName,
                                                progress) {
                                              debugPrint(
                                                  "download complete in progress");
                                            },
                                            notificationType:
                                            NotificationType
                                                .all);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: 20),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius
                                                .circular(5)),
                                        child: Text("Download",
                                            style: TextStyle(
                                                color:
                                                Colors.white)),
                                      ),
                                    )
                                  ],
                                );
                              } else if (lookupMimeType(url.path)!
                                  .contains("video/")) {
                                return Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Center(
                                        child: CustomVideoPlayer(
                                            link: mainData[
                                            'promotionImages']
                                            [index])),
                                    InkWell(
                                      onTap: () {
                                        FileDownloader.downloadFile(
                                            url: mainData[
                                            'promotionImages']
                                            [index],
                                            onDownloadCompleted:
                                                (path) {
                                              debugPrint(
                                                  "download complete hua: ${path}");
                                            },
                                            onDownloadError:
                                                (errorMessage) {
                                              debugPrint(
                                                  "download complete nhi hua error: ${errorMessage}");
                                            },
                                            onProgress: (fileName,
                                                progress) {
                                              debugPrint(
                                                  "download complete in progress");
                                            },
                                            notificationType:
                                            NotificationType
                                                .all);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: 20),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius
                                                .circular(5)),
                                        child: Text("Download",
                                            style: TextStyle(
                                                color:
                                                Colors.white)),
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                return Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Center(
                                      child: Image.network(
                                        mainData['promotionImages']
                                        [index],
                                        errorBuilder: (context,
                                            error, stackTrace) {
                                          return CustomVideoPlayer(
                                              link: mainData[
                                              'promotionImages']
                                              [index]);
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        FileDownloader.downloadFile(
                                            url: mainData[
                                            'promotionImages']
                                            [index],
                                            onDownloadCompleted:
                                                (path) {
                                              debugPrint(
                                                  "download complete hua: ${path}");
                                            },
                                            onDownloadError:
                                                (errorMessage) {
                                              debugPrint(
                                                  "download complete nhi hua error: ${errorMessage}");
                                            },
                                            onProgress: (fileName,
                                                progress) {
                                              debugPrint(
                                                  "download complete in progress");
                                            },
                                            notificationType:
                                            NotificationType
                                                .all);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: 20),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius
                                                .circular(5)),
                                        child: Text("Download",
                                            style: TextStyle(
                                                color:
                                                Colors.white)),
                                      ),
                                    )
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      if (mainData['postImages'] != null &&
                          mainData['postImages'].isNotEmpty)
                        Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                "Posts",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange),
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showPostsImage =
                                      !showPostsImage;
                                    });
                                  },
                                  icon: Icon(
                                    showPostsImage == false
                                        ? Icons.arrow_drop_down
                                        : Icons.arrow_drop_up,
                                    color: Colors.white,
                                  ))
                            ]),
                      if (showPostsImage &&
                          mainData['postImages'] != null &&
                          mainData['postImages'].isNotEmpty)
                        AspectRatio(
                          aspectRatio: 4 / 5,
                          child: PageView.builder(
                            reverse: false,
                            scrollDirection: Axis.horizontal,
                            itemCount:
                            mainData['postImages'].length,
                            itemBuilder: (context, index) {
                              Uri url = Uri.parse(
                                  mainData['postImages'][index]);
                              if (lookupMimeType(url.path)!
                                  .contains("image/")) {
                                return Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Center(
                                      child: Image.network(
                                        mainData['postImages']
                                        [index],
                                        errorBuilder: (context,
                                            error, stackTrace) {
                                          return const Center(
                                              child: Text(
                                                  "some error occurred",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .white)));
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        FileDownloader.downloadFile(
                                            url: mainData[
                                            'postImages']
                                            [index],
                                            onDownloadCompleted:
                                                (path) {
                                              debugPrint(
                                                  "download complete hua: ${path}");
                                            },
                                            onDownloadError:
                                                (errorMessage) {
                                              debugPrint(
                                                  "download complete nhi hua error: ${errorMessage}");
                                            },
                                            onProgress: (fileName,
                                                progress) {
                                              debugPrint(
                                                  "download complete in progress");
                                            },
                                            notificationType:
                                            NotificationType
                                                .all);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: 20),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius
                                                .circular(5)),
                                        child: Text("Download",
                                            style: TextStyle(
                                                color:
                                                Colors.white)),
                                      ),
                                    )
                                  ],
                                );
                              } else if (lookupMimeType(url.path)!
                                  .contains("video/")) {
                                return Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Center(
                                        child: CustomVideoPlayer(
                                            link: mainData[
                                            'postImages']
                                            [index])),
                                    InkWell(
                                      onTap: () {
                                        FileDownloader.downloadFile(
                                            url: mainData[
                                            'postImages']
                                            [index],
                                            onDownloadCompleted:
                                                (path) {
                                              debugPrint(
                                                  "download complete hua: ${path}");
                                            },
                                            onDownloadError:
                                                (errorMessage) {
                                              debugPrint(
                                                  "download complete nhi hua error: ${errorMessage}");
                                            },
                                            onProgress: (fileName,
                                                progress) {
                                              debugPrint(
                                                  "download complete in progress");
                                            },
                                            notificationType:
                                            NotificationType
                                                .all);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: 20),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius
                                                .circular(5)),
                                        child: Text("Download",
                                            style: TextStyle(
                                                color:
                                                Colors.white)),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Center(
                                      child: Image.network(
                                        mainData['postImages']
                                        [index],
                                        width: 1.sw,
                                        errorBuilder: (context,
                                            error, stackTrace) {
                                          return CustomVideoPlayer(
                                              link: mainData[
                                              'postImages']
                                              [index]);
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        FileDownloader.downloadFile(
                                            url: mainData[
                                            'postImages']
                                            [index],
                                            onDownloadCompleted:
                                                (path) {
                                              debugPrint(
                                                  "download complete hua: ${path}");
                                            },
                                            onDownloadError:
                                                (errorMessage) {
                                              debugPrint(
                                                  "download complete nhi hua error: ${errorMessage}");
                                            },
                                            onProgress: (fileName,
                                                progress) {
                                              debugPrint(
                                                  "download complete in progress");
                                            },
                                            notificationType:
                                            NotificationType
                                                .all);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: 20),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius
                                                .circular(5)),
                                        child: Text("Download",
                                            style: TextStyle(
                                                color:
                                                Colors.white)),
                                      ),
                                    )
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      if (mainData['reelsImages'] != null &&
                          mainData['reelsImages'].isNotEmpty)
                        Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                "Reels",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange),
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showReelImage =
                                      !showReelImage;
                                    });
                                  },
                                  icon: Icon(
                                    showReelImage == false
                                        ? Icons.arrow_drop_down
                                        : Icons.arrow_drop_up,
                                    color: Colors.white,
                                  ))
                            ]),
                      if (showReelImage &&
                          mainData['reelsImages'] != null &&
                          mainData['reelsImages'].isNotEmpty)
                        AspectRatio(
                          aspectRatio: 9 / 16,
                          child: PageView.builder(
                            reverse: false,
                            scrollDirection: Axis.horizontal,
                            itemCount:
                            mainData['reelsImages'].length,
                            itemBuilder: (context, index) {
                              Uri url = Uri.parse(
                                  mainData['reelsImages'][index]);
                              if (lookupMimeType(url.path)!
                                  .contains("image/")) {
                                return Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Center(
                                      child: Image.network(
                                        mainData['reelsImages']
                                        [index],
                                        errorBuilder: (context,
                                            error, stackTrace) {
                                          return const Center(
                                              child: Text(
                                                  "some error occurred",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .white)));
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        FileDownloader.downloadFile(
                                            url: mainData[
                                            'reelsImages']
                                            [index],
                                            onDownloadCompleted:
                                                (path) {
                                              debugPrint(
                                                  "download complete hua: ${path}");
                                            },
                                            onDownloadError:
                                                (errorMessage) {
                                              debugPrint(
                                                  "download complete nhi hua error: ${errorMessage}");
                                            },
                                            onProgress: (fileName,
                                                progress) {
                                              debugPrint(
                                                  "download complete in progress");
                                            },
                                            notificationType:
                                            NotificationType
                                                .all);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: 20),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius
                                                .circular(5)),
                                        child: Text("Download",
                                            style: TextStyle(
                                                color:
                                                Colors.white)),
                                      ),
                                    )
                                  ],
                                );
                              } else if (lookupMimeType(url.path)!
                                  .contains("video/")) {
                                return Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Center(
                                        child: CustomVideoPlayer(
                                            link: mainData[
                                            'reelsImages']
                                            [index])),
                                    InkWell(
                                      onTap: () {
                                        FileDownloader.downloadFile(
                                            url: mainData[
                                            'reelsImages']
                                            [index],
                                            onDownloadCompleted:
                                                (path) {
                                              debugPrint(
                                                  "download complete hua: ${path}");
                                            },
                                            onDownloadError:
                                                (errorMessage) {
                                              debugPrint(
                                                  "download complete nhi hua error: ${errorMessage}");
                                            },
                                            onProgress: (fileName,
                                                progress) {
                                              debugPrint(
                                                  "download complete in progress");
                                            },
                                            notificationType:
                                            NotificationType
                                                .all);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: 20),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius
                                                .circular(5)),
                                        child: Text("Download",
                                            style: TextStyle(
                                                color:
                                                Colors.white)),
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                return Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Center(
                                      child: Image.network(
                                        mainData['reelsImages']
                                        [index],
                                        errorBuilder: (context,
                                            error, stackTrace) {
                                          return CustomVideoPlayer(
                                              link: mainData[
                                              'reelsImages']
                                              [index]);
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        FileDownloader.downloadFile(
                                            url: mainData[
                                            'reelsImages']
                                            [index],
                                            onDownloadCompleted:
                                                (path) {
                                              debugPrint(
                                                  "download complete hua: ${path}");
                                            },
                                            onDownloadError:
                                                (errorMessage) {
                                              debugPrint(
                                                  "download complete nhi hua error: ${errorMessage}");
                                            },
                                            onProgress: (fileName,
                                                progress) {
                                              debugPrint(
                                                  "download complete in progress");
                                            },
                                            notificationType:
                                            NotificationType
                                                .all);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: 20),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                            BorderRadius
                                                .circular(5)),
                                        child: Text("Download",
                                            style: TextStyle(
                                                color:
                                                Colors.white)),
                                      ),
                                    )
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 10),
                Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.all(15),
                  width: Get.width - 100.w,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        overlayColor:
                        WidgetStateProperty.resolveWith(
                                (states) => Colors.transparent),
                        onTap: () {
                          setState(() {
                            showEventDetail = !showEventDetail;
                          });
                        },
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Event Details",
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white70,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              !showEventDetail
                                  ? Icons.arrow_drop_down
                                  : Icons.arrow_drop_up,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                      if (showEventDetail)
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 15),
                            Center(
                              child: SizedBox(
                                width:  Get.width / 2.8,
                                child: AspectRatio(
                                  aspectRatio: 9/16,
                                  child: Container(
                                    width: Get.width,
                                    // height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child:
                                      CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        fadeInDuration: const Duration(milliseconds: 100),
                                        fadeOutDuration: const Duration(milliseconds: 100),
                                        useOldImageOnUrlChange: true,
                                        filterQuality: FilterQuality.low,
                                        imageUrl: widget.data['coverImages'][0].toString(), // Use the first image in the list
                                        // placeholder: (_, __) => const Center(
                                        //   child: CircularProgressIndicator(color: Colors.orange),
                                        // ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                            Text(
                              "${mainData['eventName']}".capitalizeFirstOfEach,
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontSize: 18,fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            Text(widget.data['briefEvent'].toString(),style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white,fontSize: 14),),
                            SizedBox(height: 10,),
                            Text(widget.data['artistName'].toString(),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                if (mainData['script'].isNotEmpty)
                                  Expanded(
                                    child: Text(
                                      "Script : ${mainData['script']}",
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                Text(
                                  "pax : ${mainData['noOfBarterCollab']}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Date : ${DateFormat.yMMMd().format(mainData['startTime'].toDate())}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize: 16),
                                ),
                                Text(
                                  "Time : ${DateFormat('hh : mm a').format(mainData['startTime'].toDate())}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize: 16),
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "Duration : ${DateTime.parse(mainData['endTime'].toDate().toString()).difference(DateTime.parse(mainData['startTime'].toDate().toString())).inHours} hours",
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontSize: 16),
                            )
                          ],
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.all(15),
                  width: Get.width - 100.w,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        overlayColor:
                        WidgetStateProperty.resolveWith(
                                (states) => Colors.transparent),
                        onTap: () {
                          setState(() {
                            showDeliverables = !showDeliverables;
                          });
                        },
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Deliverables",
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white70,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              !showDeliverables
                                  ? Icons.arrow_drop_down
                                  : Icons.arrow_drop_up,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                      if (showDeliverables)
                        const SizedBox(height: 10),
                      if (showDeliverables)
                        ListView.builder(
                          shrinkWrap: true,
                          physics:
                          const NeverScrollableScrollPhysics(),
                          itemCount:
                          mainData['deliverables'].length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white,
                                      width: 0.5),
                                  borderRadius:
                                  BorderRadius.circular(60)),
                              child: Row(
                                children: [
                                  Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                        color: Colors
                                            .primaries[index %
                                            Colors.primaries
                                                .length +
                                            10]
                                            .withOpacity(0.3),
                                        borderRadius:
                                        BorderRadius.circular(
                                            1000)),
                                    child: Center(
                                        child: Text(
                                          "${index + 1}",
                                          style: TextStyle(
                                              color: Colors.primaries[
                                              index %
                                                  Colors
                                                      .primaries
                                                      .length +
                                                  10]),
                                        )),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text(
                                          "${mainData['deliverables'][index]}",
                                          style: GoogleFonts.ubuntu(
                                              color: Colors.white70,
                                              fontWeight: FontWeight
                                                  .w600))),
                                ],
                              ),
                            );
                          },
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if ((mainData['offerFromMenu'] as List)
                    .where((element) =>
                element['gender'] ==
                    (currentUserData.data()['gender'] ??
                        'male') ||
                    (element['gender'] == "both" &&
                        (currentUserData.data()['gender'] ??
                            'male') !=
                            'others'))
                    .toList()
                    .isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(15),
                    width: Get.width - 100.w,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          overlayColor:
                          WidgetStateProperty.resolveWith(
                                  (states) => Colors.transparent),
                          onTap: () {
                            setState(() {
                              showMenu = !showMenu;
                            });
                          },
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Offered Menu Items",
                                style: GoogleFonts.ubuntu(
                                    color: Colors.white70,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                !showMenu
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                        if (showMenu) const SizedBox(height: 10),
                        if (showMenu)
                          ListView.builder(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemCount: (mainData['offerFromMenu']
                            as List)
                                .where((element) =>
                            element['gender'] ==
                                (currentUserData
                                    .data()['gender'] ??
                                    'male') ||
                                (element['gender'] == "both" &&
                                    (currentUserData.data()[
                                    'gender'] ??
                                        'male') !=
                                        'others'))
                                .toList()
                                .first['menu']
                                .length,
                            itemBuilder: (context, index) {
                              var data = (mainData['offerFromMenu']
                              as List)
                                  .where((element) =>
                              element['gender'] ==
                                  (currentUserData.data()[
                                  'gender'] ??
                                      'male') ||
                                  (element['gender'] ==
                                      "both" &&
                                      (currentUserData.data()[
                                      'gender'] ??
                                          'male') !=
                                          'others'))
                                  .toList()
                                  .first['menu'];
                              return Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "${data[index]['title'].toString().capitalize}",
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.white70)),
                                  const SizedBox(height: 25),
                                  Text("${data[index]['qty']}",
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.white70)),
                                ],
                              );
                              // return MenuComponent(data: mainData['offerFromMenu'][index], index: index);
                            },
                          )
                      ],
                    ),
                  ).marginOnly(
                      left: 30.w,
                      right: 30.w,
                      bottom: 00.h,
                      top: 00.h),
                const SizedBox(height: 10),
                Divider(),
                const SizedBox(height: 10),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Text(
                                  "Require deliverable from influencer (If any)",
                                  style: TextStyle(
                                      color: Colors.white)),
                              // SizedBox(width: 5),
                              // Text("*", style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          if (deliverable.length < 10)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  deliverable
                                      .add(TextEditingController());
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.white,
                                      width: 1),
                                ),
                                child: Icon(Icons.add,
                                    color: Colors.white, size: 16),
                              ),
                            )
                        ],
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        itemCount: deliverable.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: Get.width,
                            // height: 130.h,
                            margin:
                            EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                                borderRadius:
                                const BorderRadius.all(
                                    Radius.circular(20))),
                            // padding: EdgeInsets.only(left: 20.w, right: 20.w),
                            child: TextFormField(
                                minLines: 2,
                                maxLines: null,
                                controller: deliverable[index],
                                style: GoogleFonts.merriweather(
                                    color: Colors.white),
                                decoration: InputDecoration(
                                    alignLabelWithHint: true,
                                    contentPadding:
                                    EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 15),
                                    errorStyle:
                                    const TextStyle(height: 0),
                                    enabledBorder:
                                    const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white70,
                                          width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            10),
                                        borderSide:
                                        const BorderSide(
                                            color: Colors.blue,
                                            width: 1.0)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            10),
                                        borderSide:
                                        const BorderSide(
                                            color: Colors.red,
                                            width: 1.0)),
                                    hintStyle: GoogleFonts.ubuntu(),
                                    label: RichText(
                                      text: TextSpan(
                                          text:
                                          'Deliverable ${index + 1}',
                                          children: [
                                            TextSpan(
                                                text: '',
                                                style:
                                                const TextStyle(
                                                    color: Colors
                                                        .red))
                                          ]),
                                    ),
                                    suffixIcon: deliverable
                                        .length ==
                                        1
                                        ? null
                                        : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          deliverable
                                              .removeAt(
                                              index);
                                        });
                                      },
                                      child: Row(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        children: [
                                          VerticalDivider(),
                                          Icon(Icons.remove,
                                              color: Colors
                                                  .white,
                                              size: 20),
                                        ],
                                      ),
                                    ),
                                    // labelText: label + (isMandatory ? ' *' : ''),
                                    labelStyle: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 40.sp))),
                          );
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                textField('Script (if any)', scriptController),
                const SizedBox(height: 10),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Platform to be used",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17)),
                      Wrap(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: platformForPosting
                                    .contains("Instagram"),
                                onChanged: (value) {
                                  if (platformForPosting
                                      .contains("Instagram")) {
                                    platformForPosting
                                        .remove("Instagram");
                                  } else {
                                    platformForPosting
                                        .add("Instagram");
                                  }
                                  setState(() {});
                                },
                              ),
                              Text("Instagram",
                                  style: TextStyle(
                                      color: Colors.white))
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: platformForPosting
                                    .contains("Facebook"),
                                onChanged: (value) {
                                  if (platformForPosting
                                      .contains("Facebook")) {
                                    platformForPosting
                                        .remove("Facebook");
                                  } else {
                                    platformForPosting
                                        .add("Facebook");
                                  }
                                  setState(() {});
                                },
                              ),
                              Text("Facebook",
                                  style: TextStyle(
                                      color: Colors.white))
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: platformForPosting
                                    .contains("Youtube"),
                                onChanged: (value) {
                                  if (platformForPosting
                                      .contains("Youtube")) {
                                    platformForPosting
                                        .remove("Youtube");
                                  } else {
                                    platformForPosting
                                        .add("Youtube");
                                  }
                                  setState(() {});
                                },
                              ),
                              Text("Youtube",
                                  style: TextStyle(
                                      color: Colors.white))
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: platformForPosting
                                    .contains("Linkedin"),
                                onChanged: (value) {
                                  if (platformForPosting
                                      .contains("Linkedin")) {
                                    platformForPosting
                                        .remove("Linkedin");
                                  } else {
                                    platformForPosting
                                        .add("Linkedin");
                                  }
                                  setState(() {});
                                },
                              ),
                              Text("Linkedin",
                                  style: TextStyle(
                                      color: Colors.white))
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: platformForPosting
                                    .contains("Twitter"),
                                onChanged: (value) {
                                  if (platformForPosting
                                      .contains("Twitter")) {
                                    platformForPosting
                                        .remove("Twitter");
                                  } else {
                                    platformForPosting
                                        .add("Twitter");
                                  }
                                  setState(() {});
                                },
                              ),
                              Text("Twitter",
                                  style: TextStyle(
                                      color: Colors.white))
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // const Text("Promotional Data", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white)),
                      InkWell(
                        overlayColor:
                        WidgetStateProperty.resolveWith(
                                (states) => Colors.transparent),
                        onTap: () {
                          setState(() {
                            showAiData = !showAiData;
                          });
                        },
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Promotional Data",
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              !showAiData
                                  ? Icons.arrow_drop_down
                                  : Icons.arrow_drop_up,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                      if (showAiData)
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 15),
                            const Text("Suggestions",
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.grey,
                                      width: 0.5)),
                              child: Wrap(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(
                                            100),
                                        border: Border.all(
                                            color: Colors.grey,
                                            width: 0.5)),
                                    child: Text("Tags",
                                        style: TextStyle(
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text("Captions",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.grey,
                                      width: 0.5)),
                              child: Wrap(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(
                                            100),
                                        border: Border.all(
                                            color: Colors.grey,
                                            width: 0.5)),
                                    child: Text(
                                      "Tags",
                                      style: TextStyle(
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text("Post",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.grey,
                                      width: 0.5)),
                              child: Wrap(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(
                                            100),
                                        border: Border.all(
                                            color: Colors.grey,
                                            width: 0.5)),
                                    child: Text(
                                      "Tags",
                                      style: TextStyle(
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text("Captions for reels",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.grey,
                                      width: 0.5)),
                              child: Wrap(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(
                                            100),
                                        border: Border.all(
                                            color: Colors.grey,
                                            width: 0.5)),
                                    child: Text(
                                      "Tags",
                                      style: TextStyle(
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text("Suggested Hashtags",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.grey,
                                      width: 0.5)),
                              child: Wrap(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(
                                            100),
                                        border: Border.all(
                                            color: Colors.grey,
                                            width: 0.5)),
                                    child: Text(
                                      "Tags",
                                      style: TextStyle(
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
                // Padding(
                //   padding:
                //   const EdgeInsets.symmetric(horizontal: 20.0),
                //   child: InkWell(
                //     onTap: () {
                //       // Get.back();
                //       // Clipboard.setData(ClipboardData(text: url));
                //       Share.share("$url");
                //       print(url);
                //       showUrl = true;
                //       setState(() {});
                //     },
                //     child: Container(
                //         padding: EdgeInsets.symmetric(
                //             horizontal: 20, vertical: 10),
                //         decoration: BoxDecoration(
                //             color: Colors.orange,
                //             borderRadius:
                //             BorderRadius.circular(10)),
                //         child: Center(
                //             child: Text(
                //                 showUrl ? url : 'Generate URL',
                //                 style: TextStyle(
                //                     color: Colors.white)))),
                //   ).paddingSymmetric(vertical: 20.h),
                // ),
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     promotorTile(
            //       "Search Influencer",
            //       const Icon(
            //         FontAwesomeIcons.ad,
            //         color: Colors.white,
            //       ),
            //       condition: () {
            //         if (platformForPosting.isEmpty) {
            //           Fluttertoast.showToast(
            //               msg: "Select atleast one platform");
            //           return false;
            //         }
            //         // if(promotionalData.isEmpty){
            //         //   Fluttertoast.showToast(msg: "Select atleast one promotional data");
            //         //   return false;
            //         // }
            //         return true;
            //       },
            //       page: InfluencerPromotionList(
            //         eventPromotionId: widget.eventPromotionId,
            //         clubId: widget.clubId,
            //         deliverables:
            //         deliverable.map((e) => e.text).toList(),
            //         script: scriptController.text,
            //         platforms: platformForPosting,
            //         url: showUrl ? url : '',
            //         promotionalData: promotionalData,
            //       ),
            //     ),
            //     promotorTile(
            //         "Accepted Influencer List",
            //         const Icon(FontAwesomeIcons.rightFromBracket,
            //             color: Colors.white),
            //         page: AcceptInfluencerPromotionList(
            //           eventPromotionId: widget.eventPromotionId,
            //           clubId: widget.clubId,
            //         )),
            //     promotorTile(
            //         "Share",
            //         const Icon(
            //           FontAwesomeIcons.share,
            //           color: Colors.white,
            //         ),
            //         page: const OfferPromotionListInPromotor(
            //           isOrganiser: true,
            //         )),
            //   ],
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Expanded(child: Text(widget.data['pomotionData']['eventLink'].toString(),style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),)),
                      GestureDetector(
                          onTap: (){
                            Clipboard.setData(ClipboardData(text: url));
                            Fluttertoast.showToast(msg: 'Copy Url');
                          },
                          child: Icon(Icons.copy,color: Colors.white,))
                    ],
                  ),
                  SizedBox(height: 20,),
                  if(widget.data['pomotionData']['entryCoupon'].toString() !='null')
                    SizedBox(
                      // width: double.infinity,
                      child: Card(
                        color: const Color(0xff451F55),
                        // margin: const EdgeInsets.all(20),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category : ${jsonDecode(widget.data['pomotionData']['entryCoupon']??'{}')['couponCategory']??''}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                  Text(
                                    'Coupon Code : ${entryCoupon.text == ''  ?jsonDecode(widget.data['pomotionData']['entryCoupon']??'{}')['couponCode']??'':entryCoupon.text}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                  Text(
                                    'Discount : ${jsonDecode(widget.data['pomotionData']['entryCoupon']??'{}')['discount']??''}%',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  GestureDetector(
                                      onTap: (){
                                        Clipboard.setData(ClipboardData(text: '${entryCoupon.text == ''  ?jsonDecode(widget.data['pomotionData']['entryCoupon']??'{}')['couponCode']??'':entryCoupon.text}'));
                                        Fluttertoast.showToast(msg: 'Copy Url');
                                      },
                                      child: Icon(Icons.copy,color: Colors.white,)),
                                  // SizedBox(width: 20,),
                                  // GestureDetector(
                                  //     onTap: (){
                                  //
                                  //
                                  //       showDialog(context: context, builder: (context) {
                                  //         return editCoupon('Entry');
                                  //       },);
                                  //     },
                                  //     child: Icon(Icons.edit,color: Colors.white,))
                                ],
                              )
                              // SizedBox(width: 64.w),
                              // coupon.couponCode.toString() == widget.eventData['entryManagementCouponList']['couponCode'].toString()?
                              // GestureDetector(
                              //     onTap: (){
                              //       Clipboard.setData(ClipboardData(text: url));
                              //       Fluttertoast.showToast(msg: 'Copy Url');
                              //     },
                              //     child: Icon(Icons.copy,color: Colors.white,)):
                              // ElevatedButton(
                              //   onPressed: () async {
                              //     print("Event Id: ${widget.eventId}");
                              //     Map firebaseCategory = {
                              //       'Entry Management':
                              //       'entryManagementCouponList',
                              //       'Table Management':
                              //       'tableManagementCouponList'
                              //     };
                              //     try {
                              //       await FirebaseFirestore.instance
                              //           .collection('Events')
                              //           .doc(widget.eventId)
                              //           .set({
                              //         '${firebaseCategory[coupon.couponCategory]}':
                              //         coupon.toJson()
                              //       }, SetOptions(merge: true)).whenComplete(() =>widget.callback);
                              //     } catch (e) {
                              //       throw Exception('Error is $e');
                              //     }
                              //   },
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: Colors.white,
                              //     foregroundColor: const Color(0xff451F55),
                              //     shadowColor: Colors.blueGrey,
                              //     elevation: 10,
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(30), //
                              //     ),
                              //     padding: EdgeInsets.symmetric(
                              //       horizontal: 24.w,
                              //       vertical: 12.h,
                              //     ),
                              //   ),
                              //   child: const Text(
                              //     'Use',
                              //     style: TextStyle(
                              //       fontSize: 16,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ),
                    ),
                  if(widget.data['pomotionData']['entryCoupon'].toString() !='null')
                    Text('Offered Commission For Entry',style: TextStyle(color: Colors.white),),
                  if(widget.data['pomotionData']['entryCoupon'].toString() !='null')
                    textField('', infComissionController,isNum: true),
                  // const SizedBox(height: 20,),
                  if(widget.data['pomotionData']['tableCoupon'].toString() !='null')
                    SizedBox(
                      // width: double.infinity,
                      child: Card(
                        color: const Color(0xff451F55),
                        // margin: const EdgeInsets.all(20),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category : ${widget.data['pomotionData']['tableCoupon'].toString() !='null'? jsonDecode(widget.data['pomotionData']['tableCoupon']??'{}')['couponCode']:''}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                  Text(
                                    'Coupon Code : ${tableCoupon.text ==''?jsonDecode(widget.data['pomotionData']['tableCoupon']??'{}')['couponCode']??'':tableCoupon.text}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                  Text(
                                    'Discount : ${jsonDecode(widget.data['pomotionData']['tableCoupon']??'{}')['discount']??''}%',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                      onTap: (){
                                        Clipboard.setData(ClipboardData(text: '${tableCoupon.text ==''?jsonDecode(widget.data['pomotionData']['tableCoupon']??'{}')['couponCode']??'':tableCoupon.text}'));
                                        Fluttertoast.showToast(msg: 'Copy Url');
                                      },
                                      child: Icon(Icons.copy,color: Colors.white,)),
                                  // SizedBox(width: 20,),
                                  // GestureDetector(
                                  //     onTap: (){
                                  //       showDialog(context: context, builder: (context) {
                                  //         return editCoupon('Table');
                                  //       },);
                                  //     },
                                  //     child: Icon(Icons.edit,color: Colors.white,))
                                ],
                              )
                              // SizedBox(width: 64.w),
                              // coupon.couponCode.toString() == widget.eventData['entryManagementCouponList']['couponCode'].toString()?
                              // GestureDetector(
                              //     onTap: (){
                              //       Clipboard.setData(ClipboardData(text: url));
                              //       Fluttertoast.showToast(msg: 'Copy Url');
                              //     },
                              //     child: Icon(Icons.copy,color: Colors.white,)):
                              // ElevatedButton(
                              //   onPressed: () async {
                              //     print("Event Id: ${widget.eventId}");
                              //     Map firebaseCategory = {
                              //       'Entry Management':
                              //       'entryManagementCouponList',
                              //       'Table Management':
                              //       'tableManagementCouponList'
                              //     };
                              //     try {
                              //       await FirebaseFirestore.instance
                              //           .collection('Events')
                              //           .doc(widget.eventId)
                              //           .set({
                              //         '${firebaseCategory[coupon.couponCategory]}':
                              //         coupon.toJson()
                              //       }, SetOptions(merge: true)).whenComplete(() =>widget.callback);
                              //     } catch (e) {
                              //       throw Exception('Error is $e');
                              //     }
                              //   },
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: Colors.white,
                              //     foregroundColor: const Color(0xff451F55),
                              //     shadowColor: Colors.blueGrey,
                              //     elevation: 10,
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(30), //
                              //     ),
                              //     padding: EdgeInsets.symmetric(
                              //       horizontal: 24.w,
                              //       vertical: 12.h,
                              //     ),
                              //   ),
                              //   child: const Text(
                              //     'Use',
                              //     style: TextStyle(
                              //       fontSize: 16,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ),
                    ),
                  if(widget.data['pomotionData']['tableCoupon'].toString() !='null')
                  Text('Offered Commission For Table',style: TextStyle(color: Colors.white),),
                  if(widget.data['pomotionData']['tableCoupon'].toString() !='null')
                    textField('', infComissionTableController,isNum: true),

                  SizedBox(height: 20,),
                  InkWell(
                    onTap: ()async{
                      SharedPreferences pref = await SharedPreferences.getInstance();
                      String planData = pref.getString('planData') ?? '{}';
                      Map<String, dynamic> jsonConvert = jsonDecode(planData);

                      if (deliverable
                          .where((element) => element.text.isEmpty)
                          .toList()
                          .isNotEmpty) {
                        Fluttertoast.showToast(
                            msg: "Please fill all deliverables");
                        return;
                      }
                      Map<String, dynamic> sendData = {
                        'id': menuId,
                        'clubUID': widget.data['clubUID'].toString(),
                        "prId":uid(),
                        'eventId': widget.data['id'].toString(),
                        "invite": selectOption.value,
                        'influencerCommissionPercentage':infComissionController.text,
                        'influencerCommissionTablePercentage':infComissionTableController.text,
                        "eventName": widget.data['title'] ??'',
                        "noOfBarterCollab": widget.data['pomotionData']['noOfBarterCollab']??'',
                        'amountPaid': widget.data['pomotionData']['amountPaid']??'',
                        'deliverables': deliverable.map((e) => e.text).toList(),
                        'script': scriptController.text,
                        'offerFromMenu': widget.data['pomotionData']['offerFromMenu'],
                        "offeredBarterItem":'',
                        "startTime": widget.data['pomotionData']['startDate'],
                        "endTime": widget.data['pomotionData']['endDate'],
                        "isPaid": widget.data['pomotionData']['isPaid'],
                        "acceptedBy": 0,
                        "platforms": platformForPosting,
                        "url": widget.data['pomotionData']['url'],
                        "type": widget.data['pomotionData']['type'],
                        "collabType": "influencer",
                        'planId':jsonConvert['planId']??'',
                        "dateTime": FieldValue.serverTimestamp(),
                        "allDetail":widget.data,
                        "infOfferedForSale":infComissionController.text,
                      };
                      FirebaseFirestore.instance
                          .collection("EventPromotion")
                          .doc(menuId)
                          .set(sendData, SetOptions(merge: true))
                          .whenComplete(() async {
                      }).whenComplete(() {
                        print('check menu id is ${menuId}');
                        EasyLoading.dismiss();
                        // if (invite == 'inviteOnly') {
                        //   Get.to(InfluencerList(collabId: menuId));
                        // } else {
                          Get.back();
                        // }
                        Fluttertoast.showToast(
                            msg: "Upload Successfully");
                      });
                    },
                    child: Container(
                      width: 1.sw,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          // border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.all(Radius.circular(11))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text('Done',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),)
                          ],),
                      ),
                    ),
                  ),

                  // FutureBuilder<List<CouponModel>>(
                  //     future: sharedCouponList,
                  //     builder: (context, snapshot) {
                  //       if (snapshot.connectionState == ConnectionState.waiting) {
                  //         return const Center(child: CircularProgressIndicator());
                  //       } else if (snapshot.hasError) {
                  //         return Center(child: Text('Error: ${snapshot.error}'));
                  //       } else {
                  //         final data = snapshot.data ?? [];
                  //         print('check it is ${data}');
                  //         List<CouponModel> couponList = data
                  //             // .where(
                  //             //     (coupon) => coupon.couponCategory == widget.couponCategory)
                  //             .toList();
                  //         return Column(
                  //           children: [
                  //             ListItemCoupon(
                  //               callback: widget.callBack,
                  //                 title: 'Choose  Coupon',
                  //                 data: couponList,
                  //                 eventId: widget.data['id'].toString(), eventData: widget.data, ),
                  //           ],
                  //         );
                  //       }
                  //     }),
                  // InkWell(
                  //   onTap:showUrl?(){}: () {
                  //     print(url);
                  //     showUrl = true;
                  //     setState(() {});
                  //   },
                  //   child: Container(
                  //     width: 1.sw,
                  //       padding: EdgeInsets.symmetric(
                  //           horizontal: 0, vertical: 10),
                  //       decoration: BoxDecoration(
                  //           color: showUrl?Colors.grey:Colors.orange,
                  //           borderRadius:
                  //           BorderRadius.circular(10)),
                  //       child: Center(
                  //           child: Text(
                  //                'Generate URL',
                  //               style: TextStyle(
                  //                   color: Colors.white)))),
                  // ),
                  // if(showUrl)
                  //   SizedBox(height: 20,),
                  // if(showUrl)
                  //   GestureDetector(
                  //       onTap: (){
                  //         Share.share("$url");
                  //       },
                  //       child: Container(
                  //           decoration: BoxDecoration(
                  //               border: Border.all(color: Colors.grey),
                  //               borderRadius: BorderRadius.all(Radius.circular(11))),
                  //           child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Text(url,style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                  //       ))),
                  SizedBox(height: 20,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text("Share Now",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color: Colors.white),),
                  //   ],
                  // ),
                  // SizedBox(height: 30,),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //         child: InkWell(
                  //           onTap: (){
                  //             // Share.share("$url");
                  //             Get.bottomSheet(
                  //                 MessagePreviewBottomSheet(
                  //                   couponCode: entryCoupon.text == ''? jsonDecode(widget.data['pomotionData']['entryCoupon']??'{}')['couponCode']??'':entryCoupon.text,
                  //                   validFrom: jsonDecode(widget.data['pomotionData']['entryCoupon'])['validFrom']?? '',
                  //                   validUntil: jsonDecode(widget.data['pomotionData']['entryCoupon'])['validTill']?? '',
                  //                   couponCategory:entryCoupon.text ==''?widget.data['pomotionData']['entryCoupon'].toString() != 'null' ?
                  //                   jsonDecode(widget.data['pomotionData']['entryCoupon'])['couponCategory']?? '':'':entryCoupon.text,
                  //                   eventName: widget.data['title']?? ''.capitalizeFirstOfEach,
                  //                   eventData: DateFormat('dd/MM/yyyy').format((widget.data['date'] as Timestamp).toDate(),
                  //                   ),
                  //                   imageUrl: widget.data['coverImages'][0].toString(), eventUrl: widget.data['pomotionData']['eventLink'].toString(),
                  //                   tableCoupon: tableCoupon.text ==''?widget.data['pomotionData']['tableCoupon'].toString() != 'null'?jsonDecode(widget.data['pomotionData']['tableCoupon']??'{}')['couponCode']??'':'':tableCoupon.text,
                  //                 )
                  //             );
                  //           },
                  //           child: Container(
                  //             decoration: BoxDecoration(
                  //                 border: Border.all(color: Colors.grey),
                  //                 borderRadius: BorderRadius.all(Radius.circular(11))),
                  //             child: const Padding(
                  //               padding: EdgeInsets.all(10.0),
                  //               child: Icon(FontAwesomeIcons.whatsapp,color: Colors.green,size: 50,),
                  //             ),
                  //           ),
                  //         )),
                  //     SizedBox(width: 10,),
                  //     Expanded(
                  //         child: InkWell(
                  //           onTap: ()async{
                  //             print('check ${widget.data['coverImages'].length}');
                  //             if(widget.data['coverImages'].length == 1) {
                  //               final response = await http.get(Uri.parse(widget.data['coverImages'][0]));
                  //               final bytes = response.bodyBytes;
                  //               final tempDir = await getTemporaryDirectory();
                  //               final file = File(
                  //                   '${tempDir.path}/shared_image.jpg');
                  //               await file.writeAsBytes(bytes);
                  //               shareToInstagram(file.path,'image');
                  //
                  //             }else{
                  //               List<String> localPaths = [];
                  //               for (var i = 0; i < widget.data['coverImages'].length; i++) {
                  //                 final fileName = 'file_$i.${widget.data['coverImages'][i].split('.').last}';
                  //                 // final localPath = await downloadFile(widget.data['coverImages'][i], fileName);
                  //                 // localPaths.add(localPath);
                  //                 // shareMultipleToInstagram(localPaths);
                  //               }
                  //             }
                  //           },
                  //           child: Container(
                  //             decoration: BoxDecoration(
                  //                 border: Border.all(color: Colors.grey),
                  //                 borderRadius: BorderRadius.all(Radius.circular(11)
                  //               )
                  //             ),
                  //             child: Padding(
                  //                 padding: const EdgeInsets.all(10.0),
                  //                 child: Image.asset('assets/insta_icons.png',height: 50,width: 50,)
                  //               // Icon(FontAwesomeIcons.instagram,color: Color(0xFFE1306C),size: 50,),
                  //             ),
                  //           ),
                  //         )),
                  //   ],
                  // ),
                  // SizedBox(height: 40,),
                  // InkWell(
                  //   onTap: ()async{
                  //     Get.offAll(OrganiserHomeBar());
                  //   },
                  //   child: Container(
                  //     width: 1.sw,
                  //     decoration: BoxDecoration(
                  //         color: Colors.orangeAccent,
                  //         border: Border.all(color: Colors.grey),
                  //         borderRadius: BorderRadius.all(Radius.circular(11))),
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: Column(
                  //         children: [
                  //           Text('Back to Home',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),)
                  //         ],),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            )
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     tile(
            //         "Share",
            //         const Icon(
            //           FontAwesomeIcons.share,
            //           color: Colors.white,
            //         ),
            //         page: const OfferPromotionListInPromotor(isOrganiser: true,)),
            //
            //   ],
            // ),
                    ],
                  ),
          ),
    );
  }
}

Widget promotorTile(String title, Icon icon,
    {var page,
      bool Function() condition = defaultCondition,
      bool isLive = false,
      bool isEVM = false,
      bool isOrganiser = false}) =>
    GestureDetector(
        child: Container(
          height: 280.h,
          width: 280.h,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(color: Colors.grey, offset: Offset(0, 2.h), blurRadius: 3)
          ], color: Colors.black, borderRadius: BorderRadius.circular(30)),
          margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10, top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(
                height: 10,
              ),
              Text(
                title,
                style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        onTap: () async {
          if (!condition()) return;
          if (isOrganiser) {
            Get.bottomSheet(Container(
              height: 500.h,
              color: Colors.black,
              child: Column(
                children: [
                  Text(
                    "Choose",
                    style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold),
                  ).paddingAll(40.w),
                  ListTile(
                    onTap: () async {
                      const FlutterSecureStorage secureStorage =
                      FlutterSecureStorage();
                      String? value = await secureStorage.read(key: 'clubUids');
                      print('club id is ${value}');
                      Get.back();
                      Get.to( EventManagement(clubUID:value??''));
                    },
                    leading: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Add Event",
                      style: GoogleFonts.ubuntu(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Get.back();
                      Get.to(EventList(
                        isOrganiser: isOrganiser,
                      ));
                    },
                    leading: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Edit Event",
                      style: GoogleFonts.ubuntu(color: Colors.white),
                    ),
                  )
                ],
              ),
            ));
          } else {
            page != null
                ? Get.to(page)
                : isLive == true
                ? Get.to(const LiveStatus())
                : isEVM == true
                ? Get.bottomSheet(Container(
              height: 500.h,
              color: Colors.black,
              child: Column(
                children: [
                  Text(
                    "Choose",
                    style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold),
                  ).paddingAll(40.w),
                  ListTile(
                    onTap: () {
                      Get.back();
                      Get.to(const EventManagement());
                    },
                    leading: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Add Event",
                      style:
                      GoogleFonts.ubuntu(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Get.back();
                      Get.to(const EventList());
                    },
                    leading: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Edit Event",
                      style:
                      GoogleFonts.ubuntu(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
                : Fluttertoast.showToast(
                msg:
                "This feature will be available at launch of user's app.");
          }
        });

bool defaultCondition() => true;
