import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfluencerDisqualification {
  static void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            "Seems, You're Not Qualified!",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff3C4F76),
                fontSize: 28),
          ),
          content: const Text(
            "It seems your followers are currently below 1000, and your engagement rate doesn't meet the minimum criteria. \n \n But don't be discouraged! Keep engaging and growing your community, and we look forward to seeing you back soon.",
            style: TextStyle(color: Color(0xff3C4F76), fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3C4F76),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Center(
                child: Text("Visit Again Soon....",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
          ],
        );
      },
    );
  }
}
