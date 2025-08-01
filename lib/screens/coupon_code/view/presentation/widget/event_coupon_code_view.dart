import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/coupon_code/model/data/coupon_code_model.dart';
import 'package:club/screens/coupon_code/view/presentation/widget/saved_coupons.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'couple_share_bottomsheet.dart';

class EventCouponCodeView extends StatefulWidget {
  final List<CouponModel> couponList;
  final String couponCategory;
  final String couponTitle;
  final QueryDocumentSnapshot documentSnapshot;
  final VoidCallback initCall;
  final DateTime date;

  const EventCouponCodeView(
      {super.key,
      required this.couponList,
      required this.couponCategory,
      required this.couponTitle,
      required this.documentSnapshot,
      required this.initCall,
      required this.date});

  @override
  State<EventCouponCodeView> createState() => _EventCouponCodeViewState();
}

class _EventCouponCodeViewState extends State<EventCouponCodeView> {
  @override
  Widget build(BuildContext context) {
    print('check coupon list is ${widget.couponList}');
    print('check coupon list is ${widget.couponCategory}');
    final eventCoupon = widget.couponList
        .where((e) => e.couponCategory == widget.couponCategory)
        .toList();
    final eventData = widget.documentSnapshot.data() as Map<String, dynamic>;
    if (eventCoupon.isNotEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0).copyWith(left: 52.w),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                widget.couponTitle,
                style: TextStyle(color: Colors.white, fontSize: 40.sp),
              ),
            ),
          ),
          if (eventCoupon.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0).copyWith(left: 52.w, top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                    color: const Color(0xff451F55),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Active Coupon: ${eventCoupon.first.couponCode}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 40.sp)),
                          Text('Category: ${eventCoupon.first.couponCategory}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 40.sp)),
                          Text('Discount: ${eventCoupon.first.discount}%',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 40.sp)),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Get.bottomSheet(CoupleShareBottomSheet(
                          couponCode: eventCoupon.first.couponCode ?? '',
                          validFrom: eventCoupon.first.validFrom ?? '',
                          validUntil: eventCoupon.first.validTill ?? '',
                          couponCategory:
                              eventCoupon.first.couponCategory ?? '',
                          eventName: eventData["title"]
                              .toString()
                              .capitalizeFirstOfEach,
                          eventData:
                              '${widget.date.day}-${widget.date.month}-${widget.date.year}',
                        ));
                      },
                      icon: const Icon(Icons.share, color: Colors.white))
                ],
              ),
            )
        ],
      );
    } else {
      print('yes empty');
      return SavedCoupons(
          couponCategory: widget.couponCategory,
          eventId: widget.documentSnapshot.id,
          voidCallback: widget.initCall);
    }
  }
}
