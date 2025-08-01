import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/arrow_pages/travel_slider_arrow.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_slider_tap.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TravelCarousel extends StatefulWidget {
  final List groomingList;
  const TravelCarousel({super.key, required this.groomingList});

  @override
  State<TravelCarousel> createState() => _TravelCarouselState();
}

class _TravelCarouselState extends State<TravelCarousel> {
  // List? groomingList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchGroomingList();
  }

  // void fetchGroomingList() async{
  //   QuerySnapshot data = await FirebaseFirestore.instance.collection('Club').get();
  //   List groomData = data.docs.where((element) => (element.data() as Map<String, dynamic>)['businessCategory']!=null && element['businessCategory'] == 2).toList();
  //   groomingList = [];
  //   for(var element in groomData){
  //     QuerySnapshot data = await FirebaseFirestore.instance
  //         .collection("EventPromotion")
  //         .where('collabType', isEqualTo: 'influencer')
  //         .where("clubUID", isEqualTo: element.id)
  //         .get();
  //     List saveData = [];
  //     for(var ele in data.docs){
  //       QuerySnapshot reqData = await FirebaseFirestore.instance
  //           .collection("PromotionRequest")
  //           .where('eventPromotionId', isEqualTo: ele['id'])
  //           .where('influencerPromotorId', isEqualTo: uid())
  //           .get();
  //       if(reqData.docs.isEmpty || (reqData.docs.isNotEmpty && reqData.docs[0]['status'] != 4)) {
  //         DateTime startTime = ele['startTime'].toDate();
  //         if ((startTime.year == DateTime.now().year && startTime.month == DateTime.now().month && startTime.day == DateTime.now().day) || startTime.isAfter(DateTime.now())) {
  //           saveData.add(ele);
  //         }
  //       }
  //     }
  //     saveData.sort((a, b) => (a['startTime'].toDate() as DateTime).compareTo(b['startTime'].toDate() as DateTime));
  //     if(saveData.isNotEmpty){
  //       groomingList = [...groomingList!, {...element.data(), ...{"promotionData": saveData[0].data()}}];
  //     }
  //   }
  //   if (mounted) {
  //     setState(() {});
  //   }  }

  @override
  Widget build(BuildContext context) {
    return widget.groomingList == null
        ? const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
        )
      : widget.groomingList!.isEmpty
        ? const Offstage()
        : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Travel & Staycation's", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () {
                      Get.to(TravelSliderArrow());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange
                      ),
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 15),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            CarouselSlider.builder(
                  itemCount: widget.groomingList!.length,
                  itemBuilder: (context, index, realIndex) {
            return GestureDetector(
              onTap: () {
                Get.to(GroomingSliderTap(clubUid: widget.groomingList![index]['clubUID']));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.white,
                        offset: Offset(1, 1),
                        blurRadius: 5
                    )
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // alignment: Alignment.bottomCenter,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.groomingList![index]['coverImage'],
                          fit: BoxFit.fill,
                          height: 170,
                          width: MediaQuery.of(context).size.width * 0.8,
                          loadingBuilder: (context, child, loadingProgress) {
                            if(loadingProgress == null) return child;
                            return Center(
                              child:
                              AspectRatio(
                                aspectRatio: 9/16,
                                child: Image.asset('assets/loading_shimmer.gif',fit: BoxFit.cover,
                                  width:
                                  double.infinity,),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_outlined, color: Colors.white,);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${widget.groomingList![index]['clubName']} ',
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.white),
                                    ),
                                    // Text(
                                    //   groomingList![index]['promotionData']['status'] == 2 ? '(In Review)' : '',
                                    //   style: GoogleFonts.ubuntu(
                                    //       color: Colors.green),
                                    // ),
                                  ],
                                ),
                                Text(
                                  "${widget.groomingList![index]['promotionData']['acceptedBy']}/${widget.groomingList![index]['promotionData']['noOfBarterCollab']} ${widget.groomingList![index]['promotionData']['acceptedBy'] == widget.groomingList![index]['promotionData']['noOfBarterCollab'] ? "(Slots full)" : ''}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white),
                                )
                              ],
                            ),
                            Divider(color: Colors.white),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${DateFormat(
                                      'dd-MM-yy hh:mm a')
                                      .format(
                                      widget.groomingList![index]['promotionData']['startTime']
                                          .toDate() ??
                                          DateTime.now())}',
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white),
                                ),
                                Text(
                                  widget.groomingList![index]['promotionData']['isPaid'] == null ? '' : widget.groomingList![index]['promotionData']['isPaid'] ? "Paid" : "Barter",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
                  },
                  options: CarouselOptions(
            height: 280,
            enlargeCenterPage: true,
            enlargeFactor: kIsWeb ? 0.01 : 0.15,
            viewportFraction: kIsWeb ? 0.3 : 0.8,
            autoPlay: true,
                  ),
                ),
          ],
        );
  }
}
