import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_two/presentation/widgets/instagram_data_card.dart';

class DataTile extends StatelessWidget {
  final String iconImage;
  final String title;
  final int value;

  const DataTile({
    super.key,
    required this.iconImage,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return InstagramDataCard(
      isFutureBuilder: false,
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        initiallyExpanded: true,
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        tilePadding: EdgeInsets.symmetric(horizontal: 28.w),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 56.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(iconImage,
                  fit: BoxFit.fill,
                  height: 800.h,
                  width: 1000.w
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 160.sp,
                    color: Colors.white),
              ),
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40.sp,
                    color: Colors.white),
              )
            ],
          ),
        ],
      ),
    );
  }
}
