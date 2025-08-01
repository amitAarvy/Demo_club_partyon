import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudflare/cloudflare.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveStatus extends StatefulWidget {
  const LiveStatus({Key? key}) : super(key: key);

  @override
  State<LiveStatus> createState() => _LiveStatusState();
}

class _LiveStatusState extends State<LiveStatus> {
  dynamic data, videoId;

  @override
  void initState() {
    // TODO: implement initState
    cloudInit();
    super.initState();
  }

  void cloudInit() async {
    EasyLoading.show();

    final homeController = Get.put(HomeController());
    await FirebaseFirestore.instance
        .collection("Admin")
        .doc("Club")
        .collection(uid().toString())
        .doc(homeController.clubID.toString())
        .get()
        .then((value) async {
      if (value.exists) {
        try {
          await cloudflare.init();
          final response =
              await cloudflare.liveInputAPI.get(id: value.data()?["videoID"]);
          setState(() {
            data = response.body;
            videoId = value.data()?["videoID"];
            EasyLoading.dismiss();
            if (kDebugMode) {
              print(response.body?.recording.mode);
            }
          });
        } catch (e) {
          Fluttertoast.showToast(msg: 'Invalid Video Id');
          EasyLoading.dismiss();
        }
      } else {
        EasyLoading.dismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: 'Go Live'),
      backgroundColor: matte(),
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
                width: 400.h,
                height: 400.h,
                child: Image.asset(
                  'assets/newLogo.png',
                  fit: BoxFit.fill,
                )).paddingSymmetric(vertical: 400.h),
            Text(
              "Connection Status: ${data?.status?.current?.state}",
              style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 50.sp),
            ),
            SizedBox(
              height: 30.h,
            ),
            Text(
              "Live Status: ${data?.recording?.mode == LiveInputRecordingMode.off ? 'Off' : data?.recording?.mode == LiveInputRecordingMode.automatic ? 'ON' : 'unknown'}",
              style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 50.sp),
            ),
            SizedBox(
              height: 30.h,
            ),
            data != null
                ? ElevatedButton(
                    onPressed: () async {
                      await cloudflare.init();

                      data?.recording?.mode == LiveInputRecordingMode.off
                          ? cloudflare.liveInputAPI
                              .update(
                                  liveInput: CloudflareLiveInput(
                                      id: videoId,
                                      recording: LiveInputRecording(
                                          mode: LiveInputRecordingMode
                                              .automatic)))
                              .whenComplete(() => cloudInit())
                          : data?.recording?.mode ==
                                  LiveInputRecordingMode.automatic
                              ? cloudflare.liveInputAPI
                                  .update(
                                      liveInput: CloudflareLiveInput(
                                          id: videoId,
                                          recording: LiveInputRecording(
                                              mode:
                                                  LiveInputRecordingMode.off)))
                                  .whenComplete(() => cloudInit())
                              : "";
                    },
                    child: Text(
                        data?.recording?.mode == LiveInputRecordingMode.off ? 'Turn On Live' : data?.recording?.mode == LiveInputRecordingMode.automatic ? 'Turn off Live' : 'unknown'))
                : Container()
          ],
        ),
      ),
    );
  }
}
