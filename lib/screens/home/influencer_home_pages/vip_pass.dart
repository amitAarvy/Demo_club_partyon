import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VipPass extends StatefulWidget {
  final dynamic promotionData;
  const VipPass({super.key, required this.promotionData});

  @override
  State<VipPass> createState() => _VipPassState();
}

class _VipPassState extends State<VipPass> {

  dynamic userData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchInfluencerProfile();
  }

  void fetchInfluencerProfile() async{
    DocumentSnapshot influ = await FirebaseFirestore.instance.collection('Influencer').doc(uid()).get();
    print('check inf ${influ}');
    // DocumentSnapshot data = await FirebaseFirestore.instance.collection('Organiser').doc(uid()).get();
    DocumentSnapshot clubData = await FirebaseFirestore.instance.collection('Club').doc(widget.promotionData['clubUID']).get();
    if( influ.exists && clubData.exists){
      userData = {...{"influData": influ.data() as Map<String, dynamic>, "clubData": clubData.data() as Map<String, dynamic>}};
      setState(() {});
      print('check it is data ${userData}');
    }else{
      userData = "";
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        // title: Text("Pass"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: userData == null
              ? const CircularProgressIndicator()
              : userData == ''
            ? const Text("Something went wrong", style: TextStyle(color: Colors.white))
          : Container(
            width: 1.sw,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/vip_pass.jpg"
                ),fit: BoxFit.fill
              )
            ),
            padding: EdgeInsets.all(40),
            child:     Container(
                  width: kIsWeb ? 230 : MediaQuery.of(context).size.width * 0.4,
                  padding: const EdgeInsets.all(kIsWeb ? 20 : 30),
                  decoration: BoxDecoration(
                    color: Colors.black
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset("assets/newLogo.png", width: 105),
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const LinearGradient(colors: [
                          Color(0xffFFD700),
                          Colors.white,
                          Color(0xffFFD700),
                        ],
                        begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        child: Text("ELITE PASS", style: GoogleFonts.aclonica(fontSize: kIsWeb ? 30 : 35, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 5),
                      Text(userData['clubData']['clubName'].toString().capitalize!, style: GoogleFonts.aclonica(fontSize: 17, color: Colors.white)),
                      const SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          if(userData['influData']['profile_image'] == null || userData['influData']['profile_image'].isEmpty)
                            const SizedBox(
                              width: kIsWeb ? 150 : 220,
                              height: kIsWeb ? 150 : 220,
                              child: Icon(PhosphorIcons.user, color: Colors.white, size: 50,),
                            )
                          else
                            SizedBox(
                              width: kIsWeb ? 150 : 200,
                              height: kIsWeb ? 150 : 200,
                              child: Image.network(userData['influData']['profile_image'], fit: BoxFit.cover),
                            ),
                          Positioned(
                            // bottom: 3,
                            // right: 2,
                            child: SizedBox(
                              width: 70,
                                height: 70,
                                child: QrImageView(
                                  data: "${uid()}/${widget.promotionData['promotionId']}",
                                  backgroundColor: Colors.white,
                                  // gapless: false,
                                  padding: EdgeInsets.all(0),
                                ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(userData['influData']['companyMame'].toString().capitalize!, style: GoogleFonts.aclonica(fontSize: 20, color: Colors.white)),
                      Text(DateFormat.yMMMMd().format(widget.promotionData['startTime'].toDate()), style: GoogleFonts.aclonica(fontSize: 15, color: Colors.white)),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xffFFD700)
                        ),
                          child: Center(child: Text(widget.promotionData['eventName'].toString().capitalize!, style: GoogleFonts.aclonica(fontSize: kIsWeb ? 16 : 20, color: Colors.black, fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),
                      ),
                    ],
                  ),
                ),
          )


          // Stack(
          //   alignment: Alignment.center,
          //   children: [
          //     SizedBox(
          //         height: 1.sh,
          //         width: kIsWeb ? 300 : null,
          //         child: Image.asset("assets/vip_pass.jpg", fit: BoxFit.fill),
          //     ),
          //
          //     Container(
          //       width: kIsWeb ? 230 : MediaQuery.of(context).size.width * 0.75,
          //       padding: const EdgeInsets.all(kIsWeb ? 20 : 30),
          //       decoration: BoxDecoration(
          //         color: Colors.black
          //       ),
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Image.asset("assets/gold_logo.png", width: 105),
          //           ShaderMask(
          //             blendMode: BlendMode.srcIn,
          //             shaderCallback: (bounds) => const LinearGradient(colors: [
          //               Color(0xffFFD700),
          //               Colors.white,
          //               Color(0xffFFD700),
          //             ],
          //             begin: Alignment.topCenter,
          //               end: Alignment.bottomCenter,
          //             ).createShader(
          //               Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          //             ),
          //             child: Text("ELITE PASS", style: GoogleFonts.aclonica(fontSize: kIsWeb ? 30 : 35, fontWeight: FontWeight.bold)),
          //           ),
          //           const SizedBox(height: 5),
          //           Text(userData['clubData']['clubName'].toString().capitalize!, style: GoogleFonts.aclonica(fontSize: 17, color: Colors.white)),
          //           const SizedBox(height: 10),
          //           Stack(
          //             alignment: Alignment.bottomRight,
          //             children: [
          //               if(userData['profileImages'] == null || userData['profileImages'].isEmpty)
          //                 const SizedBox(
          //                   width: kIsWeb ? 150 : 220,
          //                   height: kIsWeb ? 150 : 220,
          //                   child: Icon(PhosphorIcons.user, color: Colors.white, size: 50,),
          //                 )
          //               else
          //                 SizedBox(
          //                   width: kIsWeb ? 150 : 200,
          //                   height: kIsWeb ? 150 : 200,
          //                   child: Image.network(userData['profileImages'][0], fit: BoxFit.cover),
          //                 ),
          //               Positioned(
          //                 // bottom: 3,
          //                 // right: 2,
          //                 child: SizedBox(
          //                   width: 70,
          //                     height: 70,
          //                     child: QrImageView(
          //                       data: "${uid()}/${widget.promotionData['promotionId']}",
          //                       backgroundColor: Colors.white,
          //                       // gapless: false,
          //                       padding: EdgeInsets.all(0),
          //                     ),
          //                 ),
          //               )
          //             ],
          //           ),
          //           const SizedBox(height: 10),
          //           Text(userData['influData']['companyMame'].toString().capitalize!, style: GoogleFonts.aclonica(fontSize: 20, color: Colors.white)),
          //           Text(DateFormat.yMMMMd().format(widget.promotionData['startTime'].toDate()), style: GoogleFonts.aclonica(fontSize: 15, color: Colors.white)),
          //           const SizedBox(height: 10),
          //           Container(
          //             width: double.infinity,
          //             padding: const EdgeInsets.all(5),
          //             decoration: const BoxDecoration(
          //               color: Color(0xffFFD700)
          //             ),
          //               child: Center(child: Text(widget.promotionData['eventName'].toString().capitalize!, style: GoogleFonts.aclonica(fontSize: kIsWeb ? 16 : 20, color: Colors.black, fontWeight: FontWeight.w600))),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }
}
