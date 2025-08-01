import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/bookings/booking_details.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database_platform_interface/src/transaction.dart'
    as transaction;

bool checkTable(BookingController bookingController,
    List<TextEditingController> tableTextController) {
  int tableCount = 0;
  for (int i = 0; i < bookingController.tableList.length; i++) {
    if (tableTextController[i].text.isNotEmpty) {
      if (int.parse(tableTextController[i].text) >
          bookingController.tableList[i]['bookingCountLeft']) {
        tableCount++;
        break;
      }
    }
  }
  return tableCount > 0 ? false : true;
}

bool checkEntrance(BookingController bookingController,
    List<TextEditingController> entranceTextController) {
  int count = 0;
  for (int i = 0; i < bookingController.getEntranceList.length; i++) {
    if (entranceTextController[i].text.isNotEmpty) {
      if (int.parse(entranceTextController[i].text) >
          bookingController.getEntranceList[i]['bookingCountLeft']) {
        count++;
        break;
      }
    }
  }
  return count > 0 ? false : true;
}

bool checkEntranceForZero(BookingController bookingController,
    List<TextEditingController> entranceTextController) {
  int count = 0;
  for (int i = 0; i < bookingController.getEntranceList.length; i++) {
    if (entranceTextController[i].text.isNotEmpty == true) {
      if (int.parse(entranceTextController[i].text) > 0) {
        count++;
        break;
      }
    }
  }
  return count > 0 ? true : false;
}

bool checkTableForZero(BookingController bookingController,
    List<TextEditingController> tableList) {
  int count = 0;
  for (int i = 0; i < bookingController.tableList.length; i++) {
    if (tableList[i].text.isNotEmpty == true) {
      if (int.parse(tableList[i].text) > 0) {
        count++;
        break;
      }
    }
  }
  return count > 0 ? true : false;
}

bool isRemainingEntries({
  required List entranceList,
  required List tableList,
}) {
  final hasEntranceRemaining = entranceList
      .where((element) => (element['bookingCountLeft'] ?? 0) > 0)
      .isNotEmpty;

  final hasTableRemaining = tableList.isNotEmpty &&
      tableList
          .where((element) => (element['bookingCountLeft'] ?? 0) > 0)
          .isNotEmpty;

  return hasEntranceRemaining || hasTableRemaining;
}


Future<void> updateAsTransactionBooking(
    String bookingID, String categoryId, int increment,
    {bool isTableBooking = false}) async {
  try {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child(
        'Bookings/$bookingID/${isTableBooking ? 'tableList' : 'entranceList'}/$categoryId/bookingCountLeft');
    await ref.runTransaction((mutableData) {
      final currentValue = (mutableData) as int? ?? 0;
      return transaction.Transaction.success(
          (currentValue + ((currentValue - increment >= 0) ? increment : 0)));
      // else return Transaction.abort();
    });
  } on FirebaseException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
  }
}
