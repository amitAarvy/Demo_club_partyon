import 'package:flutter/material.dart';

class InstagramDataConst {


  static List<Map<String, dynamic>> viewsData(
          int followCount, int nonFollowCount) =>
      [
        {"views": followCount, "color": Colors.blue},
        {"views": nonFollowCount, "color": Colors.pink},
      ];


  static List<Map<String, dynamic>> ageWiseEngagement = [
    {"ageGroup": "13-17", "percent": 20, "gender": "Men"},
    {"ageGroup": "18-24", "percent": 60, "gender": "Women"},
    {"ageGroup": "25-34", "percent": 10, "gender": "Men"},
    {"ageGroup": "35-44", "percent": 80, "gender": "Women"},
    {"ageGroup": "45-54", "percent": 50, "gender": "Men"},
    {"ageGroup": "55-64", "percent": 90, "gender": "Women"},
    {"ageGroup": "65+", "percent": 40, "gender": "Men"},
  ];

  static List instagramTabList = ["Media Insights", "Profile Insights"];
}
