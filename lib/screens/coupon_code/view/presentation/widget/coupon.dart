import 'package:club/screens/coupon_code/controller/coupon_code_controller.dart';
import 'package:club/screens/coupon_code/model/data/coupon_code_model.dart';
import 'package:club/screens/coupon_code/view/presentation/widget/shared_coupon_event_list.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Coupon extends StatefulWidget {
  final String couponCategory;
  final String? validFrom, validTill;
  final String couponCode;
  final String discount;

  const Coupon({
    super.key,
    required this.couponCategory,
    required this.validFrom,
    required this.validTill,
    required this.couponCode,
    required this.discount,
  });

  @override
  State<Coupon> createState() => _CouponState();
}

class _CouponState extends State<Coupon> {
  final couponCodeController = Get.put(CouponCodeController());
  bool _isCouponSaved = false;
  bool isSaved = false;

  void onSaveCoupon() async {
    if (widget.couponCode.isNotEmpty &&
        (widget.couponCategory.isNotEmpty) && (widget.discount.isNotEmpty) &&
        (widget.validFrom != null && widget.validTill != null)) {
      await CouponCodeController.saveCouponToFirebase(widget.couponCategory,
          widget.validFrom ?? '', widget.validTill ?? '', widget.couponCode, widget.discount);
      _isCouponSaved = true;
      isSaved = true;
      Fluttertoast.showToast(msg: 'The coupon code is saved!');
    } else {
      Fluttertoast.showToast(msg: 'Enter all fields');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: matte(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 20,
            color: const Color(0xff6E0E0A),
            shadowColor: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const DottedLine(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    lineLength: double.infinity,
                    lineThickness: 4.0,
                    dashLength: 8.0,
                    dashColor: Colors.white,
                    dashGapLength: 4.0,
                    dashGapColor: Colors.transparent,
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    'Coupon Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 80.sp,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Colors.black54,
                    color: const Color(0xffF0E20E),
                    elevation: 12,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.couponCode,
                            style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 48.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                      ClipboardData(text: widget.couponCode))
                                  .then((_) {
                                Fluttertoast.showToast(
                                    msg: 'Coupon code copied to clipboard!');
                              });
                            },
                            child: const Icon(
                              Icons.copy,
                              color: Colors.purple,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48.sp,
                          ),
                          children: [
                            const TextSpan(text: 'Valid From : '),
                            TextSpan(
                              text: widget.validFrom,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 48.sp),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 40.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48.sp,
                          ),
                          children: [
                            const TextSpan(text: 'Valid Until : '),
                            TextSpan(
                              text: widget.validTill,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 48.sp),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 40.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48.sp,
                          ),
                          children: [
                            const TextSpan(text: 'Category : '),
                            TextSpan(
                              text: widget.couponCategory,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 48.sp),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.category, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 40.h),
                  const DottedLine(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    lineLength: double.infinity,
                    lineThickness: 4.0,
                    dashLength: 8.0,
                    dashColor: Colors.white,
                    dashGapLength: 4.0,
                    dashGapColor: Colors.transparent,
                  ),
                  SizedBox(height: 40.h),
                  ElevatedButton(
                    onPressed: () {
                      !isSaved ? onSaveCoupon() : () {};
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: const Color(0xffF0E20E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      !isSaved ? 'Save Coupon Code' : 'Saved Code',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  if (!_isCouponSaved)
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Fluttertoast.showToast(
                            msg: 'The coupon code is discarded!');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xffF0E20E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Discard Coupon Code',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isSaved)
                    TextButton(
                      onPressed: () => Get.back(result: 'saved'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xffF0E20E),
                      ),
                      child: Text(
                        'View Saved Coupons',
                        style: GoogleFonts.ubuntu(
                          fontSize: 46.sp,
                          decorationColor: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      // if (_isCouponSaved)
                      //   FloatingActionButton(
                      //     onPressed: () {
                      //       showModalBottomSheet(
                      //         context: context,
                      //         backgroundColor: Colors.transparent,
                      //         builder: (BuildContext context) {
                      //           return CoupleShareBottomSheet(
                      //             couponCode: widget.couponCode,
                      //             validFrom: widget.validFrom ?? '',
                      //             validUntil: widget.validTill ?? '',
                      //             couponCategory: widget.couponCategory,
                      //           );
                      //         },
                      //       );
                      //       Fluttertoast.showToast(msg: 'Share this coupon code!');
                      //     },
                      //     backgroundColor: Colors.purple,
                      //     child: const Icon(Icons.share),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
