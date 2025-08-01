import 'package:club/screens/insta-analytics/controller/phyllo_controller.dart';
import 'package:club/screens/insta-analytics/models/audience_demographics.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/age_wise_engagement/engagement_percent.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/data_filter_button/gender_views_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DemographicData extends StatefulWidget {
  final RetrieveAudienceDemographics? audienceDemographics;

  const DemographicData({super.key, this.audienceDemographics});

  @override
  State<DemographicData> createState() => _DemographicDataState();
}

class _DemographicDataState extends State<DemographicData> {
  final PhylloController controller = Get.put(PhylloController());

  @override
  Widget build(BuildContext context) {
    List<Cities>? cityResults = widget.audienceDemographics?.cities;
    List<Countries>? countryResults = widget.audienceDemographics?.countries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audience Demographics',
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
              isAudienceDemographics: true,
              text: 'Countries',
            ),
            SizedBox(width: 20.w),
            const GenderViewsFilter(
              isAudienceDemographics: true,
              text: 'Cities',
            ),
          ],
        ),
        SizedBox(height: 40.h),
        Obx(() {
          bool isCitiesSelected =
              controller.demographicDataType.value == 'Cities';
          List results = (isCitiesSelected ? cityResults : countryResults) ?? [];

          if (results.isNotEmpty) {
            return Column(
              children: results.map((e) {
                if (isCitiesSelected) {
                  final Cities city = e as Cities;
                  return EngagementData(
                    name: city.name ?? '',
                    value: ((city.value) as num).toDouble().toPrecision(2) ?? 0,
                  );
                } else {
                  final Countries country = e as Countries;
                  return EngagementData(
                    name: country.code ?? '',
                    value:
                        ((country.value) as num).toDouble().toPrecision(2) ?? 0,
                  );
                }
              }).toList(),
            );
          } else {
            return Text(
              'No Audience Demographics Data',
              style: TextStyle(color: Colors.white, fontSize: 52.sp),
            );
          }
        }),
      ],
    );
  }
}
