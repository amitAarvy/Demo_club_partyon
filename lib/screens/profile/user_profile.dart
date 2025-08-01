import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../utils/app_utils.dart';


class PromoterInfProfile extends StatefulWidget {
  final bool pr;
  final String? id;
  final data ;
  const PromoterInfProfile({super.key, required this.pr,  this.id, this.data});

  @override
  State<PromoterInfProfile> createState() => _PromoterInfProfileState();
}

class _PromoterInfProfileState extends State<PromoterInfProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar(context, title: "Profile", ),
      body:widget.pr?
      promoterDetail():
      infDetail()
    );
  }

  Widget infDetail(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 150,
              width: 150,
              child: widget.data['profile_image'] ==null?Image.asset('assets/appLogo.png'):Image.network(widget.data['profile_image']??''),
            ),
          ),
          SizedBox(height: 10,),
          userContent(title: 'Name:',trailing: widget.data['username']??''),
          userContent(title: 'Company Name:',trailing: widget.data['companyMame']??''),
          userContent(title: 'Email:',trailing: widget.data['emailPhone']??''),
          SizedBox(height: 30,),
          Text('Address',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
          Text('${widget.data['address']??''} ${widget.data['area']??''} ${widget.data['city']??''}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
          Text('${widget.data['state']??''}, ${widget.data['pinCode']??''}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
        ],
      ),
    );
  }

  Widget promoterDetail(){
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection(widget.pr?"Organiser":'Influencer')//tmxdVErnCgRX2MWOQHooVUK0UBS2
            .where(widget.pr ? 'organiserID' : 'clubUID',
            isEqualTo: widget.id)
            .get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (kDebugMode) {
            print(uid());
            print('check is ${snapshot.data?.docs.length}');
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
            print('check data is ${snapshot.data!.docs}');
            var data = snapshot.data!.docs[0];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 150,
                      width: 150,
                      child: Image.network(data['profile_image'].toString()),
                    ),
                  ),
                  SizedBox(height: 10,),
                  userContent(title: 'Name:',trailing: widget.pr?data['name']:''),
                  userContent(title: 'Company Name:',trailing: widget.pr?data['companyMame']:''),
                  userContent(title: 'Email:',trailing: widget.pr?data['emailPhone']:''),
                  SizedBox(height: 30,),
                  Text('Address',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                  Text('${widget.pr?data['address']:''}, ${widget.pr?data['area']:''},${widget.pr?data['city']:''}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                  Text('${widget.pr?data['state']:''}, ${widget.pr?data['pinCode']:''}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),

                ],
              ),
            );
          }
        });
  }


  Widget userContent({String? title,String? trailing}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title!,style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
        Text(trailing!,style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),)
      ],
    );
  }
}
