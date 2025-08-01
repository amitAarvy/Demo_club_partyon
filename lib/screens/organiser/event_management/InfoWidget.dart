// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables


import 'package:flutter/material.dart';

class InfoWidget extends StatelessWidget {
  final String title;
  // final String headingSubTitle;
  final String subtitle;
  const InfoWidget({
    super.key,
    required this.title,
    // required this.headingSubTitle,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0,vertical: 5.0),
      child: Padding(
        padding: EdgeInsets.all(2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.0,
                    color: Colors.grey,
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
