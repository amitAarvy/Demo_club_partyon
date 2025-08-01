import 'package:club/screens/insta-analytics/models/audience_demographics.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/age_wise_engagement/age_wise_engagement.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_two/presentation/widgets/profile_insights/gender_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'demographic_data/demographic_data.dart';
import 'instagram_data_card.dart';

class InstagramDataScreenTwo extends StatefulWidget {
  final RetrieveAudienceDemographics? demographicsData;

  const InstagramDataScreenTwo({super.key, this.demographicsData});

  @override
  State<InstagramDataScreenTwo> createState() => _InstagramDataScreenTwoState();
}

class _InstagramDataScreenTwoState extends State<InstagramDataScreenTwo> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 28.w),
        child: Column(children: [
          InstagramDataCard(
            isFutureBuilder: false,
            child: GenderData(audienceDemographics: widget.demographicsData),
          ),
          SizedBox(height: 20.h),
          InstagramDataCard(
            isFutureBuilder: false,
            child: AgeWiseEngagement(
                audienceDemographics: widget.demographicsData),
          ),
          SizedBox(height: 20.h),
          InstagramDataCard(
            isFutureBuilder: false,
            child:
                DemographicData(audienceDemographics: widget.demographicsData),
          ),
        ]),
      ),
    );
  }
}
