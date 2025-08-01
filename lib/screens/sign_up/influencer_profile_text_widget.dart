import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_utils.dart';

class InfluencerProfileTextWidget extends StatelessWidget {
  final String text;
  final String? value;

  const InfluencerProfileTextWidget(
      {super.key, required this.text, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6)
              .copyWith(bottom: 0),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(8),
            color: matte(),
          ),
          child: Text(
            value ?? 'Null',
            style: GoogleFonts.merriweather(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
