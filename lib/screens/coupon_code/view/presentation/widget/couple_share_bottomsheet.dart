import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class CoupleShareBottomSheet extends StatefulWidget {
  final String couponCode;
  final String validFrom;
  final String validUntil;
  final String couponCategory;
  final String eventName;
  final String eventData;

  const CoupleShareBottomSheet(
      {super.key,
      required this.couponCode,
      required this.validFrom,
      required this.validUntil,
      required this.couponCategory,
      required this.eventName,
      required this.eventData});

  @override
  State<CoupleShareBottomSheet> createState() => _CoupleShareBottomSheetState();
}

class _CoupleShareBottomSheetState extends State<CoupleShareBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff6E0E0A),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share the Coupon Code 🎁',
              style: TextStyle(
                color: Colors.white,
                fontSize: 52.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 28.h,
            ),
            Text(
              'Event Name: \'${widget.eventName}\' \n Event Date: ${widget.eventData}?. \n \n Share this exclusive coupon code and get ready to dive into the Partyon experience !',
              style: TextStyle(color: Colors.white, fontSize: 40.sp),
            ),
            SizedBox(
              height: 28.h,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
              decoration: BoxDecoration(
                  color: const Color(0xffF0E20E),
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.couponCode,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 48.sp,
                          color: Colors.purple),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        String message =
                            '✨ Are you ready for \'${widget.eventName}\' on ${widget.eventData}? Special Offer Just for You! ✨ \n We’re thrilled to offer you an exclusive coupon code: ${widget.couponCode} \n 📌 Valid from: ${widget.validFrom}. \n 📆 Hurry, code valid until ${widget.validUntil} \n !👉 Redeem it for ${widget.couponCategory}!';
                        Share.share(message);
                      },
                      icon: const Icon(Icons.share, color: Colors.purple)),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
