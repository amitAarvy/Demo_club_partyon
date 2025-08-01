import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/refer/presentation/controller/refer_controller.dart';
import 'package:club/screens/refer/presentation/views/widgets/refer_info_row.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReferInfoCard extends StatefulWidget {
  final String title;
  final String uid;
  final String date;

  const ReferInfoCard(
      {super.key, required this.title, required this.uid, required this.date});

  @override
  State<ReferInfoCard> createState() => _ReferInfoCardState();
}

class _ReferInfoCardState extends State<ReferInfoCard> {
  final ReferController referController = Get.put(ReferController());
  int _referCount = -1;

  void onTapView(String uid) async {
    final DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection('Refer').doc(uid).get();
    if (docSnap.exists) {
      final List referList = getKeyValueFirestore(docSnap, 'referList') ?? [];
      _referCount = referList.length;
    } else {
      _referCount = 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ReferInfoRow(text: widget.title),
            ReferInfoRow(text: widget.date),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    if (_referCount != -1)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '$_referCount refer',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    if (_referCount == -1)
                      TextButton(
                        onPressed: () async => onTapView(widget.uid),
                        child: const Text(
                          'View',
                          style: TextStyle(color: Colors.amber),
                        ),
                      )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


class ReferEarnCard extends StatefulWidget {
  final String title;
  final String uid;
  final String date;

  const ReferEarnCard(
      {super.key, required this.title, required this.uid, required this.date});

  @override
  State<ReferEarnCard> createState() => _ReferEarnCardState();
}

class _ReferEarnCardState extends State<ReferEarnCard> {
  final ReferController referController = Get.put(ReferController());
  int _referCount = 0;

  void onTapView(String uid) async {
    final DocumentSnapshot docSnap =
    await FirebaseFirestore.instance.collection('Refer').doc(uid).get();
    if (docSnap.exists) {
      final List referList = getKeyValueFirestore(docSnap, 'referList') ?? [];
      _referCount = referList.length;
    } else {
      _referCount = 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ReferInfoRow(text: widget.title),
            ReferInfoRow(text: widget.date),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    // if (_referCount != -1)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '$_referCount ',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    // if (_referCount == -1)
                    //   TextButton(
                    //     onPressed: () async => onTapView(widget.uid),
                    //     child: const Text(
                    //       'View',
                    //       style: TextStyle(color: Colors.amber),
                    //     ),
                    //   )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}