import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingUserList extends StatefulWidget {
  const BookingUserList({super.key});

  @override
  State<BookingUserList> createState() => _BookingUserListState();
}

class _BookingUserListState extends State<BookingUserList> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> tableUserList = [];
  List<Map<String, dynamic>> entryUserList = [];
  ValueNotifier<bool> isLoading = ValueNotifier(false);


  fetchBookingUserList()async{
    isLoading.value = true;
    var data =  await FirebaseFirestore.instance.collection('Bookings').get();
    List myBooking = data.docs.where((element) => element['clubUID'].toString() == uid()).toList();


    for (var user in myBooking) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user['userID'])
          .get();

      var data = user.data() as Map<String, dynamic>;
      if (userDoc.exists) {
        if(data['totalEntranceCount'].toString() != '0'){
          entryUserList.add(userDoc.data() as Map<String, dynamic>);
        }else{
          tableUserList.add(userDoc.data() as Map<String, dynamic>);
        }

      }
    }
    setState(() {});
    isLoading.value = false;
    print('check user list is ${entryUserList.length}');
    print('check user list is ${tableUserList.length}');
  }

  late TabController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 2, vsync: this);
    fetchBookingUserList();
  }
  
  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar:  Padding(
        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 10),
        child: GestureDetector(
          onTap: (){
            Fluttertoast.showToast(msg: 'Notification will be available after 45 events are completed.');
          },
          child: Container(
            height: 50,
            width: 0.9.sw,
            decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(11)
            ),
            child: const Center(child: Text('Send Notification',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),),
          ),
        ),
      ),
      appBar:  PreferredSize(
        preferredSize: Size.fromHeight(220.h),
        child: AppBar(
          automaticallyImplyLeading: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PartyOn",
                style: GoogleFonts.dancingScript(
                  color: Colors.red,
                  fontSize: 70.sp,
                ),
              ),
              // SizedBox(
              //   width: 400.w,
              // ),

            ],
          ),
          bottom: TabBar(
            controller: controller,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: "Floor Customers"),
              Tab(text: "Table Customers"),
            ],
          ),
          backgroundColor: Colors.black,
          shadowColor: Colors.grey,
        ),
      ),

      body:  ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context,bool loading, child) {
         if(loading){
           return Center(child: CircularProgressIndicator(color: Colors.orangeAccent,),);
         }
         return DefaultTabController(
           length:  2 ,
           child: TabBarView(
             controller: controller,
             children: [
               userData(entryUserList),
               userData1(tableUserList)
             ],
           ),
         );
        },

      ),
    );
  }
  Widget titleWidget(String title) => Expanded(
      child: SizedBox(
          child: Center(
              child: Text(title,
                  style: GoogleFonts.ubuntu(
                    color: Colors.orange,
                    fontSize: 50.sp,
                  )))));

  Widget userData(List data){
    List<Map<String, dynamic>> uniqueList = [];
    Set<String> seenUserIDs = {};

    for (var item in data) {
      String userId = item['uid'].toString();
      if (!seenUserIDs.contains(userId)) {
        seenUserIDs.add(userId);
        uniqueList.add(item);
      }
    }
    if(uniqueList.isEmpty){
      return Center(child: Text('No user available',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Colors.white),),);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            width: Get.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                titleWidget('S.no'),
                titleWidget('Name'),
                titleWidget('User Id'),
                titleWidget('City')
              ],
            ).paddingAll(20.h),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: uniqueList.length,
            itemBuilder: (BuildContext context, int index) {
              var user =
              uniqueList[index];
      
              return GestureDetector(
                onTap: () {
      
                },
                child: Container(
                  height: 300.h,
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: Center(
                            child: Text(
                              '${index+1}',
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
                              "${user["userName"]}",
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
                              "${user["uid"]}",
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
                            child:  Text(
                              user['city'],
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).paddingAll(20.h),
              );
            },
          )
        ],
      ),
    );
  }
  Widget userData1(List data){
    List<Map<String, dynamic>> uniqueList = [];
    Set<String> seenUserIDs = {};

    for (var item in data) {
      String userId = item['uid'].toString();
      if (!seenUserIDs.contains(userId)) {
        seenUserIDs.add(userId);
        uniqueList.add(item);
      }
    }
    if(uniqueList.isEmpty){
      return Center(child: Text('No user available',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Colors.white),),);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            width: Get.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                titleWidget('S.no'),
                titleWidget('Name'),
                titleWidget('User Id'),
                titleWidget('City')
              ],
            ).paddingAll(20.h),
          ),

          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: uniqueList.length,
            itemBuilder: (BuildContext context, int index) {
              var user =
              uniqueList[index];

              return GestureDetector(
                onTap: () {

                },
                child: Container(
                  height: 300.h,
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: Center(
                            child: Text(
                              '${index+1}',
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
                              "${user["userName"]}",
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
                              "${user["uid"]}",
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
                            child:  Text(
                              user['city'],
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).paddingAll(20.h),
              );
            },
          )
        ],
      ),
    );
  }
  
  
}
