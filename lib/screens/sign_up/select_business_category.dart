import 'package:club/screens/sign_up/club_details.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpVenue extends StatefulWidget {
  final String email, phone;
  final bool isPhone;
  const SignUpVenue(
      {this.phone = "", this.isPhone = false, required this.email, Key? key})
      : super(key: key);

  @override
  State<SignUpVenue> createState() => _SignUpVenueState();
}

class _SignUpVenueState extends State<SignUpVenue> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Select Business Category"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.to(ClubDetails(
                          businessCategory: 1,
                          email: widget.email,
                          isPhone: widget.phone.isNotEmpty,
                          phone: widget.phone,
                        ));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Center(
                            child: Text(
                                "Nightlife\n & \nevent's",
                                style: GoogleFonts.ubuntu(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                        ),
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       Get.to(ClubDetails(
                  //         businessCategory: 2,
                  //         email: widget.email,
                  //         isPhone: widget.phone.isNotEmpty,
                  //         phone: widget.phone,
                  //       ));
                  //     },
                  //     child: Container(
                  //       margin: const EdgeInsets.all(5),
                  //       height: 100,
                  //       decoration: BoxDecoration(
                  //           border: Border.all(color: Colors.white, width: 1),
                  //           borderRadius: BorderRadius.circular(10)
                  //       ),
                  //       child: Center(
                  //         child: Text(
                  //           "Hotel's / Resort/\nFarmhouse/AirBhb",
                  //           style: GoogleFonts.ubuntu(color: Colors.white),
                  //           textAlign: TextAlign.center,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () {
              //           Get.to(ClubDetails(
              //             businessCategory: 3,
              //             email: widget.email,
              //             isPhone: widget.phone.isNotEmpty,
              //             phone: widget.phone,
              //           ));
              //         },
              //         child: Container(
              //           margin: const EdgeInsets.all(5),
              //           height: 100,
              //           decoration: BoxDecoration(
              //               border: Border.all(color: Colors.white, width: 1),
              //               borderRadius: BorderRadius.circular(10)
              //           ),
              //           child: Center(
              //             child: Text(
              //               "Beauty & Cosmetics's\nSaloon's / Makeup\nProduct / Accessories",
              //               style: GoogleFonts.ubuntu(color: Colors.white),
              //               textAlign: TextAlign.center,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () {
              //           Get.to(ClubDetails(
              //             businessCategory: 4,
              //             email: widget.email,
              //             isPhone: widget.phone.isNotEmpty,
              //             phone: widget.phone,
              //           ));
              //         },
              //         child: Container(
              //           margin: const EdgeInsets.all(5),
              //           height: 100,
              //           decoration: BoxDecoration(
              //               border: Border.all(color: Colors.white, width: 1),
              //               borderRadius: BorderRadius.circular(10)
              //           ),
              //           child: Center(
              //             child: Text(
              //               "Brand & \nProduct's",
              //               style: GoogleFonts.ubuntu(color: Colors.white),
              //               textAlign: TextAlign.center,
              //             ),
              //           ),
              //         ),
              //       ),
              //     )
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
