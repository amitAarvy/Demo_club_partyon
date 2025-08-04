import 'dart:convert';
import 'dart:io';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/purchase_plan/purchase_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/app_utils.dart';
import '../../widgets/plan_message.dart';
import '../transaction/tranaction_home.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeBar extends StatefulWidget {
  const HomeBar({Key? key}) : super(key: key);

  @override
  State<HomeBar> createState() => _HomeBarState();
}

class _HomeBarState extends State<HomeBar> {
  ValueNotifier<int> currentIndex = ValueNotifier(0);
  ValueNotifier<bool> barVisibility = ValueNotifier(false);
  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 250), () {
      barVisibility.value = true;
    });
    fetchPlan();
    pages=[
      ClubHome(),
      // PurchasePlan(isProfile: 'venue',),
      TransactionHome()
    ];
  }
  ValueNotifier<bool> isPlan = ValueNotifier(false);

  Future fetchPlan()async{
    print('yes it is');
    SharedPreferences pref = await SharedPreferences.getInstance();
    QuerySnapshot data = await   FirebaseFirestore.instance
        .collection("BookingPlan").where('id', isEqualTo: uid()).where('status',isEqualTo: 'S').get();
    print('check plan is ${data.docs}');
    print('check plan is ${uid()}');
    if(data.docs.isNotEmpty){
      print('check plan is ${data.docs[0]['planDetail']}');
      Map<String,dynamic> planData = data.docs[0]['planDetail'];
      pref.setString('planData',jsonEncode(planData) );
    }else{
      isPlan.value =true;
      pref.setString('planData',jsonEncode({}) );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: ValueListenableBuilder(
        valueListenable: isPlan,
        builder: (context, bool plan, child) {
          // if(plan){
          //   return Scaffold(
          //     appBar: appBar(context,
          //         title: "Home", showLogo: true, showBack: false),
          //     body: Container(
          //         height: 1.sh,
          //         width: 1.sw,
          //         color: Colors.black,
          //         child: Center(child: planMessage())),
          //   );
          // }
          return  Scaffold(
            body:
            ValueListenableBuilder(
                valueListenable: currentIndex,
                builder: (context, int index, _) {
                  print('int index is ${index}');
                  return pages[index];
                }),
            extendBody: true,
            bottomNavigationBar:
            ValueListenableBuilder(
                valueListenable: barVisibility,
                builder: (context, bool isVisible, _) {
                  return ValueListenableBuilder(
                      valueListenable: currentIndex,
                      builder: (context, int index, _) {
                        return Container(
                          margin: const EdgeInsets.all(10),
                          // padding: const EdgeInsets.all(10),
                          child:  AnimatedOpacity(
                            opacity: isVisible ? 1 : 0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutBack,
                            child: AnimatedScale(
                              scale: isVisible ? 1 : 0.95,
                              duration: const Duration(milliseconds: 500),
                              // curve: Curves.easeInOutExpo,
                              curve: Curves.easeInOutBack,
                              child: IgnorePointer(
                                ignoring: !isVisible,
                                child: AnimatedSlide(
                                  offset: isVisible ? const Offset(0, 0) : const Offset(0, 0.1),
                                  duration: const Duration(milliseconds: 500),
                                  // curve: Curves.easeInOutExpo,
                                  curve: Curves.easeInOutBack,
                                  child: SizedBox(
                                    // height: 180.h,
                                    width: 1.sw,
                                    child:  Container(
                                      // margin: EdgeInsets.symmetric(horizontal: 20.w).copyWith(bottom: 30.h),
                                      // height: 20.h,
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            // height: 00.h,
                                              decoration: BoxDecoration(
                                                  color: Colors.black45,
                                                  border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0))
                                              ),
                                              child:  Padding(
                                                padding: const EdgeInsets.only(top: 5),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          // border: index == 0 ? Border(top: BorderSide(color: Colors.grey, width: 2)) : Border()
                                                        ),
                                                        child: BottomBarIcon(
                                                          // imageIcon: Images.homeIcon,
                                                          icon: PhosphorIcons.house,
                                                          title: "Home",
                                                          // activeColor: K.primaryColor,
                                                          activeColor:index ==0?Colors.orangeAccent: Colors.white,
                                                          isSelected: true,
                                                          onTap: () {
                                                            currentIndex.value = 0;
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   child: Container(
                                                    //     decoration: BoxDecoration(
                                                    //       // border: index == 1 ? Border(top: BorderSide(color: Colors.white, width: 2)) : Border()
                                                    //     ),
                                                    //     child: BottomBarIcon(
                                                    //       icon: FontAwesomeIcons.solidNoteSticky,
                                                    //       // imageIcon: Images.storeIcon,
                                                    //       title: "Plan\'s",
                                                    //       // activeColor: K.primaryColor,
                                                    //       activeColor: index ==1?Colors.orangeAccent:Colors.white,
                                                    //       isSelected: true,
                                                    //       onTap: () {
                                                    //         currentIndex.value = 1;
                                                    //       },
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                    Expanded(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          // border: index == 1 ? Border(top: BorderSide(color: Colors.white, width: 2)) : Border()
                                                        ),
                                                        child: BottomBarIcon(
                                                          icon: FontAwesomeIcons.book,
                                                          // imageIcon: Images.storeIcon,
                                                          title: "Transaction",
                                                          // activeColor: K.primaryColor,
                                                          activeColor: index ==1?Colors.orangeAccent:Colors.white,
                                                          isSelected: true,
                                                          onTap: () {
                                                            currentIndex.value = 1;
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                          ),
                                          // const SizedBox(
                                          //   height: 5,
                                          // )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                }
            ),
          );
        },

      ),


      onWillPop: () async {
        final value = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Exit"),
                content: const Text("Are you sure you want to Exit?"),
                actions: [
                  TextButton(
                    onPressed: () async{
                      // SharedPreferences pref = await SharedPreferences.getInstance();
                      // pref.setString('audioCheck','');
                      Navigator.of(context).pop();
                      exit(0);
                    },
                    child: const Text(
                      "Yes",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text(
                      "No",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              );
            });
        if(value !=null){
          return Future.value(value);
        }else{
          return Future.value(false);
        }
      },
    );
  }
}

class BottomBarIcon extends StatelessWidget {
  final Color activeColor;
  final IconData? icon;
  final String? imageIcon;
  final String? title;
  final VoidCallback onTap;
  final bool isSelected;
  const BottomBarIcon(
      {Key? key,
        required this.activeColor,
        this.icon,
        required this.onTap,
        this.title,
        this.imageIcon,
        required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
      onPressed: () {
        onTap();
      },
      stayOnBottom: true,
      scaleFactor: 0.5,
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null
              ? Icon(
            icon,
            color:
            isSelected ? activeColor : Colors.black.withOpacity(0.7),
            size: isSelected ? 27 : 25,
          )
              : Image.asset(
            imageIcon!,
            color:
            isSelected ? activeColor : Colors.black.withOpacity(0.7),
            height: isSelected ? 27 : 25,
          ),
          const SizedBox(
            height: 1,
          ),
          Text(
            "$title",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: isSelected ? activeColor : Colors.black.withOpacity(0.7),
                fontSize: isSelected ? 13 : 12,fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
