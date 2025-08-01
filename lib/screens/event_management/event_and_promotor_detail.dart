import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

class EventAndPromotorDetail extends StatefulWidget {
  final String dataId;
  final bool isInf;
  final Map<String, dynamic> data;
  const EventAndPromotorDetail({super.key, required this.data, required this.dataId,  this.isInf=false});

  @override
  State<EventAndPromotorDetail> createState() => _EventAndPromotorDetailState();
}

class _EventAndPromotorDetailState extends State<EventAndPromotorDetail> {
  Map<String, dynamic>? promotorDetail;
  List? tablesData;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.data);
    fetchPromotorData();
  }
  
  void fetchPromotorData() async{
    QuerySnapshot table = await FirebaseFirestore.instance
        .collection('Events')
        .doc(widget.dataId)
        .collection('Tables')
        .get();
    tablesData = table.docs;
    DocumentSnapshot promotor = await FirebaseFirestore.instance
        .collection('Organiser')
        .doc(widget.data['organiserID'])
        .get();
    promotorDetail = promotor.data() as Map<String, dynamic>;
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Organiser Details"),
      body: promotorDetail == null || tablesData == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.network(promotorDetail!['profile_image'], fit: BoxFit.contain),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("PR / Organiser Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
                        const SizedBox(width: 15),
                        Expanded(child: Text("${promotorDetail!['companyMame']}", style: TextStyle(color: Colors.white), textAlign: TextAlign.right)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Contact", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
                        Text("${promotorDetail!['name']}", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Whatsapp No.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
                        Text("${promotorDetail!['whatsaapNo'] ==null ? 'Not Available' : promotorDetail!['whatsaapNo']}", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 50),
                    const Text("Event Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 25)),
                    const SizedBox(height: 15),
                    Image.network(widget.data['coverImages'][0], fit: BoxFit.contain),
                    const SizedBox(height: 10),
                    const Align(
                        alignment: Alignment.center,
                        child: Text("Cover Image", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(10),
                      // decoration: BoxDecoration(
                      //     color: Colors.grey.shade900,
                      //     borderRadius: BorderRadius.circular(20)
                      // ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("${widget.data['title'].toString().capitalize}", style: TextStyle(color: Colors.white, fontSize: 30)),
                          // const SizedBox(height: 10),
                          Text("${widget.data['briefEvent']}", style: TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 10),
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(Icons.calendar_month_outlined, color: Colors.white, size: 18),
                              // const Text("Start Date : ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                              const SizedBox(width: 10),
                              Text("${DateFormat.yMMMd().format(widget.data['startTime'].toDate())}", style: TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(Icons.access_time, color: Colors.white, size: 18),
                              // const Text("Start Time : ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                              const SizedBox(width: 10),
                              Text("${DateFormat('hh:mm a').format(widget.data['startTime'].toDate())} (${widget.data['duration']} hours)", style: TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          // const SizedBox(height: 15),
                          // Row(
                          //   // crossAxisAlignment: CrossAxisAlignment.stretch,
                          //   children: [
                          //     Icon(Icons.timelapse_outlined, color: Colors.white, size: 18),
                          //     // const Text("Duration : ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                          //     const SizedBox(width: 10),
                          //     Text("${widget.data['duration']} hours", style: TextStyle(color: Colors.white, fontSize: 16)),
                          //   ],
                          // ),
                          const SizedBox(height: 15),
                          const Text("Artist lineup", style: TextStyle(color: Colors.white, fontSize: 18, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                          const SizedBox(height: 15),
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(Icons.portrait_outlined, color: Colors.white, size: 18),
                              // const Text("Artist Name : ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                              const SizedBox(width: 10),
                              Text("${widget.data['artistName']}", style: TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(Icons.face, color: Colors.white, size: 18),
                              // const Text("Genre : ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                              const SizedBox(width: 10),
                              Text("${widget.data['genre']}", style: TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                  "Category : ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                      // decoration: TextDecoration.underline,
                                      // decorationColor: Colors.white,
                                  ),
                              ),
                              const SizedBox(height: 5),
                              // Text("${widget.data['entranceList']} hours", style: TextStyle(color: Colors.white)),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: widget.data['entranceList'].length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text("${widget.data['entranceList'][index]['categoryName']}", style: TextStyle(color: Colors.white)),
                                      const SizedBox(height: 5),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade900,
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: widget.data['entranceList'][index]['subCategory'].length,
                                          separatorBuilder: (context, index) {
                                            return const SizedBox(height: 20);
                                          },
                                          itemBuilder: (context, itemIndex) {
                                            Map<String, dynamic> subCategoryData = widget.data['entranceList'][index]['subCategory'][itemIndex];
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Text("${subCategoryData['entryCategoryName']}", style: TextStyle(color: Colors.white)),
                                                const SizedBox(height: 5),
                                                Text("No. of entries : ${subCategoryData['entryCategoryCount']}", style: TextStyle(color: Colors.white)),
                                                const SizedBox(height: 5),
                                                Text("Price : ${subCategoryData['entryCategoryPrice']}/pax", style: TextStyle(color: Colors.white)),
                                              ],
                                            );
                                          },
                                        ),
                                      )
                                    ],
                                  );
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                  "Tables : ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                      // decoration: TextDecoration.underline,
                                      // decorationColor: Colors.white,
                                  ),
                              ),
                              const SizedBox(height: 5),
                              // Text("${widget.data['entranceList']} hours", style: TextStyle(color: Colors.white)),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: tablesData!.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text("Name : ${tablesData![index]['tableName']}", style: TextStyle(color: Colors.white)),
                                        const SizedBox(height: 5),
                                        Text("Seat Available : ${tablesData![index]['seatsAvail']}", style: TextStyle(color: Colors.white)),
                                        const SizedBox(height: 5),
                                        Text("Table Available : ${tablesData![index]['tableAvail']}", style: TextStyle(color: Colors.white)),
                                        const SizedBox(height: 5),
                                        Text("Table Price : ${tablesData![index]['tablePrice']}", style: TextStyle(color: Colors.white)),
                                      ],
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
