import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/InfluencerHome.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/arrow_pages/promotion_by_events_arrow.dart';
import 'package:club/screens/organiser/home/organiser_homeBar.dart';
import 'package:club/screens/pr_companies/widget/VenueCampaigns.dart';
import 'package:club/screens/pr_companies/widget/message_preview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../dynamic_link/dynamic_link.dart';
import '../../utils/app_utils.dart';
import '../coupon_code/controller/coupon_code_controller.dart';
import '../coupon_code/model/data/coupon_code_model.dart';
import 'package:club/screens/home/home_provider.dart';
import '../home/influencer_pages/influencer_requests.dart';
import '../organiser/event_management/promoter_page.dart';
import 'package:http/http.dart' as http;

import 'influencer_promotion.dart';
import 'influencer_request.dart';


class CampaignsTabBar extends StatefulWidget {
  final data;
  final String? id;
  final VoidCallback callBack;
  const CampaignsTabBar({super.key, this.data, required this.callBack, this.id});

  @override
  State<CampaignsTabBar> createState() => _CampaignsTabBarState();
}

class _CampaignsTabBarState extends State<CampaignsTabBar>
    with SingleTickerProviderStateMixin {
  final HomeController homeController = Get.put(HomeController());
  late TabController controller;
  TextEditingController uniqueName = TextEditingController();

  String? businessCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      uniqueIdGenerate();
      setBusinessCategory();
    });

    log('cchekc widget data is ${widget.data}');
  }


List  uniqueIdCoupon =[];
List  allUniqueId =[];

ValueNotifier<bool> isLoading = ValueNotifier(false);

  uniqueIdGenerate()async{
    print('check call this function');
    isLoading.value =true;
   var data =  await FirebaseFirestore.instance.collection('UniquePrId').get();
    allUniqueId = data.docs;
   List uniqueId = data.docs.where((e)=>getKeyValueFirestore(e, 'prId') ==uid()).toList();
    print('check this is ${uniqueId}');
   if(uniqueId.isEmpty){
     modalBottomSheet(context);
   }else{
     couponCodeNew.value =uniqueId[0]['couponId'].toString();
   }
   setState(() {});
    isLoading.value =false;
  }

  ValueNotifier<String?> couponCodeNew = ValueNotifier(null);

  void modalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Get.back(); 
            Get.back(); 
            return false; 
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),            child: Material(
              color: Colors.black54,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Please provide a unique name for the coupon code.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    textField('Enter your unique name', uniqueName, isMandatory: true,isWithOutSpace: true,isUpperCase: true),
                    const SizedBox(height: 10),
                    const Text(
                      'Note: One time name generation, cannot be changed further',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                            Get.back();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if(uniqueName.text.isEmpty){
                              Fluttertoast.showToast(msg: 'Please enter unique id');
                              return ;
                            }
                            List match = allUniqueId.where((e)=>getKeyValueFirestore(e, 'couponId') == uniqueName.text.toString()).toList();
                            if(match.isNotEmpty){
                              Fluttertoast.showToast(msg: 'The name already exists.');
                              return ;
                            }
                            FirebaseFirestore.instance.collection('UniquePrId').doc().set({
                              "prId":uid(),
                              "couponId":uniqueName.text
                            }).whenComplete(() {
                              Get.back();
                              Get.back();
                              Fluttertoast.showToast(msg: 'Update successful');
                            },);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: const Center(
                              child: Text(
                                'Update',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  setBusinessCategory() async {
    // businessCategory =
    // await const FlutterSecureStorage().read(key: "businessCategory");
    // if(businessCategory == "1"){
    //   controller = TabController(length: 3, vsync: this);
    // }else{
    controller = TabController(length: 2, vsync: this);
    // }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, bool loading, child) {
        if(loading){
          return Center(child: CircularProgressIndicator(color: Colors.orangeAccent,),);
        }
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar:  PreferredSize(
            preferredSize: Size.fromHeight(220.h),
            child: AppBar(
              automaticallyImplyLeading: true,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "PartyOn",
                    style: GoogleFonts.dancingScript(
                      color: Colors.red,
                      fontSize: 70.sp,
                    ),
                  ),
                  // SizedBox(
                  //   width: 400.w,
                  // ),
                  SizedBox(
                    width: 300.w,
                    child: Obx(() => Text(
                      homeController.clubName.value.capitalizeFirst
                          .toString(),
                      textAlign: TextAlign.end,
                      style: GoogleFonts.dancingScript(
                          color: Colors.white, fontSize: 70.sp),
                      overflow: TextOverflow.ellipsis,
                    )),
                  )
                ],
              ),
              bottom: TabBar(
                controller: controller,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: "My On"),
                  // Tab(text: "Influencer"),
                  Tab(text:  "All"),
                ],
              ),
              backgroundColor: Colors.black,
              shadowColor: Colors.grey,
            ),
          ),
          body:  DefaultTabController(
            length:  2 ,
            child: TabBarView(
              controller: controller,
              children: [
                ValueListenableBuilder(
                    valueListenable: couponCodeNew,
                    builder: (context, value, child) =>
                        CreateCamignsSecond(callBack: widget.callBack,data: widget.data,couponId: value ==null?'':value.toString(),)),
                // ValueListenableBuilder(
                //     valueListenable: couponCodeNew,
                //     builder: (context, value, child) =>
                //    InfluencerPromotion(
                //     eventPromotionId:widget.id !=null ?widget.id:
                //     widget.data['pomotionData']['id'],
                //     clubId: widget.data['clubUID'],
                //     data: widget.data,
                //     couponId: value ==null?'':value.toString(),
                //   ),
                // ),
                AllInfluencerRequest()
                // CreateCamignsSecond(callBack: widget.callBack,data: widget.data,),
              ],
            ),
          ),
        );
      },

    );
  }
}


class CreateCamignsSecond extends StatefulWidget {
  final bool isInf;
  final data;
  final String? couponId;
  final VoidCallback callBack;

  const CreateCamignsSecond({super.key, this.data, required this.callBack,this.isInf = false, this.couponId});

  @override
  State<CreateCamignsSecond> createState() => _CreateCamignsSecondState();
}

class _CreateCamignsSecondState extends State<CreateCamignsSecond> {
  String url ='';
  bool showUrl= false;
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

  Future<String> downloadFile(String url, String fileName, {String defaultExtension = 'jpg'}) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName.$defaultExtension'; // Add a default extension if missing

      // Force content type detection and append extension dynamically
      final response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
      final fileType = response.headers['content-type']?.first ?? 'application/octet-stream';

      String actualExtension;
      if (fileType.startsWith('image')) {
        actualExtension = 'jpg'; // You can refine this further
      } else if (fileType.startsWith('video')) {
        actualExtension = 'mp4'; // Default for videos
      } else {
        actualExtension = defaultExtension; // Fallback
      }

      // Update file path with the detected extension
      final updatedFilePath = '${dir.path}/$fileName.$actualExtension';

      // Write the file
      final file = File(updatedFilePath);
      await file.writeAsBytes(response.data);

      return updatedFilePath;
    } catch (e) {
      print('Error downloading file: $e');
      rethrow;
    }
  }

List prCouponData = [];
  fetchPrPromotion()async{
    final data;
    if(widget.isInf){
      data =  await FirebaseFirestore.instance.collection('CouponPR').where('infId',isEqualTo: uid()).where('eventId',isEqualTo: widget.data['allDetail']['pomotionData']['eventId'].toString()).where('isInf',isEqualTo: true).get();
    }else{
   data =  await FirebaseFirestore.instance.collection('CouponPR').where('prId',isEqualTo: uid()).where('eventId',isEqualTo: widget.data['pomotionData']['eventId'].toString()).where('isInf',isEqualTo: false).get();
    }
  prCouponData = data.docs;
  print('check coupon list is ${prCouponData}');
  for(var data in prCouponData){
    print(data.id);
  }
    setState(() {});
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    log('check is ${widget.data}');
    // createUrl();
    sharedCoupon();
      updateCouponCodePr();
      fetchPrPromotion();
      if(!widget.isInf){
        createUrl();
      }
    print('check image is ${widget.data}');
  }


  String fillerCouponCode ='';
  updateCouponCodePr()async{
   final promoData = widget.isInf ?widget.data['allDetail']['pomotionData']:widget.data['pomotionData']  ?? {};
   String discount = widget.isInf ?widget.data['influencerCommissionPercentage']??jsonDecode(promoData['entryCoupon'] ?? '{}')['discount']?.toString(): jsonDecode(promoData['entryCoupon'] ?? '{}')['discount']?.toString() ?? '';
   String tableDiscount = widget.isInf ?widget.data['influencerCommissionTablePercentage']??jsonDecode(promoData['tableCoupon'] ?? '{}')['discount']?.toString() ?? '':jsonDecode(promoData['tableCoupon'] ?? '{}')['discount']?.toString() ?? '';
   String companyName =widget.couponId.toString();
   String finalCode = 'PARTYON' + companyName + discount;
   String tableCode  = companyName + 'PARTYON' + tableDiscount;

    print('tesing check ${promoData.containsKey('tableCoupon')}');
    entryCoupon.text = promoData['entryCoupon'].toString() != 'null'
        ? finalCode
        : '';
    tableCoupon.text = promoData['tableCoupon'].toString() != 'null' ? tableCode
        : '';
   fillerCouponCode = 'PARTYON' + companyName;
   setState(() {
   });
  }


  void createUrl() async {
    url = await FirebaseDynamicLinkEvent.createDynamicLink(
      short: true,
      // clubUID: isClub ? uid() : data['clubUID'] ?? '',
      clubUID: widget.data['clubUID'],
      eventID: widget.data['pomotionData']['eventId'],
      organiserID: uid().toString(),
      promoterID: uid().toString(),
    );
print('check url is ${url}');
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.black,
        appBar:widget.isInf? appBar(context, title: "", ):PreferredSize(preferredSize: Size.fromHeight(0), child: AppBar()),
        body:Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child:SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Event Details",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 16),),
                SizedBox(height: 10,),
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
                            imageUrl:widget.isInf?  widget.data['allDetail']['coverImages'][0].toString():widget.data['coverImages'][0].toString(), // Use the first image in the list
                            // placeholder: (_, __) => const Center(
                            //   child: CircularProgressIndicator(color: Colors.orange),
                            // ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // AspectRatio(
                //     aspectRatio: 9/13,
                //     child: Image.network(widget.data['coverImages'][0].toString(),fit: BoxFit.fill,)),
               SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.isInf?widget.data['allDetail']['title'].toString().capitalizeFirstOfEach:widget.data['title'].toString().capitalizeFirstOfEach,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),),
                    Text("Date : ${DateFormat('dd/MM/yyyy').format((widget.isInf ?widget.data['allDetail']['date'] as Timestamp:widget.data['date'] as Timestamp).toDate(),)}",
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          fontSize: 16),
                    ),
                  ],
                ),
                Text(widget.isInf?widget.data['allDetail']['briefEvent'].toString():widget.data['briefEvent'].toString(),style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white,fontSize: 14),),
                SizedBox(height: 10,),
                Text(widget.isInf?widget.data['allDetail']['artistName'].toString():widget.data['artistName'].toString(),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(child: Text(widget.isInf?widget.data['allDetail']['pomotionData']['eventLink'].toString():url,style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),)),
                    GestureDetector(
                        onTap: (){
                          Clipboard.setData(ClipboardData(text: url));
                          Fluttertoast.showToast(msg: 'Copy Url');
                        },
                        child: Icon(Icons.copy,color: Colors.white,))
                  ],
                ),
                SizedBox(height: 20,),
                if ((jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']??'{}':widget.data['pomotionData']['entryCoupon']??'{}')['couponCategory']??''
                ).toString() != 'null')
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
                                'Category : ${jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']??'{}':widget.data['pomotionData']['entryCoupon']??'{}')['couponCategory']??''}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 40.sp),
                              ),
                              Text(
                                'Coupon Code : ${entryCoupon.text == ''  ?jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']??'{}':widget.data['pomotionData']['entryCoupon']??'{}')['couponCode']??'':entryCoupon.text}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 40.sp),
                              ),
                              Text(
                                'Commission : ${
                                    widget.isInf?
                                    widget.data['allDetail']['pomotionData']['infOfferedForSale'] !=null?
                                    widget.data['allDetail']['pomotionData']['infOfferedForSale'].toString():
                                        jsonDecode(widget.data['allDetail']['pomotionData']['entryCoupon']??{})['discount']:
                                    widget.data['pomotionData']['offeredCommissionPr'] !=null?widget.data['pomotionData']['offeredCommissionPr'].toString():
                                    jsonDecode(widget.data['pomotionData']['entryCoupon']??'{}')['discount']??''}%',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 40.sp),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              GestureDetector(
                                  onTap: (){
                                    Clipboard.setData(ClipboardData(text: '${entryCoupon.text == ''  ?jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']??'{}':widget.data['pomotionData']['entryCoupon']??'{}')['couponCode']??'':entryCoupon.text}'));
                                    Fluttertoast.showToast(msg: 'Copy Url');
                                  },
                                  child: Icon(Icons.copy,color: Colors.white,)),
                              // SizedBox(width: 20,),
                              // GestureDetector(
                              //     onTap: (){
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
                SizedBox(height: 20,),

                if ((
                    widget.isInf?jsonDecode(widget.data['allDetail']['pomotionData']['tableCoupon'])['couponCategory']:widget.data['pomotionData']['tableCoupon'].toString() !='null'? jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon']??'{}':widget.data['pomotionData']['tableCoupon']??'{}')['couponCategory']:''
                ).toString() != 'null')
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
                                'Category : ${widget.isInf?jsonDecode(widget.data['allDetail']['pomotionData']['tableCoupon'])['couponCategory']:widget.data['pomotionData']['tableCoupon'].toString() !='null'? jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon']??'{}':widget.data['pomotionData']['tableCoupon']??'{}')['couponCategory']:''}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 40.sp),
                              ),
                              Text(
                                'Coupon Code : ${tableCoupon.text ==''?jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon']??'{}':widget.data['pomotionData']['tableCoupon']??'{}')['couponCode']??'':tableCoupon.text}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 40.sp),
                              ),
                              Text(
                                'Commission : ${
                                    widget.isInf?
                                    widget.data['allDetail']['pomotionData']['infOfferedForSale']!=null?
                                    widget.data['allDetail']['pomotionData']['infOfferedForSale'].toString():
                                    jsonDecode(widget.data['allDetail']['pomotionData']['tableCoupon']??'{}')['discount']??'':
                                    widget.data['pomotionData']['offeredCommissionTablePr'] !=null?
                                    widget.data['pomotionData']['offeredCommissionTablePr']:
                                    jsonDecode(widget.data['pomotionData']['tableCoupon']??'{}')['discount']??''}%',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 40.sp),
                              ),
                            ],
                          ),
                     Row(
                       children: [
                         GestureDetector(
                             onTap: (){
                               Clipboard.setData(ClipboardData(text: '${tableCoupon.text ==''?jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon']??'{}':widget.data['pomotionData']['tableCoupon']??'{}')['couponCode']??'':tableCoupon.text}'));
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
                SizedBox(height: 20,),

                if(prCouponData.isEmpty)
                InkWell(
                  onTap: ()async{
                    dynamic entryCouponRaw = widget.isInf
                        ? widget.data['allDetail']['pomotionData']['entryCoupon']
                        : widget.data['pomotionData']['entryCoupon'];

                    Map<String, dynamic>? data = (entryCouponRaw != null && entryCouponRaw.toString() != 'null')
                        ? jsonDecode(entryCouponRaw.toString())
                        : null;

                    dynamic tableCouponRaw = widget.isInf
                        ? widget.data['allDetail']['pomotionData']['tableCoupon']
                        : widget.data['pomotionData']['tableCoupon'];

                    Map<String, dynamic>? tableCoupons = (tableCouponRaw != null && tableCouponRaw.toString() != 'null')
                        ? jsonDecode(tableCouponRaw.toString())
                        : null;

                    if (data != null) {
                      data['couponCode'] = entryCoupon.text ?? '';
                    }

                    if (tableCoupons != null) {
                      tableCoupons['couponCode'] = tableCoupon.text ?? '';
                    }
                    await FirebaseFirestore.instance
                        .collection('CouponPR')
                        .doc()
                        .set(widget.isInf?{
                      "clubUID":widget.isInf?widget.data['allDetail']['pomotionData']['clubUID']:widget.data['pomotionData']['clubUID'],
                      'infId':uid(),
                      'isInf':widget.isInf,
                      'entryCoupon': data,
                      'tableCoupon':tableCoupons,
                      'totalUseCoupon':0,
                      'totalUseCouponTable':0,
                      'data':widget.data,
                      'eventId':widget.data['allDetail']['pomotionData']['eventId'],
                    }:{
                      "clubUID":widget.isInf?widget.data['pomotionData']['clubUID']:widget.data['pomotionData']['clubUID'],
                      'prId':uid(),
                      'eventId':widget.data['pomotionData']['eventId'],
                      'entryCoupon': data,
                      'isInf':widget.isInf,
                      'tableCoupon':tableCoupons,
                      'totalUseCoupon':0,
                      'totalUseCouponTable':0,
                      'data':widget.data,
                      'filler':fillerCouponCode,
                    }).catchError((e){
                      Fluttertoast.showToast(msg: e.toString());
                    }).whenComplete(() async {
                      if(!widget.isInf){
                        await FirebaseFirestore.instance.collection('PrAnalytics').doc().set({
                         'eventId':widget.data['pomotionData']['eventId'],
                          'prId':uid(),
                          'venueId':widget.data['clubUID'].toString(),
                          "noOfView":0,
                          "noOfReserved":0,
                          "noOfClick":0,
                        });
                      }
                      fetchPrPromotion();
                      Fluttertoast.showToast(msg: 'Update completed successfully.');
                    });
                    // }
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
                if(prCouponData.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Share Now",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color: Colors.white),),
                  ],
                ),
                if(prCouponData.isNotEmpty)
                SizedBox(height: 30,),
                if(prCouponData.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                        child: InkWell(
                          onTap: (){
                            // Share.share("$url");
                            Get.bottomSheet(bottomSheet('whatsaap'));
                            // Get.bottomSheet(
                            //     MessagePreviewBottomSheet(
                            //        couponCode: entryCoupon.text == ''? jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']??'{}':widget.data['pomotionData']['entryCoupon']??'{}')['couponCode']??'':entryCoupon.text,
                            //         validFrom: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['validFrom']?? '',
                            //          validUntil: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['validTill']?? '',
                            //          couponCategory:entryCoupon.text ==''?widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon'].toString():widget.data['pomotionData']['entryCoupon'].toString() != 'null' ?
                            //          jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['couponCategory']?? '':'':entryCoupon.text,
                            //          eventName: widget.isInf?widget.data['title']?? '':widget.data['title']?? ''.capitalizeFirstOfEach,
                            //          eventData: DateFormat('dd/MM/yyyy').format((widget.isInf?widget.data['allDetail']['date']:widget.data['date'] as Timestamp).toDate(),
                            // ),
                            //       imageUrl:widget.isInf? widget.data['allDetail']['coverImages'][0].toString(): widget.data['coverImages'][0].toString(),
                            //       eventUrl:widget.isInf? widget.data['allDetail']['pomotionData']['eventLink'].toString():url,
                            //       tableCoupon: tableCoupon.text ==''?widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon'].toString():widget.data['pomotionData']['tableCoupon'].toString() != 'null'?jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon']??'{}':widget.data['pomotionData']['tableCoupon']??'{}')['couponCode']??'':'':tableCoupon.text,
                            //       discountPercentage: widget.data['entryManagementCouponList']['discount'],
                            // )
                            // );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.all(Radius.circular(11))),
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(FontAwesomeIcons.whatsapp,color: Colors.green,size: 50,),
                            ),
                          ),
                        )),
                    SizedBox(width: 10,),
                    Expanded(
                        child: InkWell(
                          onTap: ()async{
                          Get.bottomSheet(  bottomSheet('insta'));
                            // print('check ${widget.isInf }');
                            // int coverImageLength = widget.isInf ? widget.data['allDetail']['coverImages'].length : widget.data['coverImages'].length ;
                            // if(coverImageLength == 1){
                            //   final response = await http.get(Uri.parse(widget.isInf?widget.data['allDetail']['coverImages'][0]:widget.data['coverImages'][0]));
                            //   final bytes = response.bodyBytes;
                            //   final tempDir = await getTemporaryDirectory();
                            //   final file = File(
                            //       '${tempDir.path}/shared_image.jpg');
                            //   await file.writeAsBytes(bytes);
                            //   shareToInstagram(file.path,'image');
                            //
                            // }else{
                            //   List<String> localPaths = [];
                            //   int imageLength = widget.isInf ?widget.data['allDetail']['coverImages'].length:widget.data['coverImages'].length;
                            //   for (var i = 0; i < imageLength; i++) {
                            //     final fileName = 'file_$i.${widget.isInf ?widget.data['allDetail']['coverImages'][i].split('.').last:widget.data['coverImages'][i].split('.').last}';
                            //     final localPath = await downloadFile(widget.isInf?widget.data['allDetail']['coverImages'][i]:widget.data['coverImages'][i], fileName);
                            //     localPaths.add(localPath);
                            //     shareMultipleToInstagram(localPaths);
                            //   }
                            // }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.all(Radius.circular(11))),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset('assets/insta_icons.png',height: 50,width: 50,)
                              // Icon(FontAwesomeIcons.instagram,color: Color(0xFFE1306C),size: 50,),
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(height: 40,),
                InkWell(
                  onTap: ()async{
                    if(widget.isInf){
                      Get.offAll(InfluencerHome());
                    }else{
                    Get.offAll(OrganiserHomeBar());
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
                      child: Column(
                        children: [
                          Text('Back to Home',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),)
                        ],),
                    ),
                  ),
                ),
              ],
            ),
          )
        )
    );
  }

  TextEditingController entryCoupon = TextEditingController();
  TextEditingController tableCoupon = TextEditingController();


  Widget bottomSheet(String type){
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30,),
            InkWell(
              onTap: () async {
                Get.back();
                if(type != 'insta') {
                  Get.bottomSheet(
                        MessagePreviewBottomSheet(
                          couponCode: fillerCouponCode,
                            validFrom: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['validFrom']?? '',
                             validUntil: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['validTill']?? '',
                             couponCategory:'Filler' ,
                             eventName: widget.isInf?widget.data['title']?? '':widget.data['title']?? ''.capitalizeFirstOfEach,
                             eventData: DateFormat('dd/MM/yyyy').format((widget.isInf?widget.data['allDetail']['date']:widget.data['date'] as Timestamp).toDate(),
                           ),
                          imageUrl:widget.isInf? widget.data['allDetail']['coverImages'][0].toString(): widget.data['coverImages'][0].toString(),
                          eventUrl:widget.isInf? widget.data['allDetail']['pomotionData']['eventLink'].toString():url,
                          tableCoupon: widget.isInf?widget.data['allDetail']['pomotionData']['fillerCouponCode']??'':widget.data['pomotionData']['fillerCouponCode']??'',
                          discountPercentage: '100',
                          type: 'filler',
                    )
                  );
                }else{
                  Get.bottomSheet(
                      InstagramShare(
                        couponCode: fillerCouponCode,
                        validFrom: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['validFrom']?? '',
                        validUntil: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['validTill']?? '',
                        couponCategory:'Filler' ,
                        eventName: widget.isInf?widget.data['title']?? '':widget.data['title']?? ''.capitalizeFirstOfEach,
                        eventData: DateFormat('dd/MM/yyyy').format((widget.isInf?widget.data['allDetail']['date']:widget.data['date'] as Timestamp).toDate(),
                        ),
                        imageUrl:widget.isInf? widget.data['allDetail']['coverImages'][0].toString(): widget.data['coverImages'][0].toString(),
                        eventUrl:widget.isInf? widget.data['allDetail']['pomotionData']['eventLink'].toString():url,
                        discountPercentage: '100',
                        type: 'Filler',
                      ));
                 }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Column(
                  children: [
                    Text(
                      'Filler',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
            if ((jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']??'{}':widget.data['pomotionData']['entryCoupon']??'{}')['couponCategory']??''
            ).toString() != 'null')
            InkWell(
              onTap: () async {
                Get.back();
                if(type != 'insta') {
                  Get.bottomSheet(
                        MessagePreviewBottomSheet(
                           couponCode: entryCoupon.text == ''? jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']??'{}':widget.data['pomotionData']['entryCoupon']??'{}')['couponCode']??'':entryCoupon.text,
                            validFrom: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['validFrom']?? '',
                             validUntil: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['validTill']?? '',
                             couponCategory:entryCoupon.text ==''?widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon'].toString():widget.data['pomotionData']['entryCoupon'].toString() != 'null' ?
                             jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['couponCategory']?? '':'':entryCoupon.text,
                             eventName: widget.isInf?widget.data['title']?? '':widget.data['title']?? ''.capitalizeFirstOfEach,
                             eventData: DateFormat('dd/MM/yyyy').format((widget.isInf?widget.data['allDetail']['date']:widget.data['date'] as Timestamp).toDate(),
                    ),
                          imageUrl:widget.isInf? widget.data['allDetail']['coverImages'][0].toString(): widget.data['coverImages'][0].toString(),
                          eventUrl:widget.isInf? widget.data['allDetail']['pomotionData']['eventLink'].toString():url,
                          tableCoupon: tableCoupon.text ==''?widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon'].toString():widget.data['pomotionData']['tableCoupon'].toString() != 'null'?jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon']??'{}':widget.data['pomotionData']['tableCoupon']??'{}')['couponCode']??'':'':tableCoupon.text,
                          discountPercentage: widget.data['entryManagementCouponList']['discount'],
                    )
                      // MessagePreviewBottomSheet(
                      //   couponCode: widget
                      //       .data['entryManagementCouponList']['couponCode'] ??
                      //       '',
                      //   validFrom: widget
                      //       .data['entryManagementCouponList']['validFrom'] ??
                      //       '',
                      //   validUntil: widget
                      //       .data['entryManagementCouponList']['validTill'] ??
                      //       '',
                      //   couponCategory: widget
                      //       .data['entryManagementCouponList']['couponCategory'] ??
                      //       '',
                      //   eventName: widget.data['title'] ?? '',
                      //   eventData: DateFormat('dd/MM/yyyy').format(
                      //     (widget.data['date'] as Timestamp).toDate(),
                      //   ),
                      //   imageUrl: widget.data['coverImages'][0].toString(),
                      //   eventUrl: url,
                      //   tableCoupon: widget
                      //       .data['tableManagementCouponList']['couponCode'] ??
                      //       '',
                      //   type: 'entry',
                      //   discountPercentage: widget
                      //       .data['entryManagementCouponList']['discount'] ??
                      //       '',
                      // )
                  );
                }else{
                  Get.bottomSheet(
                      InstagramShare(
                          couponCode: entryCoupon.text == ''? jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']??'{}':widget.data['pomotionData']['entryCoupon']??'{}')['couponCode']??'':entryCoupon.text,
                          validFrom: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['validFrom']?? '',
                          validUntil: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['validTill']?? '',
                          couponCategory:entryCoupon.text ==''?widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon'].toString():widget.data['pomotionData']['entryCoupon'].toString() != 'null' ?
                          jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['couponCategory']?? '':'':entryCoupon.text,
                          eventName: widget.isInf?widget.data['title']?? '':widget.data['title']?? ''.capitalizeFirstOfEach,
                          eventData: DateFormat('dd/MM/yyyy').format((widget.isInf?widget.data['allDetail']['date']:widget.data['date'] as Timestamp).toDate(),
                          ),
                          imageUrl:widget.isInf? widget.data['allDetail']['coverImages'][0].toString(): widget.data['coverImages'][0].toString(),
                          eventUrl:widget.isInf? widget.data['allDetail']['pomotionData']['eventLink'].toString():url,
                          discountPercentage: widget.data['entryManagementCouponList']['discount'],
                          type: 'entry',

                      ));
                }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Column(
                  children: [
                    Text(
                      'Entry Management',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
            if ((
                widget.isInf?jsonDecode(widget.data['allDetail']['pomotionData']['tableCoupon'])['couponCategory']:widget.data['pomotionData']['tableCoupon'].toString() !='null'? jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon']??'{}':widget.data['pomotionData']['tableCoupon']??'{}')['couponCategory']:''
            ).toString() != 'null')
            InkWell(
              onTap: () async {
                Get.back();
                Get.bottomSheet(
                    type != 'insta'?
                    MessagePreviewBottomSheet(
                      couponCode: entryCoupon.text == ''? jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']??'{}':widget.data['pomotionData']['entryCoupon']??'{}')['couponCode']??'':entryCoupon.text,
                      validFrom: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['validFrom']?? '',
                      validUntil: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['validTill']?? '',
                      couponCategory:entryCoupon.text ==''?widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon'].toString():widget.data['pomotionData']['entryCoupon'].toString() != 'null' ?
                      jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['entryCoupon']:widget.data['pomotionData']['entryCoupon'])['couponCategory']?? '':'':entryCoupon.text,
                      eventName: widget.isInf?widget.data['title']?? '':widget.data['title']?? ''.capitalizeFirstOfEach,
                      eventData: DateFormat('dd/MM/yyyy').format((widget.isInf?widget.data['allDetail']['date']:widget.data['date'] as Timestamp).toDate(),
                      ),
                      imageUrl:widget.isInf? widget.data['allDetail']['coverImages'][0].toString(): widget.data['coverImages'][0].toString(),
                      eventUrl:widget.isInf? widget.data['allDetail']['pomotionData']['eventLink'].toString():url,
                      tableCoupon: tableCoupon.text ==''?widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon'].toString():widget.data['pomotionData']['tableCoupon'].toString() != 'null'?jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon']??'{}':widget.data['pomotionData']['tableCoupon']??'{}')['couponCode']??'':'':tableCoupon.text,
                      discountPercentage: widget.data['entryManagementCouponList']['discount'],
                  type: 'table',
                    ):

                    InstagramShare(
                        couponCode:tableCoupon.text ==''?widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon'].toString():widget.data['pomotionData']['tableCoupon'].toString() != 'null'?jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon']??'{}':widget.data['pomotionData']['tableCoupon']??'{}')['couponCode']??'':'':tableCoupon.text,
                      validFrom: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon']:widget.data['pomotionData']['tableCoupon'])['validFrom']?? '',
                      validUntil: jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon']:widget.data['pomotionData']['tableCoupon'])['validTill']?? '',
                      couponCategory:entryCoupon.text ==''?widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon'].toString():widget.data['pomotionData']['tableCoupon'].toString() != 'null' ?
                      jsonDecode(widget.isInf?widget.data['allDetail']['pomotionData']['tableCoupon']:widget.data['pomotionData']['tableCoupon'])['couponCategory']?? '':'':entryCoupon.text,
                      eventName: widget.isInf?widget.data['title']?? '':widget.data['title']?? ''.capitalizeFirstOfEach,
                      eventData: DateFormat('dd/MM/yyyy').format((widget.isInf?widget.data['allDetail']['date']:widget.data['date'] as Timestamp).toDate(),
                      ),
                      imageUrl:widget.isInf? widget.data['allDetail']['coverImages'][0].toString(): widget.data['coverImages'][0].toString(),
                      eventUrl:widget.isInf? widget.data['allDetail']['pomotionData']['eventLink'].toString():url,
                      discountPercentage: widget.data['entryManagementCouponList']['discount'],
                      type: 'table',
                   )
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Column(
                  children: [
                    Text(
                      'Table Management',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

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
}

class ListItemCoupon extends StatefulWidget {
  final List<CouponModel> data;
  final VoidCallback callback;
  final String title;
  final String eventId;
  final eventData;

  const ListItemCoupon(
      {super.key,
        required this.data,
        // required this.widget,
        required this.eventData,
        required this.title, required this.eventId, required this.callback});

  @override
  State<ListItemCoupon> createState() => _ListItemCouponState();
}

class _ListItemCouponState extends State<ListItemCoupon> {
  ValueNotifier<String> copyIcon = ValueNotifier('');
  String url = '';

  void createUrl() async {
    url = await FirebaseDynamicLinkEvent.createDynamicLink(
      short: true,
      // clubUID: isClub ? uid() : data['clubUID'] ?? '',
      clubUID: widget.eventData['clubUID'],
      eventID: widget.eventData['pomotionData']['promotionId'],
      organiserID: uid().toString(),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    if (widget.data.isNotEmpty) {
      print('check event id is ${widget.eventId.toString}');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.zero.copyWith(left: 52.w),
            child: Text(widget.title,
                style: TextStyle(fontSize: 40.sp, color: Colors.white)),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: widget.data.length,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final coupon = widget.data[index];
                final discount = coupon.discount;
                // discountCodeList.removeAt(0);
                return Column(
                  children: [
                    SizedBox(
                      // width: double.infinity,
                      child: Card(
                        color: const Color(0xff451F55),
                        margin: const EdgeInsets.all(20),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category : ${coupon.couponCategory}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                  Text(
                                    'Coupon Code : ${coupon.couponCode}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                  Text(
                                    'Discount : $discount%',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                ],
                              ),
                              SizedBox(width: 64.w),
                            coupon.couponCode.toString() == widget.eventData['entryManagementCouponList']['couponCode'].toString()?
                                GestureDetector(
                                    onTap: (){
                                      Clipboard.setData(ClipboardData(text: url));
                                      Fluttertoast.showToast(msg: 'Copy Url');
                                    },
                                    child: Icon(Icons.copy,color: Colors.white,)):
                                ElevatedButton(
                                onPressed: () async {
                                  print("Event Id: ${widget.eventId}");
                                  Map firebaseCategory = {
                                    'Entry Management':
                                    'entryManagementCouponList',
                                    'Table Management':
                                    'tableManagementCouponList'
                                  };
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('Events')
                                        .doc(widget.eventId)
                                        .set({
                                      '${firebaseCategory[coupon.couponCategory]}':
                                      coupon.toJson()
                                    }, SetOptions(merge: true)).whenComplete(() =>widget.callback);
                                  } catch (e) {
                                    throw Exception('Error is $e');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xff451F55),
                                  shadowColor: Colors.blueGrey,
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30), //
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 12.h,
                                  ),
                                ),
                                child: const Text(
                                  'Use',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ],
      );
    } else {
      return Center(
        child: Card(
          color: const Color(0xff451F55),
          margin: const EdgeInsets.all(16),
          child: Text(
            'No Saved Coupons found!',
            style: TextStyle(color: Colors.white, fontSize: 48.sp),
          ),
        ),
      );
    }
  }
}
