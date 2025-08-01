import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/organiser/event_management/organiser_event_controller.dart';
import 'package:club/screens/organiser/event_management/search_city.dart';
import 'package:club/search/search_artist.dart';
import 'package:club/search/search_club_details.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class OrganiserEventManagement extends StatefulWidget {
  const OrganiserEventManagement({Key? key}) : super(key: key);

  @override
  State<OrganiserEventManagement> createState() =>
      _OrganiserEventManagementState();
}

class _OrganiserEventManagementState extends State<OrganiserEventManagement> {
  final organiserEventController = Get.put(OrganiserEventController());
  final TextEditingController _searchCity = TextEditingController();
  List<QueryDocumentSnapshot> clubUIDList = [];
  List<QueryDocumentSnapshot> clubList = [];
  bool loading = true;

  Future<void> getClubUIDList() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Club').where("businessCategory", isEqualTo: 1).get();
    clubList = querySnapshot.docs;
    // for (var club in querySnapshot.docs) {
    //   clubList.add(club);
    // }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    print('chekc it is event mangemnet');
    // TODO: implement initState
    getClubUIDList();
    super.initState();
  }

  Widget clubCard(DocumentSnapshot documentSnapshot) => InkWell(
        onTap: () {
          Get.to(SearchClubDetails(
              documentSnapshot.id, documentSnapshot.get('clubName')));
        },
        child: Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.black,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(20)),
              width: Get.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 1,
                      child: ClipRRect(
                        child: CachedNetworkImage(
                          imageUrl: documentSnapshot.get('coverImage') ?? '',
                          placeholder: (_, __) => const SizedBox(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                          ),
                        ).paddingSymmetric(horizontal: 40.w),
                      )),
                  Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            documentSnapshot
                                    .get('clubName')
                                    .toString()
                                    .capitalizeFirstOfEach,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            '${documentSnapshot.get('address')}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            '${documentSnapshot.get('city')}, ${documentSnapshot.get('state')}',
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ))
                ],
              )).paddingSymmetric(vertical: 50.h),
        ).paddingSymmetric(vertical: 25.h),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: 'Event Management'),
      body: Obx(() => SingleChildScrollView(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                AnimatedContainer(
                  height: organiserEventController.showCity ? Get.height : 0,
                  width: organiserEventController.showCity ? Get.width : 0,
                  curve: Curves.fastLinearToSlowEaseIn,
                  duration: const Duration(milliseconds: 500),
                  child: SearchCity(
                    searchCity: _searchCity,
                  ),
                ),
                loading
                    ? SizedBox(
                        width: Get.width,
                        height: Get.height,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        ),
                      )
                    : AnimatedContainer(
                        height:
                            !organiserEventController.showCity ? Get.height : 0,
                        curve: Curves.decelerate,
                        duration: const Duration(milliseconds: 500),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.resolveWith(
                                                  (states) => Colors.orange)),
                                      onPressed: () => organiserEventController
                                          .updateShowCity(true),
                                      child: Text(organiserEventController.cityName.isEmpty ? 'Select city' : organiserEventController.cityName))
                                  .paddingSymmetric(vertical: 25.h),
                              ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: organiserEventController.cityName.toString().isNotEmpty
                                      ? clubList.where((element) =>
                                              element.get('city') == organiserEventController.cityName.toString()
                                                  ? true
                                                  : false).length
                                      : clubList.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    try {
                                      DocumentSnapshot documentSnapshot =
                                          organiserEventController.cityName.toString().isNotEmpty
                                              ? clubList
                                                  .where((element) => element
                                                              .get('city') ==
                                                          organiserEventController
                                                              .cityName
                                                              .toString()
                                                      ? true
                                                      : false)
                                                  .toList()[index]
                                              : clubList[index];
                                      if(organiserEventController.cityName.toString().isEmpty){
                                        return const Offstage();
                                      }
                                      return clubCard(documentSnapshot);
                                    } catch (e) {
                                      if (kDebugMode) {
                                        print(e);
                                      }
                                    }
                                    return null;
                                  }),
                            ],
                          ).paddingSymmetric(
                            horizontal: 40.h,
                          ),
                        ),
                      ),
              ],
            ),
          )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => Get.to(const SearchArtistView()),
        child: const Icon(FontAwesomeIcons.magnifyingGlass),
      ),
    );
  }
}
