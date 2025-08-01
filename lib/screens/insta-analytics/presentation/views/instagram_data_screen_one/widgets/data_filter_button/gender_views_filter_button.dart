import 'package:club/screens/insta-analytics/controller/phyllo_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GenderViewsFilter extends StatefulWidget {
  final String text;
  final bool isAudienceDemographics;

  const GenderViewsFilter(
      {super.key, required this.text, this.isAudienceDemographics = false});

  @override
  State<GenderViewsFilter> createState() => _GenderViewsFilterState();
}

class _GenderViewsFilterState extends State<GenderViewsFilter> {
  final PhylloController controller = Get.put(PhylloController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextButton(
        onPressed: () {
          if (widget.isAudienceDemographics == true) {
            controller.demographicDataType.value = widget.text;
          } else {
            controller.gender = widget.text;
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll((widget.isAudienceDemographics
                      ? controller.demographicDataType.value
                      : controller.gender) ==
                  widget.text
              ? Colors.black
              : Colors.grey),
          elevation: const WidgetStatePropertyAll(6),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(7)),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
              fontSize: 40.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }
}
