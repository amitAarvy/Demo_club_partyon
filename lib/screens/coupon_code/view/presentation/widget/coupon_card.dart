import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CouponCard extends StatelessWidget {
  final String titleText;
  final Widget widget;
  const CouponCard({super.key, required this.titleText, required this.widget});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff451F55),
      margin: const EdgeInsets.all(20),
      elevation: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              titleText,
              style: TextStyle(
                  fontSize: 48.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          widget,
        ],
      ),
    );
  }
}
