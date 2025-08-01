import 'package:club/screens/event_management/barter_collab.dart';
import 'package:flutter/material.dart';

class VenueInfluencerTabs extends StatefulWidget {
  const VenueInfluencerTabs({super.key});

  @override
  State<VenueInfluencerTabs> createState() => _VenueInfluencerTabsState();
}

class _VenueInfluencerTabsState extends State<VenueInfluencerTabs> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: currentIndex == 0 ? Colors.yellow.withOpacity(0.4) : Colors.transparent,
                      ),
                      child: Text("Barter", style: TextStyle(color: Colors.white),)),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 1;
                    });
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: currentIndex == 1 ? Colors.yellow.withOpacity(0.4) : Colors.transparent,
                      ),
                      child: Text("Paid", style: TextStyle(color: Colors.white),)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if(currentIndex == 0)
            Expanded(
              key: ValueKey(currentIndex),
              child: const BarterCollab(type: 'venue', eventId: '',),
            ),
          if(currentIndex == 1)
            Expanded(
              key: ValueKey(currentIndex),
              child: const BarterCollab(paid: true, type: 'venue', eventId: '',),
            ),
        ],
      ),
    );
  }
}
