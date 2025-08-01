import 'package:club/screens/insta-analytics/controller/phyllo_controller.dart';
import 'package:club/screens/insta-analytics/models/audience_demographics.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/data_filter_button/gender_views_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'engagement_percent.dart';

class AgeWiseEngagement extends StatefulWidget {
  final RetrieveAudienceDemographics? audienceDemographics;

  const AgeWiseEngagement({super.key, this.audienceDemographics});

  @override
  State<AgeWiseEngagement> createState() => _AgeWiseEngagementState();
}

class _AgeWiseEngagementState extends State<AgeWiseEngagement> {
  final PhylloController controller = Get.put(PhylloController());

  @override
  Widget build(BuildContext context) {
    List<GenderAgeDistribution>? ageResults =
        widget.audienceDemographics?.genderAgeDistribution;

    final List<GenderAgeDistribution>? malesList =
        ageResults?.where((e) => e.gender == 'MALE').toList();

    final List<GenderAgeDistribution>? femaleList =
        ageResults?.where((e) => e.gender == 'FEMALE').toList();

    final List<GenderAgeDistribution>? otherList =
        ageResults?.where((e) => e.gender == 'OTHER').toList();

    if (ageResults != null && ageResults.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Age-wise Engagement %',
            style: TextStyle(
                fontSize: 66.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const GenderViewsFilter(
                text: 'Males',
              ),
              SizedBox(width: 20.w),
              const GenderViewsFilter(
                text: 'Females',
              ),
              SizedBox(width: 20.w),
              const GenderViewsFilter(
                text: 'Others',
              ),
            ],
          ),
          SizedBox(height: 40.h),
          Obx(() {
            bool isMaleSelected = (controller.gender == 'Males');
            bool isFemaleSelected = (controller.gender == 'Females');
            List<GenderAgeDistribution> genderResults = (isMaleSelected
                    ? malesList
                    : (isFemaleSelected ? femaleList : otherList)) ??
                [];
            print('isMaleSelected ${controller.gender}');

            if (genderResults.isNotEmpty) {
              return Column(
                children: genderResults
                    .map((e) => EngagementData(
                          name: e.ageRange ?? '',
                          value: e.value?.toDouble().toPrecision(2) ?? 0,
                        ))
                    .toList(),
              );
            } else {
              return Text(
                'No Age Engagement Data Available!',
                style: TextStyle(color: Colors.white, fontSize: 52.sp),
              );
            }
          }),
        ],
      );
    } else {
      return Text(
        'No Age Engagement Data Available!',
        style: TextStyle(color: Colors.white, fontSize: 52.sp),
      );
    }
  }
}
