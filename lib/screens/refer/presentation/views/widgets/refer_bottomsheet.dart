import 'package:club/screens/refer/presentation/controller/refer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

class ReferBottomSheet extends StatefulWidget {
  final String referURL;
  final bool isEditableCode;
  final String couponCode;

  const ReferBottomSheet(
      {super.key,
      required this.referURL,
      required this.isEditableCode,
      required this.couponCode});

  @override
  _ReferBottomSheetState createState() => _ReferBottomSheetState();
}

class _ReferBottomSheetState extends State<ReferBottomSheet> {
  bool isEditable = true;
  final TextEditingController _couponController = TextEditingController();

  Future<void> _initializeCoupon() async {
    setState(() {
      _couponController.text = widget.couponCode;
    });
  }

  @override
  void initState() {
    super.initState();
    isEditable = widget.isEditableCode;
    _initializeCoupon();
  }

  Future<void> _saveCoupon() async {
    if (isEditable) {
      await ReferController.onSaveCouponCode(_couponController.text);
      setState(() {
        isEditable = false;
      });
      Fluttertoast.showToast(
          msg: 'Referral code has been saved and is no longer editable');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 20,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refer & Earn 🎉',
              style: TextStyle(
                fontSize: 52.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Text(
              'Share the app with your friends and let them join in on the experience!',
              style: TextStyle(fontSize: 36.sp),
            ),
            SizedBox(
              height: 20.h,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.referURL,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 44.sp,
                          color: Colors.white),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        String message =
                            await ReferController.referralLinkMessage(
                                widget.referURL);
                        message +=
                            '\n Use my referral code: ${_couponController.text}';
                        Share.share(message);
                      },
                      icon: const Icon(Icons.share, color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Your Referral Code',
              style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    enabled: isEditable,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Edit your referral code',
                    ),
                  ),
                ),
                SizedBox(width: 26.w),
                ElevatedButton(
                  onPressed: _saveCoupon,
                  style: ButtonStyle(
                    elevation: const WidgetStatePropertyAll(10),
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 40.h, vertical: 40.w)),
                  ),
                  child: Text(
                    'Save Code',
                    style: TextStyle(fontSize: 44.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
