// ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


class MenuCategoryView extends StatelessWidget {
  const MenuCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime timeNow = DateTime.now();
    DateTime today = DateTime(timeNow.year, timeNow.month, timeNow.day);
    return
      FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('Menucategory')
          .where('status', isEqualTo: 1)
          .where('clubUID', isEqualTo: uid())
          // .where('date', isGreaterThanOrEqualTo: today)
      // .where('city', isEqualTo: homeController.city)

          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error"),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: Get.height / 5,
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text("No category found!"),
          );
        }

        if (snapshot.data != null) {
          return Container(
            height: Get.height,
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final productData = snapshot.data!.docs[index];
                // ProductModel productModel = ProductModel(
                //   productId: productData['clubUID'],
                //   categoryId: productData['title'],
                //   productName: productData['title'],
                //   categoryName: productData['venueName'],
                //   salePrice: productData['startTime'].toDate(),
                //   fullPrice: productData['title'],
                //   productImages: productData['coverImages'],
                // );
                // CategoriesModel categoriesModel = CategoriesModel(
                //   categoryId: snapshot.data!.docs[index]['categoryId'],
                //   categoryImg: snapshot.data!.docs[index]['categoryImg'],
                //   categoryName: snapshot.data!.docs[index]['categoryName'],
                //   createdAt: snapshot.data!.docs[index]['createdAt'],
                //   updatedAt: snapshot.data!.docs[index]['updatedAt'],
                // );
                return Wrap(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 1.h),
                                spreadRadius: 5.h,
                                blurRadius: 20.h,
                                color: Colors.deepPurple,
                              )
                            ],
                            borderRadius: BorderRadius.circular(22),
                            color: Color(0x42C3C3C3),
                          ),
                          width: Get.width,
                          child: Column(children: [

                            Text(
                              productData['title'],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white),
                            ).paddingAll(5.0).marginOnly(left: 10.0,right: 10.0),

                          ])),
                    ),
                  ],
                );
              },
            ),
          );
        }

        return Container();
      },
    );
  }
}
