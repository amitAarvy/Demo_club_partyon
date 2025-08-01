import 'package:club/screens/event_management/barter_collab.dart';
import 'package:club/screens/event_management/venue_influencer_tabs.dart';
import 'package:club/screens/event_management/venue_promotion_create.dart';
import 'package:flutter/material.dart';

class VenueTabs extends StatefulWidget {
  final String businessCategory;
  const VenueTabs({super.key, required this.businessCategory});

  @override
  State<VenueTabs> createState() => _VenueTabsState();
}

class _VenueTabsState extends State<VenueTabs> {

  int currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.businessCategory != "1"){
      currentIndex = 1;
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        if(widget.businessCategory == "1")
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
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: currentIndex == 0 ? Colors.yellow.withOpacity(0.4) : Colors.transparent,
                      ),
                      child: Text("Promoter Collab's", style: TextStyle(color: Colors.white),)),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 1;
                    });
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: currentIndex == 1 ? Colors.yellow.withOpacity(0.4) : Colors.transparent,
                      ),
                      child: Text("Influencer Collab's", style: TextStyle(color: Colors.white),)),
                ),
              ],
            ),
          ),
        if(currentIndex == 0)
          Expanded(
            child: VenuePromotionCreate(
              // isOrganiser: widget.isOrganiser,
              // isPromoter: widget.isPromoter,
              // isClub: widget.isClub,
              eventId: ("data.id").toString(),
            ),
          ),
        if(currentIndex == 1)
          Expanded(child: VenueInfluencerTabs()),
      ],
    );
  }
}
