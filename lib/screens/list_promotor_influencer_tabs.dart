import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/promotion_list.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../utils/app_utils.dart';

class ListPromoterInfluencerTabs extends StatefulWidget {
  final String isOrganiser;
  const ListPromoterInfluencerTabs({super.key, required this.isOrganiser});

  @override
  State<ListPromoterInfluencerTabs> createState() => _ListPromoterInfluencerTabsState();
}

class _ListPromoterInfluencerTabsState extends State<ListPromoterInfluencerTabs> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('PromotionRequest').where('venueId',isEqualTo: uid()).snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      int notificationCount = 0;
      if (snapshot.hasError) {
        notificationCount = 0;
        // return Center(child: Text('Error: ${snapshot.error}'));
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        notificationCount = 0;
        // return Center(child: CircularProgressIndicator());
      }
      notificationCount = snapshot.data == null
          ? 0
          : snapshot.data!.docs
          .where((doc) {
        var data1 = doc.data() as Map<String, dynamic>;
        return data1.containsKey('venueId') &&
            data1.containsKey('notification') &&
            doc['notification'].toString() == 'true' && doc['collabType'].toString() == 'promotor' ;
      }).toList().length;
     int notificationCountInf = snapshot.data == null
          ? 0
          : snapshot.data!.docs
          .where((doc) {
        var data1 = doc.data() as Map<String, dynamic>;
        return data1.containsKey('venueId') &&
            data1.containsKey('notification') &&
            doc['notification'].toString() == 'true'  && doc['collabType'].toString() != 'promotor';
      }).toList().length;



      return Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = 0;
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: currentIndex == 0 ? Colors.yellow.withOpacity(
                              0.4) : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            const Text("Promoter Collab's",
                              style: TextStyle(color: Colors.white),),
                            if(notificationCount !=0)
                            SizedBox(width: 5,),
                            if(notificationCount !=0)
                            Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green
                              ),
                              child: Center(child: Text(notificationCount.toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),),
                            )

                                                    ],
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = 1;
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: currentIndex == 1 ? Colors.yellow.withOpacity(
                              0.4) : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            const Text("Influencer Collab's",
                              style: TextStyle(color: Colors.white),),
                            if(notificationCountInf !=0)
                            SizedBox(width: 5,),
                            if(notificationCountInf !=0)
                            Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green
                              ),
                              child: Center(child: Text(notificationCountInf.toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),),
                            )
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
          if(currentIndex == 0)
            Expanded(
              key: ValueKey(currentIndex),
              child: PromotionList(
                collabType: "promotor", isOrganiser: widget.isOrganiser,),
            ),
          if(currentIndex == 1)
            Expanded(
              key: ValueKey(currentIndex),
              child: PromotionList(
                  collabType: "influencer", isOrganiser: widget.isOrganiser),
            ),
        ],
      );
    }
    );
  }
}
