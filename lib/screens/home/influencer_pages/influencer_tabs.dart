import 'package:club/screens/home/influencer_pages/pending_request.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';

class InfluencerTabs extends StatefulWidget {
  final int status;
  const InfluencerTabs({super.key, required this.status});

  @override
  State<InfluencerTabs> createState() => _InfluencerTabsState();
}

class _InfluencerTabsState extends State<InfluencerTabs> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: currentIndex == 0 ? Colors.yellow.withOpacity(0.4) : Colors.transparent,
                      ),
                      child: const Text("Venue", style: TextStyle(color: Colors.white),)),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 1;
                    });
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: currentIndex == 1 ? Colors.yellow.withOpacity(0.4) : Colors.transparent,
                      ),
                      child: const Text("Promoter", style: TextStyle(color: Colors.white),)),
                ),
              ],
            ),
          ),
          if(currentIndex == 0)
            Expanded(
              key: ValueKey(currentIndex),
              child: PendingRequest(key: const ValueKey("venue"), status: widget.status, type: "venue"),
            ),
          if(currentIndex == 1)
            Expanded(
              key: ValueKey(currentIndex),
              child: PendingRequest(key: const ValueKey("influencer"), status: widget.status, type: "influencer"),
            )
        ],
      ),
      // floatingActionButton: widget.isPromoter
      //     ? SizedBox(
      //         width: 350.w,
      //         child: FloatingActionButton(
      //           backgroundColor: Colors.orange,
      //           shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(15)),
      //           child: const Text('Promoter Link'),
      //           onPressed: () => onTapShareOptions(isPromotion: true),
      //         ))
      //     : widget.isClub
      //         ? FloatingActionButton(
      //             onPressed: () async {
      //               // final homeController = Get.put(HomeController());
      //               final scanResult = await barCodeScannerResult();
      //               List<String> scanResultData = scanResult.split('|');
      //               final bookingId = scanResultData[0];
      //               final clubUID = scanResultData[1];
      //               //final clubId = scanResultData[2];
      //               if (scanResult.isNotEmpty && scanResult != '-1') {
      //                 if (clubUID == uid()) {
      //                   Get.to(BookingDetails(bookingID: bookingId));
      //                 } else {
      //                   Fluttertoast.showToast(
      //                       msg: 'Booking is not made for this place');
      //                 }
      //               } else {
      //                 Fluttertoast.showToast(msg: 'Booking Id not found');
      //               }
      //             },
      //             backgroundColor: Colors.red,
      //             child: const Icon(Icons.document_scanner_outlined),
      //           )
      //         : const SizedBox(),
    );
  }
}
