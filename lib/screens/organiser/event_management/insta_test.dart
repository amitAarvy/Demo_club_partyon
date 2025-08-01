// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:club/screens/bookings/booking_details.dart';
// import 'package:club/screens/event_management/promotion_list.dart';
// import 'package:club/screens/event_management/venue_promotion_create.dart';
// import 'package:club/utils/app_utils.dart';
// import 'package:club/screens/bookings/booking_list.dart';
// import 'package:club/screens/home/home_provider.dart';
// import 'package:club/screens/home/home_utils.dart';
// import 'package:club/utils/qr_generator.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:club/dynamic_link/dynamic_link.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:insta_login/insta_login.dart';
// import 'package:insta_login/insta_view.dart';
// import 'package:share_plus/share_plus.dart';
//
// import '../../event_management/create_event_promotion.dart';
// import 'InfoWidget.dart';
// import 'list_promotion_in_organiser.dart';
// import 'promotion_detail.dart';
//
// class TestInsta extends StatefulWidget {
//   final bool isOrganiser;
//   final bool isPromoter;
//   final bool isClub;
//
//   const TestInsta(
//       {Key? key,
//       this.isOrganiser = false,
//       this.isPromoter = false,
//       this.isClub = false})
//       : super(key: key);
//
//   @override
//   State<TestInsta> createState() => _HomeState();
// }
//
// class _HomeState extends State<TestInsta> {
//   String token = '', userid = '', username = '', accountType = '';
//   int mediaCount = -1;
//   List<dynamic> mediaList = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Connect to Instagram')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//
//             if (token != '' || userid != '' || username != '')
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Center(
//                         child: Text(
//                           '------Instagram Connected------',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                       InfoWidget(title: 'Access Token', subtitle: token),
//                       InfoWidget(title: 'Userid', subtitle: userid),
//                       InfoWidget(title: 'Username', subtitle: username),
//                       const SizedBox(height: 10),
//                       if (accountType != '' || mediaCount != -1)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Center(
//                               child: Text(
//                                 '------Basic Profile Details------',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                             ),
//                             InfoWidget(
//                               title: 'Media Count',
//                               subtitle: mediaCount.toString(),
//                             ),
//                             InfoWidget(
//                               title: 'Account Type',
//                               subtitle: accountType,
//                             ),
//                           ],
//                         )
//                       else
//                         Center(
//                           child: ElevatedButton(
//                             onPressed: () async {
//                               await Instaservices()
//                                   .getContent(
//                                       accesstoken: token, userid: userid)
//                                   .then((value) {
//                                 if (value != null) {
//                                   accountType = value['account_type'];
//                                   mediaCount = value['media_count'];
//                                 }
//                                 setState(() {});
//                               });
//                             },
//                             child: const Text('Get Basic Profile Details'),
//                           ),
//                         ),
//                       const SizedBox(height: 10),
//                       if (mediaList.isNotEmpty)
//                         Expanded(
//                           child: Column(
//                             children: [
//                               const Center(
//                                 child: Text(
//                                   '------Media List------',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: GridView.count(
//                                   crossAxisCount: 3,
//                                   crossAxisSpacing: 10,
//                                   mainAxisSpacing: 10,
//                                   children: List.generate(
//                                     mediaList.length,
//                                     (index) {
//                                       var media = mediaList[index];
//                                       return InkWell(
//                                         onTap: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   PromotionListOrganiser(
//                                                       // url: media['media_url'],
//                                                       // media: media,
//                                                       ),
//                                             ),
//                                           );
//                                         },
//                                         child: Container(
//                                           alignment: Alignment.center,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             image: DecorationImage(
//                                               image: NetworkImage(
//                                                   media['media_url']),
//                                             ),
//                                           ),
//                                           child: media['media_type'] == 'VIDEO'
//                                               ? const Icon(Icons.videocam)
//                                               : null,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       else
//                         Center(
//                           child: ElevatedButton(
//                             onPressed: () async {
//                               await Instaservices()
//                                   .fetchUserMedia(
//                                 userId: userid,
//                                 accessToken: token,
//                               )
//                                   .then((value) {
//                                 mediaList = value;
//                                 setState(() {});
//                               });
//                             },
//                             child: const Text('Get Media'),
//                           ),
//                         )
//                     ],
//                   ),
//                 )
//               else
//                 SizedBox(
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) {
//                             return InstaView(
//                               instaAppId: '4053343864940436',
//                               instaAppSecret:
//                                   '089aeee78e4055de1a708bae60fe4fb9',
//                               redirectUrl: 'https://ayesha-iftikhar.web.app/',
//                               onComplete: (_token, _userid, _username) {
//                                 WidgetsBinding.instance.addPostFrameCallback(
//                                   (timeStamp) {
//                                     setState(() {
//
//                                       token = _token;
//                                       userid = _userid;
//                                       username = _username;
//                                       Fluttertoast.showToast(msg: 'token- $_token');
//
//                                     });
//                                   },
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       );
//                     },
//                     child: const Text('Connect to Instagram'),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
