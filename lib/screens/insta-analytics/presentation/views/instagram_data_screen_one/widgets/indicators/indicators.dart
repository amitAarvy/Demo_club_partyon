import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Indicators extends StatelessWidget {
  final Color color;
  final String text;

  const Indicators({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 20.w),
        Container(
          height: 44.h,
          width: 52.w,
          color: color,
        ),
        SizedBox(width: 40.w),
        Text(
          text,
          style: TextStyle(fontSize: 44.sp, color: Colors.white),
        ),
      ],
    );
  }
}
