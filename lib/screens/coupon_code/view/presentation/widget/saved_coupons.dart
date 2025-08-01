import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/coupon_code/model/data/coupon_code_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../controller/coupon_code_controller.dart';

class SavedCoupons extends StatefulWidget {
  final String eventId;
  final VoidCallback voidCallback;
  final String couponCategory;

  const SavedCoupons(
      {super.key,
      required this.eventId,
      required this.voidCallback,
      required this.couponCategory});

  @override
  State<SavedCoupons> createState() => _SavedCouponsState();
}

class _SavedCouponsState extends State<SavedCoupons> {
  late Future<List<CouponModel>> sharedCouponList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sharedCoupon();
  }

  void sharedCoupon() async {
    sharedCouponList = (CouponCodeController.savedCouponCodes());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CouponModel>>(
        future: sharedCouponList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data ?? [];
            List<CouponModel> couponList = data
                .where(
                    (coupon) => coupon.couponCategory == widget.couponCategory)
                .toList();
            return Column(
              children: [
                SaveCouponItemList(
                    title: 'Choose ${widget.couponCategory} Coupon',
                    data: couponList,
                    widget: widget),
              ],
            );
          }
        });
  }
}

class SaveCouponItemList extends StatelessWidget {
  final List<CouponModel> data;
  final SavedCoupons widget;
  final String title;

  const SaveCouponItemList(
      {super.key,
      required this.data,
      required this.widget,
      required this.title});

  @override
  Widget build(BuildContext context) {
    if (data.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.zero.copyWith(left: 52.w),
            child: Text(title,
                style: TextStyle(fontSize: 40.sp, color: Colors.white)),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final coupon = data[index];
                // final List<String> discountCodeList =
                //     coupon.couponCode?.split(RegExp(r'(?=[0-9])')) ?? [];
                final discount = coupon.discount;
                // discountCodeList.removeAt(0);
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: const Color(0xff451F55),
                        margin: const EdgeInsets.all(20),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
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
                                    }, SetOptions(merge: true)).whenComplete(
                                            () => widget.voidCallback());
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
                                  'Pick Me!',
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
