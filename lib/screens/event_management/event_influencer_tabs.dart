import 'package:club/screens/event_management/barter_collab.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';

class EventInfluencerTabs extends StatefulWidget {
  final String? eventName;
  final String? eventId;
  final bool? isOrganiser;
  const EventInfluencerTabs({super.key, this.eventName,this.isOrganiser,this.eventId});

  @override
  State<EventInfluencerTabs> createState() => _EventInfluencerTabsState();
}

class _EventInfluencerTabsState extends State<EventInfluencerTabs> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: 'Influencer Promotion'),
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
                child: BarterCollab(eventName: widget.eventName, type: 'event',isOrganiser: widget.isOrganiser,eventId: widget.eventId.toString(),),
            ),
          if(currentIndex == 1)
            Expanded(
                key: ValueKey(currentIndex),
                child: BarterCollab(paid: true, eventName: widget.eventName, type: 'event',isOrganiser: widget.isOrganiser,eventId: widget.eventId.toString(),),
            ),
        ],
      ),
    );
  }
}
