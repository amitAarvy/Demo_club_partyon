import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../utils/app_utils.dart';


class ReservedPage extends StatefulWidget {
  final data;
  final String type;
  final bool isRedirected;
  final bool isVenue;

  const ReservedPage({super.key, this.isRedirected = false, this.data, required this.type,this.isVenue =false});

  @override
  State<ReservedPage> createState() => _ReservedPageState();
}

class _ReservedPageState extends State<ReservedPage> {


  Widget titleWidget(String title) => Expanded(
      child: SizedBox(
          child: Center(
              child: Text(title,
                  style: GoogleFonts.ubuntu(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  )))));

  List durationList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    if(widget.type.toString() == 'filler'){
      print('chekc type is ${widget.type}');
      durationList = (widget.data['userList'] as List) .where((ele) => ele['type'].toString() == 'entry',).where((element) => element['couponDetail']['appliedCoupon'].toString() == 'filler',)
          .
      where((element) => element['checkIn'].toString() != '',)
    .toList();
    }else if(widget.type.toString() == 'entry'){
      durationList = (widget.data['userList'] as List)
      //     .
      // where((element) => element['duration'].toString() != '',)
          .where((ele) => ele['type'].toString() == widget.type.toString(),).where((element) => element['couponDetail']['appliedCoupon'].toString() != 'filler',).toList();
  }else{
      durationList = (widget.data['userList'] as List)
      //     .
      // where((element) => element['duration'].toString() != '',)
          .where((ele) => ele['type'].toString() == widget.type.toString(),).toList();
    }
    
    print('check duration list is ${durationList.length}');

  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Color(0xff1f51ff),
    body: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20,),
          SizedBox(
            width: Get.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                titleWidget('Name'),
                titleWidget('In'),
                titleWidget('Out'),
                titleWidget('Duration')
              ],
            ).paddingAll(20.h),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: durationList.length,
            itemBuilder: (BuildContext context, int index) {
              var data = durationList[index];
              // DateTime date = data?['date'].toDate();
              return GestureDetector(
                onTap:widget.isVenue? (){
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                      title: Text(data['name'].toString().capitalizeFirstOfEach??'',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700),),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Booking Id: ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                            Expanded(child: Text(data['bookingId']??'',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User Number: ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                            Expanded(child: Text(data['userId']??'',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gender: ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                            Text(data['gender']??'',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                          ],
                        ),
                          Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Age: ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                            Text(data['age'].toString(),style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                          ],
                        ),
                          SizedBox(height: 20,),
                          GestureDetector(
                            onTap: (){
                              Get.back();
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.all(Radius.circular(11))
                              ),
                              child: Center(child: Text('Ok',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800,),),),
                            ),
                          )
                      ],),
                    );
                  },);
                }:(){},
                child: Container(
                  width: Get.width,
                  // decoration: BoxDecoration(
                  //   color: Colors.black,
                  //   borderRadius: BorderRadius.circular(20),
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: Center(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${data['name']}',
                                  style: GoogleFonts.ubuntu(
                                    color: Colors.white,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: Center(
                            child: Text(
                              // "${!data['checkIn'].toString().contains('at')?data['checkIn']:
                              "${data['checkIn'] == ''?'-':DateFormat('dd-MM-yyyy \nMM:hh:ss').format((data['checkIn'] as Timestamp).toDate())}",
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: Center(
                            child: Text(
                              // "${!data['checkOut'].toString().contains("at")?data['checkOut']:
                        "${data['checkOut'] == ''?'-':DateFormat('dd-MM-yyyy\nMM:hh:ss').format((data['checkOut'] as Timestamp).toDate())}",
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: Center(
                            child: Text(
                              '${data['duration'] == ''?'-':data['duration'].toString()}',
                              // "${data['duration'].toString().contains('h')?data['duration']:data['duration'].toString().split(':')[0]}:${data['duration'].toString().split(':')[1]}",
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Expanded(
                      //   child: SizedBox(
                      //     child: Center(
                      //       child: data?['status'] == 'F'
                      //           ? Text(
                      //         'Failed',
                      //         style: GoogleFonts.ubuntu(
                      //           color: Colors.red,
                      //         ),
                      //       )
                      //           : Text(
                      //         'Success',
                      //         style: GoogleFonts.ubuntu(
                      //           color: Colors.green,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ).paddingAll(20.h),
              );
            },
          )
        ],
      ),
    ),
  );
}
