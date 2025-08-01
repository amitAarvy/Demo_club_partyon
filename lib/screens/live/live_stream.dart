// import 'dart:async';
// import 'dart:convert';
// import 'package:agora_rtc_engine/rtc_engine.dart';
// import "package:agora_rtc_engine/rtc_local_view.dart" as LocalView;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:club/screens/home/home.dart';
// import 'package:club/screens/home/home_provider.dart';
// import 'package:club/screens/live/live_app_id.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:random_string/random_string.dart';
// import 'package:wakelock/wakelock.dart';
//
// class LiveStream extends StatefulWidget {
//   String channel;
//
//   LiveStream(this.channel, {Key? key}) : super(key: key);
//
//   @override
//   State<LiveStream> createState() => _LiveStreamState();
// }
//
// class _LiveStreamState extends State<LiveStream> {
//   bool pause = false, mute = false;
//   var token;
//   String baseUrl = "https://partyon-artist.herokuapp.com";
//   late String rid;
//   late String sid;
//   late int uid;
//   late int recUid;
//   var url;
//   Timer? timer;
//   bool local = false;
//   final String videoId = randomAlphaNumeric(6);
//   bool video = true, audio = false, end = false;
//   StreamSubscription? subscription;
//
//   late RtcEngine _engine;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     initAgora();
//     Wakelock.enable();
//     updateChannel();
//     //
//     // timer = Timer.periodic(Duration(seconds: 10), (_timer) {
//     //   getUrl();
//     //   if (url != null) {
//     //     timer?.cancel();
//     //     _timer.cancel();
//     //     addStream();
//     //   }
//     //   print("url " + url.toString());
//     // });
//
//     super.initState();
//   }
//
//   Future<void> controlStream() async {
//     FirebaseFirestore.instance.collection("Streams").doc(widget.channel).set({
//       "id": widget.channel,
//       "video": true,
//       "audio": true,
//       "end": false,
//     }).whenComplete(() {
//       subscription = FirebaseFirestore.instance
//           .collection("Streams")
//           .doc(widget.channel)
//           .snapshots()
//           .listen((event) {
//         setState(() {
//           if (event.exists) {
//             video = event.data()?["video"];
//             audio = event.data()?["audio"];
//             end = event.data()?["end"];
//           }
//         });
//       });
//     });
//   }
//
//   Future<void> initAgora() async {
//     await [Permission.microphone, Permission.camera].request();
//     // retrieve permission
//     _getToken();
//
//     //create the engine
//     _engine = await RtcEngine.create(app_id);
//     await _engine.joinChannel(null, widget.channel, null, 2);
//     await _engine.disableVideo();
//
//     await _engine.enableLocalAudio(true).whenComplete(() => setState(() {
//           mute = false;
//         }));
//     await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//     await _engine.setClientRole(ClientRole.Broadcaster);
//     // .whenComplete(() => controlStream());
//     _engine.setEventHandler(
//       RtcEngineEventHandler(
//         joinChannelSuccess: (String channel, int uid, int elapsed) {
//           print("local user $uid joined");
//           setState(() {
//             local = true;
//           });
//         },
//       ),
//     );
//     //_startRecording(widget.channel);
//   }
//
//   void updateChannel() async {
//     final c = Get.put(HomeGetX());
//     FirebaseFirestore.instance
//         .collection("Club")
//         .doc(FirebaseAuth.instance.currentUser?.uid)
//         .collection("clubData")
//         .doc(c.clubID.value)
//         .set({"channel": widget.channel}, SetOptions(merge: true));
//   }
//
//   void addStream() async {
//     var data = await FirebaseFirestore.instance
//         .collection("Artist")
//         .doc(FirebaseAuth.instance.currentUser?.uid)
//         .get();
//     var ds = data.data();
//     FirebaseFirestore.instance
//         .collection("Videos")
//         .doc(videoId)
//         .set({
//           "videoId": videoId,
//           "artistId": ds?["artistId"].toString(),
//           // "clubId": widget.clubId != null ? widget.clubId : "",
//           // "name": widget.streamName,
//           "videoLink": url
//               .toString()
//               .replaceAll(".US East (N. Virginia) us-east-1.", ".")
//               .replaceAll("[", "")
//               .replaceAll("]", ""),
//           "likes": 0,
//           "views": 0,
//           "dueAmount": 0,
//           "earnings": 0,
//           "statusPay": "",
//           "dateTime": Timestamp.now().toDate(),
//           "sHour": 0,
//           "sMin": 0,
//           "sSec": 0,
//           "eHour": 0,
//           "eMin": 0,
//           "eSec": 0,
//           "duration": 0,
//           "onClub": false,
//           "onUser": false,
//           "isLive": true,
//           "fromStream": true,
//           "uid": FirebaseAuth.instance.currentUser
//         })
//         .whenComplete(() => FirebaseFirestore.instance
//             .collection("Videos")
//             .doc(videoId)
//             .collection("Ratings")
//             .add({"userId": "", "rating": 0}))
//         .whenComplete(() {
//           Fluttertoast.showToast(msg: "Stream has been successfully added");
//         });
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     //_stopRecording(widget.channel, rid, sid, recUid);
//     _engine.leaveChannel();
//     _engine.destroy();
//     subscription?.cancel();
//     Wakelock.disable();
//     // timer?.cancel();
//     // FirebaseFirestore.instance
//     //     .collection("Streams")
//     //     .doc(widget.channel)
//     //     .delete();
//     // FirebaseFirestore.instance.collection("Videos").doc(videoId).set({
//     //   "isLive": false,
//     // }, SetOptions(merge: true));
//
//     super.dispose();
//   }
//
//   void getUrl() async {
//     final data = await http.get(
//       Uri.parse(baseUrl + '/api/get/recordingUrls/' + widget.channel),
//     );
//     setState(() {
//       if (!mounted) url = jsonDecode(data.body)["recordings"];
//     });
//
//     if (url == null) {
//       Future.delayed(Duration(seconds: 5), () async {
//         getUrl();
//       });
//     } else {
//       print(url
//           .toString()
//           .replaceAll(".US East (N. Virginia) us-east-1.", ".")
//           .replaceAll("[", "")
//           .replaceAll("]", ""));
//     }
//   }
//
//   Future<void> _getToken() async {
//     final response =
//         await http.get(Uri.parse(baseUrl + '/api/get/rtc/' + widget.channel));
//     if (response.statusCode == 200) {
//       print(response.body);
//       setState(() {
//         token = jsonDecode(response.body)['rtc_token'];
//         uid = jsonDecode(response.body)['uid'];
//       });
//     } else {
//       print(response.reasonPhrase);
//       print('Failed to generate the token : ${response.statusCode}');
//     }
//   }
//
//   Future<void> _startRecording(String channelName) async {
//     final response =
//         await http.post(Uri.parse(baseUrl + '/api/start/call'), body: {
//       "channel": channelName,
//     });
//
//     if (response.statusCode == 200) {
//       print('Recording Started');
//       setState(() {
//         rid = jsonDecode(response.body)['data']['rid'];
//         recUid = jsonDecode(response.body)['data']['uid'];
//         sid = jsonDecode(response.body)['data']['sid'];
//       });
//     } else {
//       print('Couldn\'t start the recording : ${response.statusCode}');
//     }
//   }
//
//   Future<void> _stopRecording(
//       String mChannelName, String mRid, String mSid, int mRecUid) async {
//     timer?.cancel();
//     FirebaseFirestore.instance.collection("Videos").doc(videoId).set({
//       "isLive": false,
//     }, SetOptions(merge: true));
//     final response = await http.post(
//       Uri.parse(baseUrl + '/api/stop/call'),
//       body: {
//         "channel": mChannelName,
//         "rid": mRid,
//         "sid": mSid,
//         "uid": mRecUid.toString()
//       },
//     );
//     print("response " + response.body);
//
//     if (response.statusCode == 200) {
//       print('Recording Ended');
//     } else {
//       print('Couldn\'t end the recording : ${response.statusCode}');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // if (end == true) {
//     //   _engine.leaveChannel();
//     //   _engine.destroy();
//     //   Get.off(Home());
//     // }
//     // if (audio == true) {
//     //   _engine.muteLocalAudioStream(false);
//     //   setState(() {
//     //     mute = false;
//     //   });
//     // } else {
//     //   _engine.muteLocalAudioStream(true);
//     //   setState(() {
//     //     mute = true;
//     //   });
//     // }
//     //
//     // if (video == true) {
//     //   _engine.muteLocalVideoStream(false);
//     //   setState(() {
//     //     pause = false;
//     //   });
//     // } else {
//     //   _engine.muteLocalVideoStream(true);
//     //   setState(() {
//     //     pause = true;
//     //   });
//     // }
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.black,
//         title: Row(
//           children: [
//             Text('Channel Id: '),
//             Text('${widget.channel}'),
//             IconButton(
//                 onPressed: () {
//                   Clipboard.setData(ClipboardData(text: "${widget.channel}"));
//                 },
//                 icon: Icon(
//                   Icons.copy,
//                   size: 60.h,
//                 ))
//           ],
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           local
//               ? Stack(
//                   children: [
//                     mute == false
//                         ? Container(
//                             height: Get.height,
//                             width: Get.width,
//                             color: Colors.black,
//                             child: Center(
//                                 child: Text("Streaming live audio",
//                                     style: GoogleFonts.ubuntu(
//                                         color: Colors.white, fontSize: 60.sp))))
//                         : Container(
//                             height: Get.height,
//                             width: Get.width,
//                             color: Colors.black,
//                             child: Center(
//                                 child: Text(
//                               "Live audio is muted",
//                               style: GoogleFonts.ubuntu(
//                                   color: Colors.white, fontSize: 60.sp),
//                             ))),
//                     LocalView.SurfaceView(
//                       channelId: widget.channel,
//                     ),
//                   ],
//                 )
//               : Container(
//                   width: Get.width,
//                   height: Get.height,
//                   child: Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 ),
//           // Align(
//           //     alignment: Alignment.bottomRight,
//           //     child: Container(
//           //       height: 150.h,
//           //       width: 150.h,
//           //       decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//           //       child: Center(
//           //         child: pause == false
//           //             ? IconButton(
//           //           icon: Icon(
//           //             Icons.videocam,
//           //             color: Colors.blue,
//           //           ),
//           //           onPressed: () {
//           //             FirebaseFirestore.instance
//           //                 .collection("Streams")
//           //                 .doc(widget.channel)
//           //                 .update({"video": false});
//           //           },
//           //           iconSize: 65.h,
//           //         )
//           //             : IconButton(
//           //           icon: Icon(
//           //             Icons.videocam,
//           //             color: Colors.grey,
//           //           ),
//           //           onPressed: () {
//           //             FirebaseFirestore.instance
//           //                 .collection("Streams")
//           //                 .doc(widget.channel)
//           //                 .update({"video": true});
//           //           },
//           //           iconSize: 65.h,
//           //         ),
//           //       ),
//           //     )).paddingAll(16),
//           // Align(
//           //     alignment: Alignment.topRight,
//           //     child: Container(
//           //       height: 150.h,
//           //       width: 150.h,
//           //       decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//           //       child: Center(
//           //           child: IconButton(
//           //             icon: Icon(
//           //               Icons.camera_alt_rounded,
//           //               color: Colors.black,
//           //             ),
//           //             onPressed: () {
//           //               _engine.switchCamera();
//           //             },
//           //             iconSize: 65.h,
//           //           )),
//           //     )).paddingAll(16),
//           Align(
//               alignment: Alignment.bottomLeft,
//               child: Container(
//                 height: 150.h,
//                 width: 150.h,
//                 decoration:
//                     BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//                 child: Center(
//                   child: mute == false
//                       ? IconButton(
//                           icon: Icon(
//                             Icons.mic,
//                             color: Colors.green,
//                           ),
//                           onPressed: () {
//                             _engine.muteLocalAudioStream(true);
//                             setState(() {
//                               mute = true;
//                             });
//                             // FirebaseFirestore.instance
//                             //     .collection("Streams")
//                             //     .doc(widget.channel)
//                             //     .update({"audio": false});
//                           },
//                           iconSize: 65.h,
//                         )
//                       : IconButton(
//                           icon: Icon(FontAwesomeIcons.microphone),
//                           color: Colors.grey,
//                           onPressed: () {
//                             // FirebaseFirestore.instance
//                             //     .collection("Streams")
//                             //     .doc(widget.channel)
//                             //     .update({"audio": true});
//                             _engine.muteLocalAudioStream(false);
//                             setState(() {
//                               mute = false;
//                             });
//                           },
//                           iconSize: 65.h,
//                         ),
//                 ),
//               )).paddingAll(16),
//           Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                   height: 150.h,
//                   width: 150.h,
//                   decoration:
//                       BoxDecoration(color: Colors.red, shape: BoxShape.circle),
//                   child: Center(
//                       child: IconButton(
//                     icon: Icon(
//                       Icons.stop,
//                       color: Colors.white,
//                     ),
//                     onPressed: () {
//                       Get.defaultDialog(
//                           title: "Are you sure?",
//                           content: Container(
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Column(
//                                       children: [
//                                         IconButton(
//                                           onPressed: () {
//                                             _engine.leaveChannel();
//
//                                             _engine.destroy();
//                                             Get.back();
//                                             Get.off(Home());
//                                           },
//                                           icon: Icon(
//                                             Icons.check,
//                                             color: Colors.green,
//                                           ),
//                                         ),
//                                         Text("Yes")
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       width: 50.w,
//                                     ),
//                                     Column(
//                                       children: [
//                                         IconButton(
//                                           onPressed: () {
//                                             // FirebaseFirestore.instance
//                                             //     .collection("Streams")
//                                             //     .doc(widget.channel)
//                                             //     .update({"end": true});
//                                             Get.back();
//                                           },
//                                           icon: Icon(
//                                             FontAwesomeIcons.xmark,
//                                             color: Colors.red,
//                                           ),
//                                         ),
//                                         Text("No")
//                                       ],
//                                     )
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ));
//                     },
//                     iconSize: 65.h,
//                   )))).paddingAll(16)
//
//           // AgoraVideoButtons(
//           //   client: client,
//           //   // extraButtons: [
//           //   //   IconButton(
//           //   //       onPressed: () {
//           //   //         _stopRecording(widget.channel, rid, sid, recUid);
//           //   //         Fluttertoast.showToast(msg: "Recording ended");
//           //   //         Get.off(agoraHome());
//           //   //       },
//           //   //       icon: Icon(
//           //   //         Icons.stop,
//           //   //         color: Colors.white,
//           //   //         size: 70.h,
//           //   //       ))
//           //   // ],
//           // ),
//         ],
//       ),
//       // floatingActionButton: FabCircularMenu(children: [IconButton(onPressed: (){
//       //
//       // }, icon: Icon(Icons.videocam))],),
//     );
//   }
// }
