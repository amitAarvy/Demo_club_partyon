import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/core/app_const/hive_const.dart';
import 'package:club/local_db/hive_db.dart';
import 'package:club/utils/provider_utils.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

Color matte() => const Color(0Xff171717);

String? uid() => FirebaseAuth.instance.currentUser?.uid;

Widget textField(String label, TextEditingController controller,
    {bool isNum = false,
    bool isMandatory = false,
    bool isReadOnly = false,
      bool isWithOutSpace = false,
      bool isUpperCase = false,
    isEmail = false,
    isPinCode = false,
    isPhone = false,
    isInfo = false,
    obscureText = false,
    Color? backgroundColor}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          // width: Get.width,
          // height: isInfo == true ? 260.h : 130.h,
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          // padding: EdgeInsets.only(left: 20.w, right: 20.w),
          child: TextFormField(
            minLines: isInfo ? 3 : null,
              maxLines: obscureText ? 1 : null,
              obscureText: obscureText,

              readOnly: (isEmail == true && isPhone == false) || isReadOnly,
              keyboardType:
                  isNum == true ? TextInputType.number : TextInputType.text,
              inputFormatters: [
                isPinCode == true
                    ? LengthLimitingTextInputFormatter(6)
                    : isInfo == true
                        ? LengthLimitingTextInputFormatter(4000)
                        : isWithOutSpace?
             FilteringTextInputFormatter.deny(RegExp(r'\s')) // disallow spaces

      :LengthLimitingTextInputFormatter(200),
                if (isNum == true) FilteringTextInputFormatter.digitsOnly,
                if(isUpperCase)UpperCaseTextFormatter(),
              ],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (isMandatory) {
                  if (controller.text.isEmpty) {
                    return '';
                  }
                }
                return null;
              },
              controller: controller,
              style: GoogleFonts.merriweather(color: Colors.white),
              decoration: InputDecoration(
                alignLabelWithHint: isInfo,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  errorStyle: const TextStyle(height: 0),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 1.0)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.0)),
                  hintStyle: GoogleFonts.ubuntu(color: Colors.white),
                  label: RichText(
                    text: TextSpan(text: label,style: const TextStyle(color: Colors.white), children: [
                      TextSpan(
                          text: isMandatory ? ' *' : '',
                          style: const TextStyle(color: Colors.red))
                    ]),
                  ),
                  // labelText: label + (isMandatory ? ' *' : ''),
                  labelStyle:
                      TextStyle(color: Colors.white70, fontSize: 40.sp))));
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

void getLogo(BuildContext context) async {
  String logoURL = "";
  await FirebaseFirestore.instance
      .collection("Club")
      .doc(uid())
      .get()
      .then((value) async {
    if (value.exists) {
      Provider.of<LogoProvider>(context, listen: false)
          .changeLogo(await value.get("logo"));
      if (kDebugMode) {
        print(logoURL);
      }
    } else {
      Provider.of<LogoProvider>(context, listen: false)
          .changeLogo(await value.get("logo"));
    }
  });
}

PreferredSizeWidget appBar(BuildContext context,
    {String title = "",
    bool isHome = false,
    bool isBooking = false,
    bool isPromotion = false,
    bool isOrganiser = false,
    bool isOffers = false,
    showLogo = true,
    showTitle = true,
    bool showBack = true,
    ShapeBorder? shapeBorder,
    PreferredSizeWidget? bottom,
    TabController? tabController,
    var key}) {
  final c = Get.put(HomeController());

  return AppBar(
    automaticallyImplyLeading: showBack,
    leading: showBack ? GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: const Icon(Icons.arrow_back, color: Colors.white),
    ) : null,
    title: showLogo
        ? Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            key.currentState?.isDrawerOpen == true
                ? key.currentState?.closeDrawer()
                : key.currentState?.openDrawer();
          },
          child: Column(
            children: [
              Text(
                "PartyOn",
                style: GoogleFonts.dancingScript(
                  color: Colors.red,
                  fontSize: 30,
                ),
              ),
  ]
            ),
          ),
        // SizedBox(
        //   width: 400.w,
        // ),
        // SizedBox(
        //   // width: 300.w,
        //   child: Obx(() => Text(
        //     c.clubName.value.capitalizeFirst.toString(),
        //     textAlign: TextAlign.end,
        //     style: GoogleFonts.dancingScript(
        //         color: Colors.white, fontSize: 30),
        //     overflow: TextOverflow.ellipsis,
        //   )),
        // )
      ],
    )
        : null,
    bottom: showTitle == false ? null : isOrganiser == true
        ? TabBar(
        controller: tabController,
        indicatorColor: Colors.white,
        tabs: const [
          // Tab(
          //   text: "List",
          // ),
          Tab(
            text: "List",
          ),
          Tab(
            text: "Accepted",
          ),
          Tab(
            text: "Past",
          ),
        ])
        : isPromotion == true
        ? TabBar(
        controller: tabController,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(
            text: "Event",
          ),
          Tab(
            text: "Venue",
          ),
          // Tab(
          //   text: "List",
          // ),
        ])
        : isOffers == true
        ? const TabBar(indicatorColor: Colors.white, tabs: [
      Tab(
        text: "Add",
      ),
      Tab(
        text: "View",
      )
    ])
        : isBooking != true
        ? PreferredSize(
      preferredSize: const Size.fromHeight(30),
      child: SizedBox(
        height: 40,
        child: Text(
          title,
          style: GoogleFonts.ubuntu(
              color: Colors.white, fontSize: 20),
        ),
      ),
    )
        : TabBar(
        controller: tabController,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(
            text: "Current",
          ),
          Tab(
            text: "Upcoming",
          ),
          Tab(
            text: "Past",
          ),
        ]),
    backgroundColor: Colors.black,
    shadowColor: Colors.grey,
    // shape: isOffers == true
    //     ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(1))
    //     : isBooking != true
    //         ? RoundedRectangleBorder(
    //             borderRadius: BorderRadius.vertical(
    //                 bottom: Radius.elliptical(
    //                     MediaQuery.of(context).size.width, 300.h)),
    //           )
    //         : RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
  );
}

Future<bool> showExitPopup(BuildContext context) async {
  return await showDialog(
        //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Do you want to exit an App?'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.black)),
              //return false when click on "NO"
              child: const Text(
                'No',
                style: TextStyle(color: Colors.white),
              ).paddingSymmetric(horizontal: 30.w),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.black)),
              //return true when click on "Yes"
              child: const Text('Yes').paddingSymmetric(horizontal: 30.w),
            ),
          ],
        ),
      ) ??
      false; //if showDialogue had returned null, then return false
}

extension CapExtension on String {
  String get inCaps =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';

  String get capitalizeFirstOfEach => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((String str) => str.inCaps)
      .join(' ');
}

dynamic getKeyValueFirestore(
    DocumentSnapshot documentSnapshot, String keyName) {
  Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>;
  if (documentSnapshot.exists && data.containsKey(keyName)) {
    return documentSnapshot.get(keyName);
  } else {
    return null;
  }
}

Widget customisedButton(
  String buttonText, {
  required Function() onTap,
  Color? buttonColor,
}) =>
    ElevatedButton(
        onPressed: () => onTap(),
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith(
                (states) => buttonColor ?? Colors.red)),
        child: Text(buttonText));

TableBorder customisedTableBorder(
        {double borderRadius = 0, Color? borderColor}) =>
    TableBorder.all(
      borderRadius: BorderRadius.circular(borderRadius),
      color: borderColor ?? Colors.amber,
      style: BorderStyle.solid,
    );

TableRow tableRow(
        {required String first,
        required String second,
        required String third,
        required String fourth}) =>
    TableRow(
      children: [
        Center(
          child: Text(
            first,
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              color: Colors.orange,
              fontSize: 45.sp,
            ),
          ).paddingAll(20.w),
        ),
        Center(
          child: Text(
            second,
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontSize: 45.sp,
            ),
          ).paddingAll(20.w),
        ),
        Center(
          child: Text(
            third,
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontSize: 45.sp,
            ),
          ).paddingAll(20.w),
        ),
        Center(
          child: Text(
            fourth,
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontSize: 45.sp,
            ),
          ).paddingAll(5.w),
        ),
      ],
    );

TableRow tableRowWidget({required String title, required String value}) =>
    TableRow(
      children: [
        Text(
          title,
          style: GoogleFonts.ubuntu(
            color: Colors.orange,
            fontSize: 45.sp,
          ),
        ).paddingAll(40.w),
        Text(
          value,
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontSize: 45.sp,
          ),
        ).paddingAll(40.w),
      ],
    );

void saveBusinessType(String businessType) async {
  Box box = await HiveDB.openBox();
  final savedBusinessType = await HiveDB.putKey(box, HiveConst.businessType, businessType);
  box.get(HiveConst.businessType);
print("savedBusinessType called ${box.get(HiveConst.businessType)}");
}

extension UpperTitle on String {
  String toUpperFirst() => this[0].toUpperCase() + substring(1);
}
