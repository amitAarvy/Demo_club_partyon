import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/create_event_promotion.dart';
import 'package:club/utils/app_const.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/screens/event_management/model/entrance_data_model.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import '../../widgets/plan_message.dart';
import 'controller/event_management_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EventManagement extends StatefulWidget {
  final String? eventId;
  final bool isOrganiser;
  final bool isEditEvent;
  final String clubUID;
  final String venueName;

  const EventManagement({
    this.eventId = '',
    this.isEditEvent = false,
    this.isOrganiser = false,
    this.clubUID = '',
    this.venueName = '',
    Key? key,
  }) : super(key: key);

  @override
  State<EventManagement> createState() => _EventManagementState();
}

class _EventManagementState extends State<EventManagement> {
  bool isNineSixteen = false;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _briefEvent = TextEditingController();
  final TextEditingController _artistName = TextEditingController();

  String bandType = '';

  final homeController = Get.put(HomeController());
  final eventController = Get.put(EventController());
  List<TextEditingController> tableName =
      List.generate(30, (i) => TextEditingController());
  List<TextEditingController> seatsAvailable =
      List.generate(30, (i) => TextEditingController());
  List<TextEditingController> tableAvailable =
      List.generate(30, (i) => TextEditingController());
  List<TextEditingController> tablePrice =
      List.generate(30, (i) => TextEditingController());
  List<TextEditingController> tableInclusion =
      List.generate(30, (i) => TextEditingController(text: ""));

//Entrance
  List<TextEditingController> entranceName =
      List.generate(30, (i) => TextEditingController());
  List<TextEditingController> totalEntry =
      List.generate(30, (i) => TextEditingController());

  List<List<TextEditingController>> entryCategoryName = List.generate(
      30, (i) => List.generate(5, (index) => TextEditingController()));
  List<List<TextEditingController>> entryCategoryCount = List.generate(
      30, (i) => List.generate(5, (index) => TextEditingController()));
  List<List<TextEditingController>> entryCategoryPrice = List.generate(
      30, (i) => List.generate(5, (index) => TextEditingController()));

  List<TextEditingController> entryNotesList =
      List.generate(30, (i) => TextEditingController(text: ""));
  final tableTypesController = Get.put(TableTypesController());
  final entranceTypesController = Get.put(EntranceTypesController());
  final entranceCategoryController = Get.put(EntranceCategoryController());
  final _formKey = GlobalKey<FormState>();
  List entranceList = [];
  List<File> uploadCover = [];
  List<File> uploadOffer = [];
  StreamSubscription? subscription;
  List coverImage = [];
  List offerImage = [];
  String dropGenre = "Select Genre";
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);

  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 59);
  int durationInHours = 0;

  bool tableShow = false, entranceShow = false, showDate = false;

  _getFromGallery({bool isOffer = false}) async {
    await cropImageMultiple(!isOffer ? isNineSixteen : false,
            promotionType: PromotionType.story)
        .then((value) {
      if (value.isNotEmpty) {
        if (isOffer) {
          offerImage = [];
        } else {
          coverImage = [];
        }
        for (CroppedFile image in value) {
          setState(() {
            if (isOffer) {
              uploadOffer.add(File((image.path).toString()));
            } else {
              uploadCover.add(File((image.path).toString()));
            }
          });
        }
      }
    });
  }



  void getDefaultTableData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Club")
          .doc(uid())
          .collection("DefaultTable")
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          tableTypesController.updateTypes(value.docs.length);
          for (int i = 0; i < value.docs.length; i++) {
            tableName[i].text = value.docs[i]["tableName"];
            tableAvailable[i].text = value.docs[i]["tableAvail"];
            tablePrice[i].text = value.docs[i]["tablePrice"];
            seatsAvailable[i].text = value.docs[i]["seatsAvail"];
          }
        }
      });
    } catch (e) {
      tableTypesController.updateTypes(1);
    }
  }

  void fetchEditTableData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Events")
          .doc(widget.eventId)
          .collection("Tables")
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          tableTypesController.updateTypes(value.docs.length);
          for (int i = 0; i < value.docs.length; i++) {
            tableTypesController.updateTypes(value.docs.length);
            tableName[i].text = value.docs[i]["tableName"].toString();
            tableAvailable[i].text = value.docs[i]["tableLeft"].toString();
            tablePrice[i].text = value.docs[i]["tablePrice"].toString();
            seatsAvailable[i].text = value.docs[i]["seatsLeft"].toString();
          }
        }
      });
    } catch (e) {
      tableTypesController.updateTypes(1);
    }
  }

  // void fetchEntranceTableData() async {
  //   print('yes it is 1');
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection("Events")
  //         .doc(widget.eventId)
  //         .collection("entranceList")
  //         .get()
  //         .then((value) {
  //       if (value.docs.isNotEmpty) {
  //         print('yes it is ');
  //         // tableTypesController.updateTypes(value.docs.length);
  //         for (int i = 0; i < value.docs.length; i++) {
  //           for(int j =0; j < value.docs[i]['subCategory'].length; j++){
  //             entranceCategoryController.entranceCategoryTypes[i].value = int.parse(value.docs[i]['subCategory'][j][''].toString());
  //           }
  //
  //           // tableTypesController.updateTypes(value.docs.length);
  //           // tableName[i].text = value.docs[i]["tableName"].toString();
  //           // tableAvailable[i].text = value.docs[i]["tableLeft"].toString();
  //           // tablePrice[i].text = value.docs[i]["tablePrice"].toString();
  //           // seatsAvailable[i].text = value.docs[i]["seatsLeft"].toString();
  //         }
  //       }
  //     });
  //   } catch (e) {
  //     tableTypesController.updateTypes(1);
  //   }
  // }

//get text field values from server in edit Event
  List entranceDefaultList = ['Couple','Female Stag','Male Stag'];
  Future<void> getEntranceFieldValues({
    isDefault = false,}) async {
    try {
      print('check is default value 1 ${isDefault}');
      if (isDefault) {
        entranceTypesController.updateTypes(entranceDefaultList.length);

        for (int i = 0; i < entranceDefaultList.length; i++) {
          if (i >= entranceName.length) continue; // Avoid index error
          entranceName[i].text = entranceDefaultList[i];

          for (int j = 0; j < 3; j++) {
            if (j >= entryCategoryName[i].length ||
                j >= entryCategoryCount[i].length ||
                j >= entryCategoryPrice[i].length) continue;

            entryCategoryName[i][j].text = '';
            entryCategoryCount[i][j].text = '';
            entryCategoryPrice[i][j].text = '';
          }
        }
        // setState(() {
        // });
        // entranceList = await fetchEntranceDataDefault(widget.eventId.toString(),
        //     isDefault: isDefault);

      } else {
        print('check is default value2');
        await FirebaseDatabase.instance
            .ref()
            .child('Events')
            .child(widget.eventId!)
            .child('entranceList')
            .once()
            .then((event) async {
          if (event.snapshot.exists) {
            entranceList = event.snapshot.value as List;
          }

        }).catchError((e){
          print('print error this ${e}');
        });
        print('check entrance list is');
        print('check entrance list is ${entranceList.length}');
        entranceTypesController.updateTypes(entranceList.length);
        for (int i = 0; i < entranceList.length; i++) {
          final entranceData =
          EntranceDataModel.fromJson(Map.from(entranceList[i]));
          entranceCategoryController.updateTypes(
              i, entranceData.subCategory.length);
          entranceName[i].text = entranceData.categoryName;
          for (int j = 0; j < entranceData.subCategory.length; j++) {
            entryCategoryName[i][j].text =
                entranceData.subCategory[j].entryCategoryName.toString();
            entryCategoryCount[i][j].text =
                entranceData.subCategory[j].entryCategoryCount.toString();
            entryCategoryPrice[i][j].text =
                entranceData.subCategory[j].entryCategoryPrice.toString();
          }
        }
      }

      setState(() {});

    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }



  fetchTotalEntryOrTable()async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection("Events")
        .where(widget.isOrganiser ? 'organiserID' : 'clubUID',
        isEqualTo: uid())
        .get();
    print('check to entry is ${data.docs.length}');
    String planData = pref.getString('planData') ?? '';
    print('check to entry is ${planData}');
    if (planData == '') {
      checkEventCreate.value = true;
      // checkEventCreate.value = false;
    } else {
      Map<String, dynamic> jsonConvert = jsonDecode(planData);
      List PromoterListPlan = data.docs
          .where((e) {
        var data = e.data() as Map<String,
            dynamic>?; // Safely cast to Map<String, dynamic>
        return data != null && data.containsKey('planId') &&
            jsonConvert['planId'].toString() == data['planId'].toString();
      }).toList();
      if (jsonConvert.isEmpty) {
        checkEventCreate.value = true;
      }
    else {
    checkEventCreate.value = int.parse(jsonConvert['entryManagement']['noOfEntry'].toString()) <= data.docs.length?
    true
    :
    false;
  }
    }

  }
  ValueNotifier<bool> checkEventCreate = ValueNotifier(false);

  void fetchEditEventsData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Events")
          .doc(widget.eventId)
          .get()
          .then((doc) async {
        if (doc.exists) {
          _title.text = getKeyValueFirestore(doc, 'title') ?? '';
          _briefEvent.text = getKeyValueFirestore(doc, 'briefEvent') ?? '';
          _artistName.text = getKeyValueFirestore(doc, 'artistName') ?? '';
          bandType = getKeyValueFirestore(doc, 'bandType') ?? '';

          dropGenre = getKeyValueFirestore(doc, 'genre') ?? '';
          coverImage = getKeyValueFirestore(doc, 'coverImages') ?? [];
          offerImage = getKeyValueFirestore(doc, 'offerImages') ?? [];
          List entranceLists = getKeyValueFirestore(doc, 'entranceList') ?? [];
          print('entrance list is check ${entranceLists}');
          entranceTypesController.updateTypes(entranceLists.length);
          for (int i = 0; i < entranceLists.length; i++) {
            entranceName[i].text = entranceLists[i]['categoryName'].toString();
            for (int j = 0;
                j < (entranceLists[i]['subCategory'] as List).length;
                j++) {
              entryCategoryCount[i][j].text = entranceLists[i]['subCategory'][j]
                          ['entryCategoryCountLeft']
                      ?.toString()??
                  "0";
              entryCategoryPrice[i][j].text = entranceLists[i]['subCategory'][j]
                          ['entryCategoryPrice']
                      ?.toString() ??
                  "0";
              entryCategoryName[i][j].text = entranceLists[i]['subCategory'][j]
                          ['entryCategoryName']
                      ?.toString() ??
                  "";
            }
          }

          try {
            DateTime date = getKeyValueFirestore(doc, 'date').toDate();
            DateTime startTimeHour =
                getKeyValueFirestore(doc, 'startTime').toDate() ??
                    DateTime.now();

            startTime = TimeOfDay(
                hour: startTimeHour.hour, minute: startTimeHour.minute);
            durationInHours = getKeyValueFirestore(doc, 'duration') ?? 0;
            endTime = TimeOfDay(
                hour: startTimeHour.hour + durationInHours,
                minute: startTimeHour.minute);
            selectedDate = DateTime(date.year, date.month, date.day);
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }

          setState(() {});
        }
      });
      await getEntranceFieldValues();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  bool checkTableNotEmpty(List<TextEditingController> list) {
    bool table = false;
    if (tableTypesController.tableTypes.value > 0) {
      for (int i = 0; i < tableTypesController.tableTypes.value; i++) {
        if (list[i].text.isNotEmpty) {
          table = true;
        } else {
          table = false;
        }
      }
    } else {
      table = true;
    }
    return table;
  }

  bool checkEntranceNotEmpty(List<TextEditingController> categoryList,
      List<List<TextEditingController>> subCategoryList) {
    int count = 0;
    for (int i = 0; i < entranceTypesController.entranceTypes.value; i++) {
      if (categoryList[i].text.isEmpty) {
        count++;
        break;
      }
      for (int j = 0;
          j < entranceCategoryController.entranceCategoryTypes[i].value;
          j++) {
        if (subCategoryList[i][j].text.isEmpty) {
          count++;
          break;
        }
      }
    }
    return count == 0;
  }

  Future<void> saveEntranceListRTDB(
      bool isEditEvent, String eventID, List entranceList) async {
    try {
      final rtdb = FirebaseDatabase.instance.ref();
      final entranceListRef =
          rtdb.child('Events').child(eventID).child('entranceList');
      if (kDebugMode) {
        print(eventID);
      }
      if (isEditEvent) {
        for (int i = 0; i < entranceTypesController.entranceTypes.value; i++) {
          final entranceNameData = entranceName[i].text;
          if (entranceNameData.isNotEmpty) {
            entranceListRef
                .child('$i')
                .update({'categoryName': entranceNameData});
            for (int j = 0;
                j < entranceCategoryController.entranceCategoryTypes[i].value;
                j++) {
              final entryCategoryNameData = (entryCategoryName[i][j].text);
              final entryCategoryCountData = (entryCategoryCount[i][j].text);
              if (kDebugMode) {
                print(entryCategoryNameData);
              }

              final entryCategoryPriceData = (entryCategoryPrice[i][j].text);
              if (entryCategoryNameData.isNotEmpty &&
                  entryCategoryCountData.isNotEmpty &&
                  entryCategoryPriceData.isNotEmpty) {
                int entryCategoryCountLeft = 0;
                await entranceListRef
                    .child('$i/subCategory/$j/entryCategoryCountLeft')
                    .once()
                    .then((event) {
                  if (event.snapshot.exists) {
                    entryCategoryCountLeft = int.parse(
                        (event.snapshot.value ?? entryCategoryCountData)
                            .toString());
                  }
                }).onError((error, stackTrace) {
                  entryCategoryCountLeft =
                      int.parse(entryCategoryCountData.toString());
                });
                entranceListRef.child('$i/subCategory/$j').update({
                  'entryCategoryName': entryCategoryNameData,
                  'entryCategoryCount':
                      int.parse(entryCategoryCountData.toString()),
                  'entryCategoryCountLeft':
                      int.parse(entryCategoryCountLeft.toString()),
                  'entryCategoryPrice':
                      int.parse(entryCategoryPriceData.toString())
                });
              } else {
                entranceListRef.child('$i/subCategory/$j').remove();
              }
            }
          } else {
            entranceListRef.child('$i').remove();
          }
        }
      } else {
        await entranceListRef.set(entranceList);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void onTapSoldOut(int index) {
    Get.defaultDialog(
        title: 'Are you sure?',
        content: Column(
          children: [
            Text(
              'This action cannot be undone.',
              style: GoogleFonts.ubuntu(color: Colors.grey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customisedButton('Yes', buttonColor: Colors.green, onTap: () {
                  final ref = FirebaseDatabase.instance.ref(
                      'Events/${widget.eventId}/entranceList/$index/subCategory');
                  ref.once().then((value) {
                    final list = value.snapshot.value as List;
                    for (int i = 0; i < list.length; i++) {
                      ref.child('$i').update({'entryCategoryCountLeft': 0});
                    }
                  }).whenComplete(() {
                    Get.back();
                    getEntranceFieldValues();
                  });
                }).paddingSymmetric(horizontal: 50.w),
                customisedButton('No',
                    onTap: () => Get.back(), buttonColor: Colors.red)
              ],
            )
          ],
        ));
  }

  @override
  void initState() {
    if (kDebugMode) {
      print('event id is data');
      print(widget.eventId);
    }
    if (widget.isEditEvent) {
      fetchEditEventsData();
      fetchEditTableData();
      // fetchEntranceTableData();
    } else {
      getEntranceFieldValues(isDefault: true);
      getDefaultTableData();
      fetchTotalEntryOrTable();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (subscription != null) {
      subscription?.cancel();
    }
    super.dispose();
  }

  Widget imageCoverWidget(List coverImages, List uploadImages,
      {bool isOffer = false, bool isNineSixteenValue = false}) {
    double carouselHeight =
        isNineSixteenValue && !isOffer ? (Get.width - 100.w) * 16 / 9 : 600.w;
    return Column(
      children: [
        Stack(
          children: [
            Container(
                    height: carouselHeight,
                    width: Get.width - 100.w,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: coverImages.isNotEmpty && uploadImages.isEmpty
                        ? eventCarousel(coverImages,
                            isEdit: true, height: carouselHeight)
                        : uploadImages.isEmpty
                            ? Center(
                                child: Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 300.h,
                              ))
                            : eventCarousel(uploadImages,
                                height: carouselHeight))
                .marginAll(20),
            Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 110.h,
                  width: 110.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: Center(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.orange,
                      ),
                      onPressed: () => setState(() {
                        if (isOffer) {
                          offerImage = [];
                          uploadOffer = [];
                        } else {
                          uploadCover = [];
                          coverImage = [];
                        }
                      }),
                    ),
                  ),
                )).marginOnly(top: 75.h, right: 75.w)
          ],
        ),
// if (!isOffer)
//   Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Text(
//         'Switch to 9/16',
//         style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 50.sp),
//       ),
//       Switch(
//           activeColor: Colors.orange,
//           value: isNineSixteen,
//           onChanged: (value) {
//             setState(() {
//               isNineSixteen = value;
//             });
//           })
//     ],
//   ),
        ElevatedButton(
          onPressed: () async {
            _getFromGallery(isOffer: isOffer);
          },
          style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.resolveWith((states) => Colors.red)),
          child: Text(!isOffer ? "Upload Cover" : 'Upload Offers'),
        ),
      ],
    );
  }

  Widget eventPreview() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          eventCarousel(isEdit: widget.isEditEvent,widget.isEditEvent?coverImage:uploadCover),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                    "${startTime.hourOfPeriod.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.period.name} Onwards",
                    style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 5),
                Text(DateFormat.yMMMd().format(selectedDate),
                    style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: const BorderSide(color: Colors.black))),
// backgroundColor: WidgetStateProperty.resolveWith(
//         (states) => Colors.red),
                        ),
                        child: Text(
                            widget.isEditEvent
                                ? "Cancel Update"
                                : "Cancel Event",
                            style: const TextStyle(color: Colors.black)),
                      ),
                    ),
                    SizedBox(
                      width: 50.w,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          print('yes it is');
                          // List entranceList = [];
                          final entranceLength = entranceTypesController.entranceTypes.value;

                          for (int i = 0; i < entranceLength; i++) {
                            Map<String, dynamic> dataMap = {};
                            dataMap['categoryName'] = entranceName[i].text.toUpperCase();
                            dataMap['subCategory'] = []; // Initialize properly

                            final entranceCategoryLength = entranceCategoryController.entranceCategoryTypes[i].value;

                            for (int j = 0; j < entranceCategoryLength; j++) {
                              Map<String, dynamic> subCategoryMap = {};
                              subCategoryMap['entryCategoryName'] = entryCategoryName[i][j].text.isNotEmpty
                                  ? entryCategoryName[i][j].text.toUpperCase()
                                  : 'Normal';

                              subCategoryMap['entryCategoryCount'] = int.parse(entryCategoryCount[i][j].text);
                              subCategoryMap['entryCategoryCountLeft'] = int.parse(entryCategoryCount[i][j].text);
                              subCategoryMap['entryCategoryPrice'] = int.parse(entryCategoryPrice[i][j].text);
                              (dataMap['subCategory'] as List).add(subCategoryMap);
                            }
                            print('Check subcategory: ${jsonEncode(dataMap['subCategory'])}');
                            print('Check subcategory: ${dataMap}');
                            entranceList =[];
                            print('Check entrance list data: ${entranceList}');
                            (entranceList as List).add(dataMap);
                          }
                      // entranceList.add(entranceList);
                            // entranceList =entry;
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return saveEventSheet();
                            },
                          );
                        },
                        style: ButtonStyle(
                            shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side:
                                        const BorderSide(color: Colors.black))),
                            backgroundColor: WidgetStateProperty.resolveWith(
                                (states) => Colors.black)),
                        child: Text(
                            widget.isEditEvent ? "Update Event" : "Save Event",
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ).marginSymmetric(vertical: 20.h),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(_title.text,
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Text(_briefEvent.text,
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 15),
                      Text(
                          "Date: ${DateFormat.yMMMMEEEEd().format(selectedDate)}",
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 15),
                      Text(
                          "Time: ${startTime.hourOfPeriod.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.period.name}",
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 15),
                      Text("Duration: $durationInHours hours",
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 15),
                      Text("Artist: ${_artistName.text}",
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 15),
                      Text("Genre: ${dropGenre}",
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 15),
                      Text("Band Type: ${bandType}",
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Text("Promotional Data",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 15),
                      const Text("Suggestions", style: TextStyle(fontSize: 17)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey, width: 0.5)),
                        child: Wrap(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5)),
                              child: const Text("Tags"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text("Captions", style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey, width: 0.5)),
                        child: Wrap(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5)),
                              child: const Text("Tags"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text("Post", style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey, width: 0.5)),
                        child: Wrap(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5)),
                              child: const Text("Tags"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text("Captions for reels",
                          style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey, width: 0.5)),
                        child: Wrap(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5)),
                              child: const Text("Tags"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text("Suggested Hashtags",
                          style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey, width: 0.5)),
                        child: Wrap(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5)),
                              child: const Text("Tags"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget saveEventSheet() {
    return WillPopScope(
      onWillPop: ()async {
        entranceList =[];
        Navigator.pop(context);
        return false;
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            eventCarousel(isEdit: widget.isEditEvent,widget.isEditEvent?coverImage:uploadCover),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_title.text,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600)),
                  Text(DateFormat.yMMMd().format(selectedDate),
                      style: const TextStyle(fontSize: 17)),
                  Text(
                      "${startTime.hourOfPeriod.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.period.name}",
                      style: const TextStyle(fontSize: 17)),
                  if(entranceList.length >0)
                  const SizedBox(height: 20),
                  if(entranceList.length >0)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey, width: 0.5)),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entranceList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(entranceList[index]['categoryName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 17)),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:entranceList[index]['subCategory'].length,
                              itemBuilder: (context, subIndex) {
                                Map<String, dynamic> subCatData =
                                entranceList[index]['subCategory'][subIndex];
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(subCatData['entryCategoryName']),
                                    Text("₹ ${subCatData['entryCategoryPrice']}"),
                                    Text(
                                        "${subCatData['entryCategoryCount']} seats"),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  if(tableTypesController.tableTypes >0)
                  const Text("Tables",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                  const SizedBox(height: 10),
                  if(tableTypesController.tableTypes >0)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey, width: 0.5)),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tableTypesController.tableTypes.toInt(),
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tableName[index].text),
                            Text("₹ ${tablePrice[index].text}"),
                            Text("${tableAvailable[index].text} table"),
                            Text("${seatsAvailable[index].text} seats"),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: const BorderSide(color: Colors.black))),
                                // backgroundColor: WidgetStateProperty.resolveWith(
                                //         (states) => Colors.red),
                          ),
                          child: Text(
                              widget.isEditEvent
                                  ? "Cancel Update"
                                  : "Cancel Event",
                              style: const TextStyle(color: Colors.black)),
                        ),
                      ),
                      SizedBox(
                        width: 50.w,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            print('check it is');
                            SharedPreferences pref = await SharedPreferences.getInstance();
                            String planData = pref.getString('planData') ?? '';
                            // Map<String, dynamic> jsonConvert = jsonDecode(planData);
                            if (_formKey.currentState?.validate() == true) {
                              try {
                                if (_title.text.isNotEmpty &&
                                    _briefEvent.text.isNotEmpty &&
                                    _artistName.text.isNotEmpty &&
                                    dropGenre != "Select Genre" &&
                                    bandType.isNotEmpty &&
                                    checkEntranceNotEmpty(
                                        entranceName, entryCategoryCount) &&
                                    checkEntranceNotEmpty(
                                        entranceName, entryCategoryPrice)) {
                                  if (checkTableNotEmpty(tableName) &&
                                      checkTableNotEmpty(seatsAvailable) &&
                                      checkTableNotEmpty(tableAvailable) &&
                                      checkTableNotEmpty(tablePrice)) {
                                    if (uploadCover.isNotEmpty ||
                                        coverImage.isNotEmpty) {
                                      List entranceList = [];
                                      final entranceLength = entranceTypesController.entranceTypes.value;
                                      for (int i = 0; i < entranceLength; i++) {
                                        Map dataMap = {};
                                        dataMap['categoryName'] =
                                            entranceName[i].text.toUpperCase();
                                        dataMap['subCategory'] = [];
                                        final entranceCategoryLength = entranceCategoryController
                                                .entranceCategoryTypes[i].value;
                                        for (int j = 0; j < entranceCategoryLength; j++) {
                                          Map subCategoryMap = {};
                                          subCategoryMap['entryCategoryName'] =
                                              entryCategoryName[i][j].text.isNotEmpty
                                                  ? entryCategoryName[i][j].text.toUpperCase()
                                                  : 'Normal';

                                          if (!widget.isEditEvent) {
                                            // if (!widget.isEditEvent) {
                                            subCategoryMap['entryCategoryCount'] =
                                                int.parse(entryCategoryCount[i][j]
                                                    .text);
                                            subCategoryMap['entryCategoryCountLeft'] = int.parse(entryCategoryCount[i][j].text);
                                          }else{
                                            subCategoryMap['entryCategoryCount'] =
                                                int.parse(entryCategoryCount[i][j]
                                                    .text);
                                            subCategoryMap[
                                            'entryCategoryCountLeft'] =
                                                int.parse(entryCategoryCount[i][j].text);
                                          }
                                          subCategoryMap['entryCategoryPrice'] = int.parse(entryCategoryPrice[i][j].text);
                                          dataMap['subCategory'].add(subCategoryMap);
                                        }

                                        print(
                                            'check subcategory is ${dataMap['subCategory']}');
                                        entranceList.add(dataMap);
                                      }

                                      DateTime startTimeAPI = DateTime(
                                          selectedDate.year,
                                          selectedDate.month,
                                          selectedDate.day,
                                          startTime.hour,
                                          startTime.minute);
                                      DateTime endTimeAPI = DateTime(
                                          selectedDate.year,
                                          selectedDate.month,
                                          selectedDate.day,
                                          startTime.hour + durationInHours,
                                          startTime.minute);
                                      String eventId = widget.isEditEvent
                                          ? widget.eventId.toString()
                                          : randomAlphaNumeric(10);
                                      EasyLoading.show();
                                      print('club id is ${widget.clubUID}');
                                      Map<String, dynamic> sendData = {
                                        'clubUID': widget.isOrganiser
                                            ? widget.clubUID
                                            : uid(),
                                        'venueName': widget.isOrganiser
                                            ? widget.venueName
                                            : homeController.clubName.value,
                                        'title': _title.text,
                                        'bandType': bandType,
                                        'isNineSixteen': isNineSixteen,
                                        'briefEvent': _briefEvent.text,
                                        'artistName': _artistName.text,
                                        'entranceList': entranceList,
                                        'genre': dropGenre,
                                        'date': selectedDate,
                                        "created_at":DateTime.now(),
                                        'startTime': startTimeAPI,
                                        'endTime': endTimeAPI,
                                        'duration': durationInHours,
                                        'isHotPick': false,
                                        'hasOffers': offerImage.isNotEmpty,
                                        'isSponsored': false,
                                        // 'planId':jsonConvert['planId']??'',
                                        'organiserID': widget.isOrganiser ? uid() : null,
                                        'promoterID': [],
                                        if (!widget.isEditEvent)
                                          'isActive':
                                              widget.isOrganiser ? false : true,
                                        if (!widget.isEditEvent)
                                          'status': widget.isOrganiser ? 'P' : 'A'
                                      };
                                      await saveEntranceListRTDB(
                                          widget.isEditEvent,
                                          (widget.isEditEvent ? widget.eventId : eventId).toString(),
                                          entranceList);

                                      FirebaseFirestore.instance
                                          .collection("Events")
                                          .doc(widget.isEditEvent
                                              ? widget.eventId
                                              : eventId)
                                          .set(sendData, SetOptions(merge: true))
                                          .whenComplete(() {
                                        for (int i = 0;
                                            i < tableTypesController.tableTypes.value; i++) {
                                          FirebaseFirestore.instance.collection("Events").doc(widget.isEditEvent ? widget.eventId
                                                  : eventId).collection("Tables").doc('table${i + 1}').set({
                                            'tableName': tableName[i].text,
                                            'seatsAvail':
                                                int.parse(seatsAvailable[i].text),
                                            'seatsLeft':
                                                int.parse(seatsAvailable[i].text),
                                            'tableAvail':
                                                int.parse(tableAvailable[i].text),
                                            'tableLeft':
                                                int.parse(tableAvailable[i].text),
                                            'tablePrice':
                                                int.parse(tablePrice[i].text),
                                            'tableInclusion':
                                                eventController.includeTable ==
                                                        true
                                                    ? tableInclusion[i].text
                                                    : '',
                                          });
                                        }
                                      }).onError((error, stackTrace) {
                                        print('check error is $error');
                                      },).whenComplete(() {
                                        if (!widget.isOrganiser) {
                                          for (int i = 0;
                                              i <
                                                  tableTypesController
                                                      .tableTypes.value;
                                              i++) {
                                            FirebaseFirestore.instance
                                                .collection("Club")
                                                .doc(uid())
                                                .collection("DefaultTable")
                                                .doc('table${i + 1}')
                                                .set({
                                              'tableName': tableName[i].text,
                                              'seatsAvail':
                                                  seatsAvailable[i].text,
                                              'tableAvail':
                                                  tableAvailable[i].text,
                                              'tablePrice': tablePrice[i].text,
                                              'tableInclusion':
                                                  eventController.includeTable ==
                                                          true
                                                      ? tableInclusion[i].text
                                                      : '',
                                            });
                                          }
                                        }
                                      }).whenComplete(() {
                                        if (!widget.isOrganiser) {
                                          FirebaseFirestore.instance
                                              .collection("Club")
                                              .doc(uid())
                                              .collection("DefaultEntry")
                                              .doc('default')
                                              .set(sendData,
                                                  SetOptions(merge: true));
                                        }
                                      }).whenComplete(() {
                                        if (!widget.isOrganiser) {
                                          FirebaseFirestore.instance
                                              .collection("Club")
                                              .doc(uid())
                                              .set({
                                            'genre': dropGenre,
                                            'eventDate': selectedDate,
                                          }, SetOptions(merge: true));
                                        }
                                      }).whenComplete(() async {
                                        await uploadImage(
                                            uploadCover,
                                            widget.isEditEvent
                                                ? widget.eventId.toString()
                                                : eventId,
                                            homeController,
                                            coverImages: widget.isEditEvent
                                                ? uploadCover.isEmpty
                                                    ? coverImage
                                                    : []
                                                : [],
                                            isOrganiser: widget.isOrganiser,
                                            endTime: endTimeAPI,
                                            startTime: startTimeAPI);
                                      }).whenComplete(() async {
                                        if (uploadOffer.isNotEmpty) {
                                          await uploadImage(
                                              uploadOffer,
                                              widget.isEditEvent
                                                  ? widget.eventId.toString()
                                                  : eventId,
                                              homeController,
                                              coverImages: widget.isEditEvent
                                                  ? uploadOffer.isEmpty
                                                      ? offerImage
                                                      : []
                                                  : [],
                                              isOrganiser: widget.isOrganiser,
                                              endTime: endTimeAPI,
                                              startTime: startTimeAPI,
                                              isOffer: true);
                                        }
                                      }).whenComplete(() {
                                        EasyLoading.dismiss();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Get.back();
                                        Fluttertoast.showToast(
                                            msg: widget.isEditEvent
                                                ? 'Event Updated'
                                                : "Event Added Successfully");
                                      });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Select an upload cover");
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Fill all empty tables");
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Kindly fill all required fields");
                                }
                              } catch (e) {
                                print(e);
                                Fluttertoast.showToast(
                                    msg: 'Something Went Wrong');
                              }
                            }
                          },
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side:
                                          const BorderSide(color: Colors.black))),
                              backgroundColor: WidgetStateProperty.resolveWith(
                                  (states) => Colors.black)),
                          child: Text(
                              widget.isEditEvent ? "Update Event" : "Save Event",
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: matte(),
      appBar: appBar(context, title: "Events Management"),
      body: ValueListenableBuilder(
        valueListenable: checkEventCreate,
        builder: (context, bool isPlan, child) {
          // if(isPlan){
          //   return planMessage();
          // }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: Get.width,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    imageCoverWidget(coverImage, uploadCover,
                        isNineSixteenValue: !isNineSixteen),
                    // imageCoverWidget(offerImage, uploadOffer, isOffer: true),
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      "Event Details",
                      style: GoogleFonts.ubuntu(
                          fontSize: 45.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                    ),
                    textField("Event Title", _title, isMandatory: true),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Radio(
                                value: bandType,
                                groupValue: "DJ",
                                onChanged: (value) {
                                  setState(() {
                                    bandType = "DJ";
                                  });
                                },
                              ),
                              const Text("DJ",
                                  style: TextStyle(color: Colors.white))
                            ],
                          ),
                          Row(
                            children: [
                              Radio(
                                value: bandType,
                                groupValue: "Live band",
                                onChanged: (value) {
                                  setState(() {
                                    bandType = "Live band";
                                  });
                                },
                              ),
                              const Text("Live band",
                                  style: TextStyle(color: Colors.white))
                            ],
                          )
                        ],
                      ),
                    ),
                    textField("Brief About Event", _briefEvent,
                        isInfo: true, isMandatory: true),
                    textField("Artist Name", _artistName, isMandatory: true),
                    Container(
                      height: 130.h,
                      width: Get.width - 100.w,
                      decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: Center(
                        child: DropdownButton(
                          items: genreListdsgfhgf
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              alignment: Alignment.center,
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? val) {
                            setState(() {
                              dropGenre = val!;
                            });
                          },
                          value: dropGenre,
                          style: const TextStyle(color: Colors.white70),
                          dropdownColor: Colors.black,
                        ),
                      ),
                    ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Select Date and Time",
                          style: GoogleFonts.ubuntu(
                              fontSize: 45.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                showDate = !showDate;
                              });
                            },
                            icon: Icon(
                              showDate == false
                                  ? Icons.arrow_drop_down
                                  : Icons.arrow_drop_up,
                              color: Colors.white,
                            ))
                      ],
                    ),
                    AnimatedSwitcher(
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.decelerate,
                        reverseDuration: const Duration(milliseconds: 750),
                        duration: const Duration(milliseconds: 1000),
                        child: showDate == true
                            ? Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 120.h,
                                width: Get.width - 100.w,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Start Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.white70,
                                          fontSize: 45.sp),
                                    ),
                                    GestureDetector(
                                        onTap: () async {
                                          DateTime? picked =
                                          await showDatePicker(
                                              initialDate: selectedDate,
                                              firstDate: DateTime(2020),
                                              lastDate: DateTime(2101),
                                              context: context);
                                          if (picked != null &&
                                              picked != selectedDate) {
                                            setState(() {
                                              selectedDate = picked;
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 100.h,
                                          width: 300.w,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 4.h)),
                                          child: Center(
                                              child: Text(
                                                "Select Date",
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.white),
                                              )),
                                        )),
                                  ],
                                ),
                              ).marginOnly(
                                  left: 30.w,
                                  right: 30.w,
                                  bottom: 30.h,
                                  top: 20.h),
                              SizedBox(
                                height: 120.h,
                                width: Get.width - 100.w,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Start Time: ${DateFormat('hh : mm a').format(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startTime.hour, startTime.minute))}",
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.white70,
                                          fontSize: 45.sp),
                                    ),
                                    GestureDetector(
                                        onTap: () async {
                                          final TimeOfDay? pickedStartTime =
                                          await showTimePicker(
                                              context: context,
                                              initialTime: startTime);
                                          if (pickedStartTime != null &&
                                              pickedStartTime != startTime) {
                                            setState(() {
                                              startTime = pickedStartTime;
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 100.h,
                                          width: 300.w,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 4.h)),
                                          child: Center(
                                              child: Text(
                                                "Select Time",
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.white),
                                              )),
                                        )),
                                  ],
                                ),
                              ).marginOnly(
                                  left: 30.w,
                                  right: 30.w,
                                  bottom: 30.h,
                                  top: 20.h),
                              SizedBox(
                                height: 120.h,
                                width: Get.width - 100.w,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Duration: $durationInHours hours",
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.white70,
                                          fontSize: 45.sp),
                                    ),
                                    GestureDetector(
                                        onTap: () async {
                                          Get.defaultDialog(
                                              title:
                                              'Choose duration in Hours',
                                              content:
                                              Builder(builder: (context) {
                                                TextEditingController
                                                durationController =
                                                TextEditingController(
                                                    text:
                                                    '$durationInHours');
                                                return Column(
                                                  children: [
                                                    SizedBox(
                                                      width: 300.w,
                                                      child: TextFormField(
                                                        style: TextStyle(
                                                            fontSize: 50.sp),
                                                        textAlign:
                                                        TextAlign.center,
                                                        decoration: const InputDecoration(
                                                            border: OutlineInputBorder(
                                                                borderSide:
                                                                BorderSide(
                                                                    color:
                                                                    Colors.blue))),
                                                        controller:
                                                        durationController,
                                                        keyboardType:
                                                        TextInputType
                                                            .number,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        validator:
                                                            (validate) {
                                                          if (durationController
                                                              .text
                                                              .isNotEmpty) {
                                                            return null;
                                                          } else {
                                                            return 'Enter a valid value';
                                                          }
                                                        },
                                                      ),
                                                    ).paddingSymmetric(
                                                        vertical: 20.h),
                                                    ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                            WidgetStateProperty.resolveWith(
                                                                    (states) =>
                                                                Colors
                                                                    .black)),
                                                        onPressed: () {
                                                          setState(() {
                                                            durationInHours =
                                                                int.parse(
                                                                    durationController
                                                                        .text);
                                                          });
                                                          Get.back();
                                                        },
                                                        child:
                                                        const Text('Ok'))
                                                  ],
                                                );
                                              }));
                                        },
                                        child: Container(
                                          height: 100.h,
                                          width: 300.w,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 4.h)),
                                          child: Center(
                                              child: Text(
                                                "Select duration",
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.white),
                                              )),
                                        )),
                                  ],
                                ),
                              ).marginOnly(
                                  left: 30.w,
                                  right: 30.w,
                                  bottom: 30.h,
                                  top: 20.h),
                            ],
                          ),
                        ).marginOnly(
                            left: 30.w, right: 30.w, bottom: 30.h, top: 20.h)
                            : Container()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Select ",
                          style: TextStyle(color: Colors.white, fontSize: 45.sp),
                        ),
                        const Icon(
                          Icons.check_box_outlined,
                          color: Colors.white,
                        ),
                        Text(
                          " for inclusions (if any)",
                          style: TextStyle(color: Colors.white, fontSize: 45.sp),
                        )
                      ],
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Obx(() => Checkbox(
                          value: eventController.includeEntrance,
                          fillColor: WidgetStateProperty.resolveWith(
                                  (states) => Colors.white),
                          focusColor: Colors.white,
                          activeColor: Colors.orange,
                          checkColor: Colors.orange,
                          onChanged: (val) {
                            eventController.changeIncludeEntrance(val!);
                          }).paddingSymmetric()),
                      Text(
                        "Entrance Management",
                        style: GoogleFonts.ubuntu(
                            fontSize: 45.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              entranceShow = !entranceShow;
                            });
                          },
                          icon: Icon(
                            entranceShow == false
                                ? Icons.arrow_drop_down
                                : Icons.arrow_drop_up,
                            color: Colors.white,
                          ))
                    ]),
                    AnimatedSwitcher(
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.decelerate,
                        reverseDuration: const Duration(milliseconds: 750),
                        duration: const Duration(milliseconds: 1000),
                        child: entranceShow == true
                            ? Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10)),
                            child: Obx(
                                  () => ListView.builder(
                                itemCount: entranceTypesController.entranceTypes.value,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Obx(
                                        () => Column(
                                      children: [
                                        Text(
                                            "Entrance Category Type ${index + 1}",
                                            style: GoogleFonts.ubuntu(
                                                color: Colors.white,
                                                fontSize: 40.sp)),
                                        textField("Entrance Name", entranceName[index],
                                            isMandatory: true,isReadOnly: true),
                                        eventController.includeTable == true
                                            ? textField("Includes",
                                            entryNotesList[index])
                                            : Container(),
                                        ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                            const NeverScrollableScrollPhysics(),
                                            itemCount:
                                            entranceCategoryController.entranceCategoryTypes[index].value,
                                            itemBuilder: (context, subIndex) {
                                              print(entranceCategoryController.entranceCategoryTypes[index].value);
                                              return Column(
                                                children: [
                                                  const Divider(
                                                    color: Colors.grey,
                                                    thickness: 2,
                                                  ).paddingSymmetric(horizontal: 50.w),
                                                  textField("Entry Sub Category Name",
                                                      entryCategoryName[index]
                                                      [subIndex],
                                                      isMandatory: false),
                                                  textField(
                                                      "Total Entries",
                                                      entryCategoryCount[index]
                                                      [subIndex],
                                                      isNum: true,
                                                      isReadOnly: widget
                                                          .isEditEvent &&
                                                          entryCategoryCount[
                                                          index]
                                                          [subIndex]
                                                              .text
                                                              .isNotEmpty,
                                                      isMandatory: true),
                                                  textField(
                                                      "Entry Charges",
                                                      entryCategoryPrice[index]
                                                      [subIndex],
                                                      isNum: true,
                                                      isMandatory: true),
                                                ],
                                              );
                                            }),
                                        if (eventController.includeEntrance)
                                          textField(
                                              'Notes', entryNotesList[index]),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                if (entranceCategoryController.entranceCategoryTypes[index].value <= 4) {
                                                  if (entryCategoryName[index][entranceCategoryController.entranceCategoryTypes[index].value - 1].text.isNotEmpty) {
                                                    entranceCategoryController.incTypes(index);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg: 'Please enter a sub name for previous sub category before adding more.',
                                                        timeInSecForIosWeb: 5);
                                                  }
                                                }
                                              },
                                              style: ButtonStyle(
                                                  shape: WidgetStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                          side:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .grey))),
                                                  backgroundColor:
                                                  WidgetStateProperty
                                                      .resolveWith(
                                                          (states) =>
                                                      Colors.black)),
                                              child: const Text(
                                                  "Add Sub Category"),
                                            ),
                                            SizedBox(
                                              width: 50.w,
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (widget.isEditEvent) {
                                                  onTapSoldOut(index);
                                                } else {
                                                  int subCategoryTypes =
                                                      entranceCategoryController
                                                          .entranceCategoryTypes[
                                                      index]
                                                          .value;
                                                  if (subCategoryTypes > 1) {
                                                    int subIndex =
                                                        subCategoryTypes - 1;
                                                    entryCategoryName[index]
                                                    [subIndex]
                                                        .clear();
                                                    entryCategoryPrice[index]
                                                    [subIndex]
                                                        .clear();
                                                    entryCategoryCount[index]
                                                    [subIndex]
                                                        .clear();
                                                    entranceCategoryController
                                                        .decTypes(index);
                                                  }
                                                }
                                              },
                                              style: ButtonStyle(
                                                  shape: WidgetStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                          side: const BorderSide(
                                                              color: Colors
                                                                  .grey))),
                                                  backgroundColor:
                                                  WidgetStateProperty.resolveWith(
                                                          (states) => widget
                                                          .isEditEvent
                                                          ? Colors.red
                                                          : Colors.black)),
                                              child: Text(widget.isEditEvent
                                                  ? "Mark as Sold Out"
                                                  : "Remove Sub Category"),
                                            ),
                                          ],
                                        ).marginSymmetric(horizontal: 20.h),
                                        Text(
                                          'Tap to add or remove sub category (if any,Ex:Early Bird)',
                                          style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 40.sp),
                                        ).paddingSymmetric(vertical: 40.h)
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )).marginAll(20.w)
                            : Container()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (entranceTypesController.entranceTypes.value <= 30) {
                              entranceTypesController.incTypes();
                            }
                          },
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(color: Colors.grey))),
                              backgroundColor: WidgetStateProperty.resolveWith(
                                      (states) => Colors.black)),
                          child: const Text("Add Entrance"),
                        ),
                        SizedBox(
                          width: 50.w,
                        ),
                        if (!widget.isEditEvent)
                          ElevatedButton(
                            onPressed: () {
                              if (entranceTypesController.entranceTypes > 1) {
                                entranceTypesController.decTypes();
                              }
                            },
                            style: ButtonStyle(
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side:
                                        const BorderSide(color: Colors.grey))),
                                backgroundColor: WidgetStateProperty.resolveWith(
                                        (states) => Colors.black)),
                            child: const Text("Remove Entrance"),
                          ),
                      ],
                    ).marginAll(20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => Checkbox(
                            value: eventController.includeTable,
                            fillColor: WidgetStateProperty.resolveWith(
                                    (states) => Colors.white),
                            focusColor: Colors.white,
                            activeColor: Colors.orange,
                            checkColor: Colors.orange,
                            onChanged: (val) {
                              eventController.changeIncludeTable(val!);
                            }).paddingSymmetric()),
                        Text(
                          "Table Management",
                          style: GoogleFonts.ubuntu(
                              fontSize: 45.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                tableShow = !tableShow;
                              });
                            },
                            icon: Icon(
                              tableShow == false
                                  ? Icons.arrow_drop_down
                                  : Icons.arrow_drop_up,
                              color: Colors.white,
                            ))
                      ],
                    ),
                    AnimatedSwitcher(
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.decelerate,
                        reverseDuration: const Duration(milliseconds: 750),
                        duration: const Duration(milliseconds: 1000),
                        child: tableShow == true
                            ? Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10)),
                            child: Obx(
                                  () => ListView.builder(
                                itemCount:
                                tableTypesController.tableTypes.value,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Obx(
                                        () => Column(
                                      children: [
                                        Text("Table Category Type ${index + 1}",
                                            style: GoogleFonts.ubuntu(
                                                color: Colors.white,
                                                fontSize: 40.sp)),
                                        textField(
                                            "Table Name", tableName[index],
                                            isMandatory: true),
                                        textField("Seats Available",
                                            seatsAvailable[index],
                                            isNum: true, isMandatory: true),
                                        textField("Table Available",
                                            tableAvailable[index],
                                            isNum: true, isMandatory: true),
                                        textField(
                                            "Table Price", tablePrice[index],
                                            isNum: true, isMandatory: true),
                                        eventController.includeTable == true
                                            ? textField("Includes",
                                            tableInclusion[index])
                                            : Container()
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )).marginAll(20.w)
                            : Container()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (tableTypesController.tableTypes.value <= 30) {
                              tableTypesController.incTypes();
                            }
                          },
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(color: Colors.grey))),
                              backgroundColor: WidgetStateProperty.resolveWith(
                                      (states) => Colors.black)),
                          child: const Text("  Add Table "),
                        ).paddingOnly(right: 50.w),
                        ElevatedButton(
                          onPressed: () {
                            if (tableTypesController.tableTypes > 0) {
                              tableTypesController.decTypes();
                            }
                          },
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(color: Colors.grey))),
                              backgroundColor: WidgetStateProperty.resolveWith(
                                      (states) => Colors.black)),
                          child: const Text("Remove Table"),
                        ),
                      ],
                    ).marginAll(20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(color: Colors.grey))),
                              backgroundColor: WidgetStateProperty.resolveWith(
                                      (states) => Colors.red)),
                          child: Text(widget.isEditEvent
                              ? "Cancel Update"
                              : "Cancel Event"),
                        ),
                        SizedBox(
                          width: 50.w,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            
                         var data =   await FirebaseFirestore.instance.collection('Events').where('clubUID',isEqualTo: uid()).get();

                         var todayEvents = data.docs.where((doc) {
                           Timestamp timestamp = doc['date'];
                           DateTime eventDate = timestamp.toDate();

                           return eventDate.year == selectedDate.year &&
                               eventDate.month == selectedDate.month &&
                               eventDate.day == selectedDate.day;
                         }).toList();


                         if(todayEvents.isNotEmpty){
                           Fluttertoast.showToast(msg: 'An event with the same date has already been created.');
                           return;
                         }
                            // abcd
                            print('cehck it is ');
                            if (_formKey.currentState?.validate() == true) {
                              try {
                                if (_title.text.isNotEmpty && _briefEvent.text.isNotEmpty &&
                                    _artistName.text.isNotEmpty && dropGenre != "Select Genre" && bandType.isNotEmpty &&
                                    checkEntranceNotEmpty(entranceName, entryCategoryCount) &&
                                    checkEntranceNotEmpty(
                                        entranceName, entryCategoryPrice)) {
                                  if (checkTableNotEmpty(tableName) &&
                                      checkTableNotEmpty(seatsAvailable) &&
                                      checkTableNotEmpty(tableAvailable) &&
                                      checkTableNotEmpty(tablePrice)) {
                                    if (uploadCover.isNotEmpty || coverImage.isNotEmpty) {
                                      print('check cover image is ${coverImage}');
                                      print('check cover image is ${uploadCover}');
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return eventPreview();
                                        },
                                      );
                                      return;
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Select an upload cover");
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Fill all empty tables");
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Kindly fill all required fields");
                                }
                              } catch (e) {
                                print(e);
                                Fluttertoast.showToast(msg: 'Something Went Wrong');
                              }
                            }
                          },
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(color: Colors.grey))),
                              backgroundColor: WidgetStateProperty.resolveWith(
                                      (states) => Colors.green)),
                          child: Text(
                              widget.isEditEvent ? "Update Event" : "Save Event"),
                        ),
                      ],
                    ).marginAll(20.h),
                  ],
                ),
              ),
            ),
          );
        },

      ),
    );
  }
}
