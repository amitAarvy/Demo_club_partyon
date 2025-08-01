import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EngagementData extends StatelessWidget {
  final String name;
  final double value;
  final String gender;

  const EngagementData(
      {super.key,
      required this.name,
      required this.value,
      this.gender = ''});

  @override
  Widget build(BuildContext context) {
      return SizedBox(
      height: 140.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  name ,
                  style: TextStyle(
                      fontSize: 48.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis),
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 20.w),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  gender,
                  style: TextStyle(
                      fontSize: 48.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  elevation: 8,
                  child: LinearProgressIndicator(
                    minHeight: 16,
                    backgroundColor: Colors.white,
                    value: value / 100,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  "$value",
                  style: TextStyle(
                      fontSize: 48.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    }
  }

