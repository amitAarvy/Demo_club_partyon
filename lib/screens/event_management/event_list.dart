import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/event_and_promotor_detail.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/event_management/event_management.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class EventList extends StatefulWidget {
  final bool isOrganiser;
  final bool isPendingRequest;

  const EventList(
      {Key? key, this.isOrganiser = false, this.isPendingRequest = false})
      : super(key: key);

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final homeController = Get.put(HomeController());

  Widget eventCard(
          {required int index,
          required DocumentSnapshot data,
          required DateTime date,
            required bool isDeleteCheck
          }){

    print('check ${getKeyValueFirestore(data, 'deleteReq')}');
    return SizedBox(
      width: Get.width,
      child: Row(
        children: [

          Expanded(
            child: SizedBox(
                child: Center(
                    child: Text(
                      "${data["title"]}".toString().capitalizeFirstOfEach,
                      style: GoogleFonts.ubuntu(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
          ),
          Expanded(
            child: SizedBox(
                child: Center(
                    child: Text(
                      "${date.day}-${date.month}-${date.year}",
                      style: GoogleFonts.ubuntu(color: Colors.white),
                    ))),
          ),
          // if(isDeleteCheck == false)
          Expanded(
            child: GestureDetector(
              onTap: ()async{

                if(isDeleteCheck){
                  showDialog(context: context, builder: (context){
                    return AlertDialog(
                      title: Text('Alert',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                      content: Text('Please send a delete request to the admin',style: TextStyle(fontWeight: FontWeight.w500),),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap:(){
                                Get.back();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(11)),

                                ),
                                child: Center(child: Text('No',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13),),),
                              ),
                            ),
                            GestureDetector(
                              onTap: getKeyValueFirestore(data, 'deleteReq')==null?()async{
                                await FirebaseFirestore.instance
                                    .collection('DeleteList')
                                    .add({
                                  "eventId": data.id,
                                  "eventData": data.data(),
                                  "deletedAt": FieldValue.serverTimestamp(), // optional
                                });
                                await FirebaseFirestore.instance.collection('Events').doc(data.id).update({
                                  "deleteReq":'Yes'
                                });
                                Get.back();
                              }:null,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.all(Radius.circular(11)),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                child: Center(child: Text('Yes',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),),
                              ),
                            ),
                          ],
                        )
                      ],

                    );
                  });
                }else {
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                      title: Text('Alert', style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),),
                      content: Text('Do you want to sure?',
                        style: TextStyle(fontWeight: FontWeight.w500),),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(11)),
                                ),
                                child: Center(child: Text('No',
                                  style: TextStyle(fontWeight: FontWeight.w600,
                                      fontSize: 13),),),
                              ),
                            ),

                            GestureDetector(
                              onTap: () async {
                                await FirebaseFirestore.instance
                                    .collection(
                                    'Events') // your collection name
                                    .doc(data.id)
                                    .delete();
                                setState(() {});
                                print('check event delete success');
                                Get.back();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(11)),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                child: Center(child: Text('Yes',
                                  style: TextStyle(fontWeight: FontWeight.w600,
                                      color: Colors.white),),),
                              ),
                            ),
                          ],
                        )
                      ],

                    );
                  });
                }
              },
              child: SizedBox(
                  child: Center(
                      child: Icon(Icons.delete,color: Colors.red,)),
                        ),
            ),),
        ],
      ).paddingSymmetric(vertical: 60.h),
    );
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // deleteOldDocs();
    bookingList();
  }

  List bookingListData = [];
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  bookingList()async{
    isLoading.value =true;
    var eventSnapshot = await FirebaseFirestore.instance
        .collection("Bookings")
        .get();

    bookingListData = eventSnapshot.docs;
    isLoading.value =false;
  }

  // void deleteOldDocs() async {
  //   final now = DateTime.now();
  //   final cutoff = now.subtract(const Duration(days: 60));
  //
  //   final query = await FirebaseFirestore.instance
  //       .collection('Events')
  //       .where('endTime', isLessThan: Timestamp.fromDate(cutoff))
  //       .get();
  //
  //   for (var doc in query.docs) {
  //     await doc.reference.delete();
  //   }
  //   debugPrint('${query.docs.length} old docs deleted.');
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: appBar(context, title: "Event List", key: _key),
      drawer: drawer(isOrganiser: widget.isOrganiser,context: context),
      body: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, bool loading, child) {
          if(loading){
            return Center(child: CircularProgressIndicator(),);
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("Events")
                        .where(widget.isOrganiser ? 'organiserID' : 'clubUID',
                        isEqualTo: uid())
                        .orderBy('date', descending: true)
                        .get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (kDebugMode) {
                        print(uid());
                        print(snapshot.data?.docs.length);
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: Get.height - 500.h,
                          width: Get.width,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.data?.docs.length == null ||
                          snapshot.data?.docs.isEmpty == true) {
                        return SizedBox(
                          height: Get.height - 500.h,
                          width: Get.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No events found",
                                style:
                                TextStyle(color: Colors.white, fontSize: 70.sp),
                              ),
                            ],
                          ),
                        );
                      } else {

                        return ListView.builder(
                            itemCount: snapshot.data?.docs.length,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              try {
                                DocumentSnapshot data = (snapshot.data?.docs[index])
                                as DocumentSnapshot;
                                String eventId = data.id;
                                // print('check event id ${data.id}');
                                // print('check eventbooking ${bookingListData[0]['eventID']}');
                                bool isDelete = bookingListData.any((e)=> e['eventID'].toString() == eventId);
                                print('Rendering index: $index, isDelete: $isDelete');
                                DateTime date =
                                getKeyValueFirestore(data, 'date').toDate();
                                bool isPending =
                                    getKeyValueFirestore(data, 'status') == 'P';
                                bool isDeclined =
                                    getKeyValueFirestore(data, 'status') == 'D';
                                String clubUID =
                                    getKeyValueFirestore(data, 'clubUID') ?? '';
                                return GestureDetector(
                                  onTap: () {
                                    // if (widget.isOrganiser
                                    //     ? (!isPending && !isDfeclined && isActive)
                                    //     : true) {
                                    if (!widget.isPendingRequest) {
                                      Get.to(EventManagement(
                                        isEditEvent: true,
                                        eventId: data.id,
                                        isOrganiser: widget.isOrganiser,
                                        clubUID: clubUID,
                                      ));
                                    }
                                    //  }
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.black),
                                        width: Get.width,
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Text(index.toString(),style: TextStyle(color: Colors.white),),
                                            if (!widget.isPendingRequest &&
                                                !widget.isOrganiser &&
                                                !isPending)
                                              eventCard(
                                                  index: index,
                                                  data: data,
                                                  isDeleteCheck: isDelete,
                                                  date: date),
                                            if (widget.isPendingRequest &&
                                                isPending)
                                              eventCard(
                                                  isDeleteCheck: isDelete,
                                                  index: index,
                                                  data: data,
                                                  date: date),
                                            if (widget.isOrganiser)
                                              eventCard(
                                                  isDeleteCheck: isDelete,
                                                  index: index,
                                                  data: data,
                                                  date: date),
                                            Column(children: [
                                              if (isPending &&
                                                  !widget.isOrganiser &&
                                                  widget.isPendingRequest)
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => EventAndPromotorDetail(data: data.data() as Map<String, dynamic>, dataId: data.id)));
                                                      },
                                                      child: Text(
                                                        'Click for details',
                                                        style: TextStyle(
                                                            decoration:
                                                            TextDecoration
                                                                .underline,
                                                            decorationColor:
                                                            Colors.orange,
                                                            fontSize: 40.sp,
                                                            color: Colors.white),
                                                      ),
                                                    ).paddingSymmetric(
                                                        horizontal: 30.w),
                                                    ElevatedButton(
                                                        style: ButtonStyle(
                                                            padding: WidgetStateProperty.resolveWith((states) => EdgeInsets.symmetric(horizontal: 20, vertical: 2)),
                                                            backgroundColor:
                                                            WidgetStateProperty
                                                                .resolveWith(
                                                                    (states) =>
                                                                Colors
                                                                    .green)),
                                                        onPressed: () {
                                                          FirebaseFirestore.instance
                                                              .collection('Events')
                                                              .doc(data.id)
                                                              .set(
                                                              {
                                                                'isActive':
                                                                true,
                                                                'status': 'A',
                                                              },
                                                              SetOptions(
                                                                  merge: true))
                                                              .whenComplete(() =>
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                  "Club")
                                                                  .doc(uid())
                                                                  .set(
                                                                  {
                                                                    "eventCover": data['cover']
                                                                        .isNotEmpty
                                                                        ? (data['cover']
                                                                    [0])
                                                                        : "",
                                                                    'eventStartTime':
                                                                    data[
                                                                    'startTime'],
                                                                    'eventEndTime':
                                                                    data[
                                                                    'endTime'],
                                                                  },
                                                                  SetOptions(
                                                                      merge:
                                                                      true)))
                                                              .whenComplete(() {
                                                            setState(() {});
                                                          });
                                                        },
                                                        child:
                                                        const Text('Accept')),
                                                    ElevatedButton(
                                                        style: ButtonStyle(
                                                            padding: WidgetStateProperty.resolveWith((states) => EdgeInsets.symmetric(horizontal: 20, vertical: 2)),
                                                            backgroundColor:
                                                            WidgetStateProperty
                                                                .resolveWith(
                                                                    (states) =>
                                                                Colors
                                                                    .red)),
                                                        onPressed: () {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                              'Events')
                                                              .doc(data.id)
                                                              .set(
                                                            {
                                                              'isActive': false,
                                                              'status': 'D',
                                                            },
                                                            SetOptions(
                                                                merge: true),
                                                          ).whenComplete(() {
                                                            setState(() {});
                                                          });
                                                        },
                                                        child: const Text(
                                                            'Reject'))
                                                        .paddingSymmetric(
                                                        horizontal: 50.w),
                                                  ],
                                                )
                                              else if (isDeclined)
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                                  children: [
                                                    const Text('Declined')
                                                        .paddingSymmetric(
                                                        vertical: 30.h,
                                                        horizontal: 30.w)
                                                  ],
                                                ),
                                              if (widget.isOrganiser)
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                                  children: [
                                                    if (isPending)
                                                      Text(
                                                        'Waiting for Approval',
                                                        style: GoogleFonts.ubuntu(
                                                          color: Colors.amber,
                                                        ),
                                                      ).paddingSymmetric(
                                                          vertical: 30.h,
                                                          horizontal: 30.w)
                                                    else if (isDeclined)
                                                      Text(
                                                        'Declined by club',
                                                        style: GoogleFonts.ubuntu(
                                                            color: Colors.red),
                                                      ).paddingSymmetric(
                                                          vertical: 30.h,
                                                          horizontal: 30.w)
                                                  ],
                                                ),
                                            ])
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ).paddingSymmetric(horizontal: 30.w, vertical: 5);
                              } catch (e) {
                                return Container();
                              }
                            });
                      }
                    })
              ],
            ),
          );
        },

      ),
    );
  }
}
