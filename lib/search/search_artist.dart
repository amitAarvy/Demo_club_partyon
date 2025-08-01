import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_const.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SearchArtistView extends StatefulWidget {
  const SearchArtistView({super.key});

  @override
  State<SearchArtistView> createState() => _SearchArtistViewState();
}

class _SearchArtistViewState extends State<SearchArtistView> {
  final TextEditingController _controller = TextEditingController();
  String query = "";
  String _radioVal = "name";
  int _radioSelected = 1;

  Widget radioWidget(int value, String titleName) => Row(
        children: [
          Radio(
            value: value,
            groupValue: _radioSelected,
            fillColor:
                WidgetStateProperty.resolveWith((states) => Colors.orange),
            onChanged: (value) {
              setState(() {
                _radioSelected = int.parse(value.toString());
                _radioVal = titleName;
              });
            },
          ),
          Text(
            titleName.capitalizeFirstOfEach,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      );

  Widget infoRow(String title, String info) => RichText(
        text: TextSpan(children: [
          TextSpan(
              text: '$title: ',
              style:
                  const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          TextSpan(text: info, style: const TextStyle(color: Colors.white))
        ]),
      );

  Widget artistCard(DocumentSnapshot documentSnapshot) => InkWell(
        onTap: () {
          // final clubUID = documentSnapshot.reference.parent.parent?.path
          //     .replaceFirst('Club/', '');
          // Get.to(SearchClubDetails(clubUID,
          //     documentSnapshot.id, documentSnapshot.get('clubName')));
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
                        borderRadius: BorderRadius.circular(10),
                        child: documentSnapshot
                                .get('photoUrl')
                                .toString()
                                .isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl:
                                    documentSnapshot.get('photoUrl') ?? '',
                                placeholder: (_, __) => const SizedBox(
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                                errorWidget: (_, __, ___) => const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                ),
                              ).paddingSymmetric(horizontal: 40.w)
                            : Image.asset("lib/assets/profile/profile.jpg"),
                      )),
                  Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          infoRow('Artist Id',
                              '${documentSnapshot.get('artistId')}'),
                          infoRow('Name', '${documentSnapshot.get('name')}'),
                          infoRow('Address',
                              '${documentSnapshot.get('city')}, ${documentSnapshot.get('state')}'),
                          infoRow('Min Budget',
                              '₹${documentSnapshot.get('min_budget')}'),
                          infoRow('Max Budget',
                              '₹${documentSnapshot.get('max_budget')}'),
                        ],
                      ))
                ],
              )).paddingSymmetric(vertical: 50.h),
        ).paddingSymmetric(vertical: 25.h),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: 'Search Artist'),
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white))),
            ).paddingSymmetric(vertical: AppConst.defaultVerticalPadding),
            Text(
              "Search by",
              style: TextStyle(
                  fontSize: AppConst.defaultFont, color: Colors.white),
            ).paddingSymmetric(vertical: AppConst.defaultVerticalPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                radioWidget(1, 'name'),
                radioWidget(2, 'city'),
                radioWidget(3, 'state'),
              ],
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => Colors.black)),
                onPressed: () {
                  setState(() {
                    query = _controller.text;
                  });
                },
                child: const Text("Search")),
            FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("Artist")
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  try {
                    if (_controller.text.isEmpty) {
                      return Text(
                        "Search Artist",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: AppConst.headingFont),
                      ).paddingSymmetric(
                          vertical: AppConst.defaultHorizontalPadding);
                    } else if (snapshot.hasError) {
                      return Column(children: [
                        SizedBox(
                          height: 200.h,
                        ),
                        Center(
                          child: Text(
                            "Something went wrong.",
                            style:
                                TextStyle(color: Colors.white, fontSize: 60.sp),
                          ),
                        )
                      ]);
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Column(children: [
                        SizedBox(
                          height: 200.h,
                        ),
                        Center(
                          child: Text(
                            "Loading...",
                            style:
                                TextStyle(color: Colors.white, fontSize: 60.sp),
                          ),
                        )
                      ]);
                    } else if (snapshot.data?.docs.isEmpty==true) {
                      return Column(children: [
                        SizedBox(
                          height: 200.h,
                        ),
                        Center(
                          child: Text(
                            "No Artist found",
                            style:
                                TextStyle(color: Colors.white, fontSize: 60.sp),
                          ),
                        )
                      ]);
                    }
                    if (snapshot.data!.docs
                        .where((QueryDocumentSnapshot<Object?> element) =>
                            element[_radioVal]
                                .toString()
                                .toLowerCase()
                                .contains(_controller.text.toLowerCase()))
                        .isEmpty) {
                      return Text(
                        "No Artist found",
                        style: TextStyle(color: Colors.white, fontSize: 60.sp),
                      );
                    } else {
                      return Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  ...snapshot.data!.docs
                                      .where((QueryDocumentSnapshot<Object?>
                                              element) =>
                                          element[_radioVal]
                                              .toString()
                                              .toLowerCase()
                                              .contains(_controller.text
                                                  .toLowerCase()))
                                      .map((QueryDocumentSnapshot<Object?>
                                          data) {
                                    return Container(child: artistCard(data));
                                  })
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    print(e);
                    return const Center(child: Text("Something went wrong",style: TextStyle(color: Colors.white),));
                  }
                })
          ],
        ).paddingSymmetric(horizontal: AppConst.defaultHorizontalPadding),
      ),
    );
  }
}
