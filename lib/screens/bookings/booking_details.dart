import 'dart:io';
import 'dart:ui';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/bookings/booking_event_view.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import '../../search/testing print.dart';
import 'booking_controller.dart';

class BookingDetails extends StatefulWidget {
  final String bookingID;
  final String? eventId;
  final String? uuid;
  final String? clubUid;

  const BookingDetails({required this.bookingID, Key? key, this.eventId,  this.uuid,this.clubUid}) : super(key: key);

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  final List<TextEditingController> tableTextController =
      List.generate(30, (i) => TextEditingController(text: '0'));
  final List<TextEditingController> entranceTextController =
      List.generate(30, (i) => TextEditingController(text: '0'));
  TextEditingController bookingCode = TextEditingController();
  late BookingEventView bookingEntranceView;
  late BookingEventView bookingTableView;
  final bookingController = Get.put(BookingController());
  List entranceList = [];
  late BluetoothService _bluetoothService;


  final GlobalKey _qrKey = GlobalKey();

  Future<Uint8List> _capturePng() async {
    RenderRepaintBoundary boundary =
    _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    var image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _printQrCode() async {
    final qrImage = await _capturePng();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(pw.MemoryImage(qrImage), width: 200, height: 200),
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }


  TableRow initRow({required String title, required String? val}) => TableRow(
        children: [
          Text(
            title,
            style: GoogleFonts.ubuntu(
              color: Colors.orange,
              fontSize: 45.sp,
            ),
          ).paddingAll(40.w),
          Text(
            "$val",
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontSize: 45.sp,
            ),
          ).paddingAll(40.w),
        ],
      );

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {});
    bookingEntranceView = BookingEventView(
        bookingID: widget.bookingID, textController: entranceTextController);
    bookingTableView = BookingEventView(
      bookingID: widget.bookingID,
      textController: tableTextController,
      isTableBooking: true,
    );
    super.initState();
    _bluetoothService = BluetoothService(
      context: context,
      onConnectionChanged: (connected) {
        setState(() {}); // optional UI update
      },
    );

    _bluetoothService.initBluetooth();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCheckInOut();
    });
  }

  List entryDetail = [];
  Future<void> fetchCheckInOut() async {
    print('check uid is ${widget.eventId}');

    try {
      var docRef = FirebaseFirestore.instance.collection('CheckInOut').doc(widget.eventId);
      var snapshot = await docRef.get();

      if (!snapshot.exists || snapshot.data()?['checkInList'] == null) {
        print('Document does not exist or checkInList is missing');
        return;
      }

      List<dynamic> userList = List.from(snapshot.data()!['checkInList']);
      print('check it is $userList');

      // Find matching booking
      entryDetail = userList
          .where((e) => e['bookingId'].toString() == widget.bookingID.toString())
          .toList();

      if (entryDetail.isEmpty) {
        print('No matching bookingId found in checkInList');
        return;
      }

      setState(() {});

      Future.delayed(Duration(seconds: 1), () {
        final entry = entryDetail[0];
        // if (entry['checkOut'] != null && entry['checkOut'].toString().isNotEmpty) {
        String durationFormatted = '';
        if(entry['checkIn'].toString() != '' && entry['checkOut'].toString() != '')  {
          DateTime startDate = (entry['checkIn'] as Timestamp).toDate();
          DateTime endDate = (entry['checkOut'] as Timestamp).toDate();

          Duration diff = endDate.difference(startDate);

          // Format as HH:mm:ss
           durationFormatted =
              "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes %
              60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60)
              .toString()
              .padLeft(2, '0')}";

          print('time duration difference is $durationFormatted');
        }

          // Update Firestore
          updateStatus(
            widget.eventId.toString(),
            widget.bookingID.toString(),
            durationFormatted,
            entry['checkIn'],
            entry['checkOut'],
          );
        // } else {
        //   print('Check-out is not available yet.');
        // }
      });
    } catch (e) {
      print('Error fetching check-in/out data: $e');
    }
  }


  Future<void> updateStatus(String eventId, String bookingId, dynamic duration, dynamic checkIn, dynamic checkOut) async {
    print('check id $eventId \\ $duration $checkIn $checkOut');

    var querySnapshot = await FirebaseFirestore.instance
        .collection('PrAnalytics')
        .where('eventId', isEqualTo: eventId)
        .get();

    for (var doc in querySnapshot.docs) {
      List<dynamic> userList = List.from(doc['userList']);

      bool updated = false;

      for (int i = 0; i < userList.length; i++) {
        if (userList[i]['bookingId'].toString() == bookingId.toString()) {
          userList[i]['checkIn'] = checkIn??'';
          userList[i]['checkOut'] = checkOut??'';
          userList[i]['duration'] = duration??'';
          updated = true;
          break;
        }
      }

      if (updated) {
        await FirebaseFirestore.instance
            .collection('PrAnalytics')
            .doc(doc.id)
            .update({'userList': userList});

        print('userList updated successfully for document ${doc.id}');
      } else {
        print('BookingId not found in document ${doc.id}');
      }
    }

    if (querySnapshot.docs.isEmpty) {
      print('No documents found for eventId: $eventId');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(context, title: widget.bookingID,),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 20,),
              if(entryDetail.isNotEmpty)
              Text('Check In : ${DateFormat('dd-MM-yyyy hh:mm a').format(
                  (entryDetail[0]['checkIn'] as Timestamp).toDate()
              )}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),

              if(entryDetail.isNotEmpty && entryDetail[0]['checkOut'] != '')
              Text('Check Out : ${DateFormat('dd-MM-yyyy hh:mm a').format(
                  (entryDetail[0]['checkOut'] as Timestamp).toDate()
              )}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
              Obx(() {
                return Column(
                  children: [
                    bookingEntranceView,
                    bookingTableView,
                    if (isRemainingEntries(
                        entranceList: bookingController.getEntranceList,
                        tableList: bookingController.getTableList))
                      ElevatedButton(
                        onPressed: () {
                          if (checkTableForZero(
                                  bookingController, tableTextController) ||
                              checkEntranceForZero(
                                  bookingController, entranceTextController)) {
                            if (checkTable(
                                    bookingController, tableTextController) &&
                                checkEntrance(bookingController,
                                    entranceTextController)) {
                              Get.defaultDialog(
                                  backgroundColor: Colors.black,
                                  title: "",
                                  titleStyle:
                                      GoogleFonts.ubuntu(color: Colors.white),
                                  content: Column(
                                    children: [
                                      // textField(
                                      //     "Enter Booking Code", bookingCode,
                                      //     isNum: true),
                                      ElevatedButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection("Bookings")
                                              .doc(widget.bookingID)
                                              .get()
                                              .then((value) {
                                            if (value.exists) {
                                              EasyLoading.show();
                                              for (int index = 0;
                                                  index <
                                                      bookingController
                                                          .getEntranceList
                                                          .length;
                                                  index++) {
                                                int entranceCount = int.parse(
                                                    entranceTextController[
                                                            index].text);

                                                if (entranceCount > 0) {
                                                  updateAsTransactionBooking(
                                                      widget.bookingID,
                                                      index.toString(),
                                                      (-entranceCount));
                                                }
                                              }
                                              for (int index = 0;
                                                  index <
                                                      bookingController
                                                          .getTableList.length;
                                                  index++) {
                                                int tableCount = int.parse(
                                                    tableTextController[index]
                                                        .text);

                                                if (tableCount > 0) {
                                                  updateAsTransactionBooking(
                                                      widget.bookingID,
                                                      index.toString(),
                                                      (-tableCount),
                                                      isTableBooking: true);
                                                }
                                              }
                                              for (TextEditingController controller
                                                  in entranceTextController) {
                                                controller.text = '0';
                                              }
                                              for (TextEditingController controller
                                                  in tableTextController) {
                                                controller.text = '0';
                                              }

                                              Get.back();
                                              bookingCode.clear();
                                              EasyLoading.dismiss();

                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Entries done successfully");
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: "Something went wrong");
                                            }
                                          });
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty
                                                    .resolveWith((states) =>
                                                        Colors.orange)),
                                        child: const Text("Confirm Entry"),
                                      )
                                    ],
                                  ));
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Entries exceed limit");
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: "At least one entry required");
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith(
                                (states) => Colors.orange)),
                        child: const Text("Confirm Entry"),
                      )
                    else
                      Text(
                        "No remaining entries",
                        style: GoogleFonts.ubuntu(
                            color: Colors.white, fontSize: 60.sp),
                      ).paddingAll(50.h)
                  ],
                );
              }),


              FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Bookings')
                      .doc(widget.bookingID)
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: Get.height,
                        width: Get.width,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData) {
                      return SizedBox(
                        height: Get.height,
                        width: Get.width,
                        child: Center(
                          child: Text(
                            'No Data Found',
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: 45.sp,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Column(children: [
                        Text(
                          'Booking Details',
                          style: GoogleFonts.ubuntu(
                            color: Colors.amber,
                            fontSize: 60.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ).paddingAll(40.sp),
                        Table(
                          border: TableBorder.all(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.amber,
                          ),
                          children: [
                            tableRowWidget(
                              title: 'Booking ID',
                              value: "${snapshot.data?.get("bookingID")}",
                            ),
                            tableRowWidget(
                              title: 'Total Entry',
                              value:
                                  "${snapshot.data?.get("totalEntranceCount")}",
                            ),
                            tableRowWidget(
                              title: 'Total Table',
                              value:
                                  "${getKeyValueFirestore(snapshot.data!, "totalTableCount") ?? 0}",
                            ),
                            tableRowWidget(
                              title: 'Total Amount',
                              value: "₹ ${snapshot.data?.get("amount")}",
                            ),
                            tableRowWidget(
                              title: 'Booking Code',
                              value: "${snapshot.data?.get("bookingCode")}",
                            ),
                          ],
                        ).paddingAll(40.w),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('User')
                              .doc(getKeyValueFirestore(
                                  snapshot.data!, 'userID'))
                              .get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(
                                height: Get.height,
                                width: Get.width,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.orange,
                                  ),
                                ),
                              );
                            } else if (!snapshot.hasData) {
                              return SizedBox(
                                height: Get.height,
                                width: Get.width,
                                child: Center(
                                  child: Text(
                                    'No Data Found',
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize: 45.sp,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Column(
                                children: [
                                  Text(
                                    'User Details',
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.amber,
                                      fontSize: 60.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ).paddingAll(40.sp),
                                  Table(
                                    border: TableBorder.all(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.amber,
                                      style: BorderStyle.solid,
                                    ),
                                    children: [
                                      TableRow(
                                        children: [
                                          Text(
                                            'User Name',
                                            style: GoogleFonts.ubuntu(
                                              color: Colors.orange,
                                              fontSize: 45.sp,
                                            ),
                                          ).paddingAll(40.w),
                                          Text(
                                            "${snapshot.data?.get("userName").toString().capitalizeFirstOfEach}",
                                            style: GoogleFonts.ubuntu(
                                              color: Colors.white,
                                              fontSize: 45.sp,
                                            ),
                                          ).paddingAll(40.w),
                                        ],
                                      ),
                                    ],
                                  ).paddingAll(40.w),
                                ],
                              );
                            }
                          },
                        ),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('Club')
                              .doc(getKeyValueFirestore(
                                  snapshot.data!, 'clubUID'))
                              .get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(
                                height: Get.height,
                                width: Get.width,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.orange,
                                  ),
                                ),
                              );
                            } else if (!snapshot.hasData) {
                              return SizedBox(
                                height: Get.height,
                                width: Get.width,
                                child: Center(
                                  child: Text(
                                    'No Data Found',
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize: 45.sp,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox(
                                child: Column(
                                  children: [
                                    Text(
                                      'Club Details',
                                      style: GoogleFonts.ubuntu(
                                        color: Colors.amber,
                                        fontSize: 60.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ).paddingAll(40.sp),
                                    Table(
                                      border: TableBorder.all(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.amber,
                                        style: BorderStyle.solid,
                                      ),
                                      children: [
                                        TableRow(
                                          children: [
                                            Text(
                                              'Club Name',
                                              style: GoogleFonts.ubuntu(
                                                color: Colors.orange,
                                                fontSize: 45.sp,
                                              ),
                                            ).paddingAll(40.w),
                                            Text(
                                              "${snapshot.data?.get("clubName")}",
                                              style: GoogleFonts.ubuntu(
                                                color: Colors.white,
                                                fontSize: 45.sp,
                                              ),
                                            ).paddingAll(40.w),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            Text(
                                              'Club Venue',
                                              style: GoogleFonts.ubuntu(
                                                color: Colors.orange,
                                                fontSize: 45.sp,
                                              ),
                                            ).paddingAll(40.w),
                                            Text(
                                              "${snapshot.data?.get("address")}, ${snapshot.data?.get("area")}, ${snapshot.data?.get("city")}, ${snapshot.data?.get("state")}",
                                              style: GoogleFonts.ubuntu(
                                                color: Colors.white,
                                                fontSize: 45.sp,
                                              ),
                                            ).paddingAll(40.w),
                                          ],
                                        ),
                                      ],
                                    ).paddingAll(40.w),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ]);
                    }
                  }),

              SizedBox(height: 10,),
              Container(
                color: Colors.white,
                child: RepaintBoundary(
                  key: _qrKey,
                  child: PrettyQr(
                    data: 'UA|${widget.bookingID}|${widget.clubUid}|${widget.eventId}|${widget.uuid}',
                    size: 300,
                    roundEdges: true,
                    typeNumber: 5,
                    elementColor: Colors.black,
                    image: const AssetImage('assets/logo.png'),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: ()async{
                    // final qrBytes = await generateQrCode(widget.bookingID.toString());
                    // await saveQrToFile(qrBytes);
                    // _printQrCode();

                    // bool? isConnected = await bluetooth.isConnected;

                    // if (isConnected != null && isConnected) {
                    //   print('yes t');
                    //   bluetooth.printNewLine();
                    //   bluetooth.printCustom("Hello World", 1, 1); // (text, size, align)
                    //   bluetooth.printNewLine();
                    //   bluetooth.paperCut(); // optional
                    // } else {
                    //  print('yes chekc ');
                    // }
                    // printSample();
                    // Get.to(MyApps());
                    // 'UA|${widget.bookingID}|${widget.eventId}|${widget.uuid}'

                    showModalBottomSheet(
                        context: context,
                        builder: (contex){
                          return Container(
                           child: Padding(
                             padding: const EdgeInsets.all(20.0),
                             child: Column(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 GestureDetector(
                                   onTap:(){
                                     _bluetoothService.printSample(
                                       bookingID: widget.bookingID,
                                       eventId: widget.eventId.toString(),
                                       uuid: widget.uuid.toString(),
                                       alignment: 'center'
                                     );
                                     Navigator.pop(context);
                                   },

                                   child: Container(
                                     decoration: BoxDecoration(
                                         color: Colors.orangeAccent,
                                         borderRadius: BorderRadius.all(Radius.circular(11))
                                     ),
                                     child: Padding(
                                       padding: const EdgeInsets.all(8.0),
                                       child: Center(child:  Text('Center',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),),
                                     ),
                                   ),
                                 ),
                                 SizedBox(height: 20,),
                                 GestureDetector(
                                   onTap:(){
                                     _bluetoothService.printSample(
                                       bookingID: widget.bookingID,
                                       eventId: widget.eventId.toString(),
                                       uuid: widget.uuid.toString(),
                                       alignment: 'right',

                                     );
                                     Navigator.pop(context);

                                   },
                                   child: Container(
                                     decoration: BoxDecoration(
                                         color: Colors.orangeAccent,
                                         borderRadius: BorderRadius.all(Radius.circular(11))
                                     ),
                                     child: Padding(
                                       padding: const EdgeInsets.all(8.0),
                                       child: Center(child:  Text('Right',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),),
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                          );
                        });
                      },

                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.all(Radius.circular(11))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child:  Text('Print',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: 10,),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 15),
              //   child: GestureDetector(
              //     onTap: ()async{
              //       // final qrBytes = await generateQrCode(widget.bookingID.toString());
              //       // await saveQrToFile(qrBytes);
              //       _printQrCode();
              //       // printSample();
              //     },
              //
              //     child: Container(
              //       decoration: BoxDecoration(
              //           color: Colors.orangeAccent,
              //           borderRadius: BorderRadius.all(Radius.circular(11))
              //       ),
              //       child: Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: Center(child:  Text('Print1',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),),
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(height: 30,),
            ],
          ),
        ));
  }

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? selectedDevice;
  bool _isConnected = false;



  void getBluetoothDevices() async {
    try {
      // Check if Bluetooth is turned on first
      // bool isBluetoothOn = await bluetooth.isBluetoothEnabled;
      // if (!isBluetoothOn) {
      //   Fluttertoast.showToast(msg: 'Please turn on Bluetooth');
      //   return;
      // }
      autoReconnectToLastDevice();
      // Check if already connected
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? address = prefs.getString('last_connected_device');
      bool? isConnected = await bluetooth.isConnected;


      if (isConnected == true) {
        // Try to get name of connected device (approximation: first from paired list)
        List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
        String deviceName = bondedDevices.isNotEmpty ? bondedDevices.first.name ?? "Bluetooth Printer" : "Bluetooth Printer";

        setState(() {
          _isConnected = true;
        });

        Fluttertoast.showToast(msg: 'Connected to $deviceName');
        return;
      }

      // Not connected: show list of bonded devices
      List<BluetoothDevice> devices = [];
      try {
        devices = await bluetooth.getBondedDevices();
      } on PlatformException {
        Fluttertoast.showToast(msg: "Failed to get bonded devices.");
        return;
      }

      if (!mounted) return;
      setState(() {
        _devices = devices;
      });

      if (_devices.isEmpty) {
        Fluttertoast.showToast(msg: 'No Bluetooth devices found');
        return;
      }

      // Listen to state changes
      bluetooth.onStateChanged().listen((state) {
        switch (state) {
          case BlueThermalPrinter.CONNECTED:
            setState(() {
              _isConnected = true;
            });
            print("Bluetooth state: connected");
            break;
          default:
            setState(() {
              _isConnected = false;
            });
            print("Bluetooth state: $state");
            break;
        }
      });

      // Show dialog to select device to connect
      showDialog(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Material(
              color: Colors.black,
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(11)),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _devices.map((device) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Close dialog
                            connectToDevice(device);
                          },
                          child: Text(
                            device.name ?? "Unknown device",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white,fontSize: 18),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(msg: 'Bluetooth error: $e');
    }
  }





  // Connect to the selected device
  void connectToDevice(BluetoothDevice device) async {
    await bluetooth.connect(device);
    await saveLastDeviceAddress(device.address.toString());
    setState(() {
      selectedDevice = device;
      _isConnected = true;
    });
    Fluttertoast.showToast(msg: 'Device Connected ${device.name}');

  }
  Future<void> autoReconnectToLastDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? address = prefs.getString('last_connected_device');

    if (address != null) {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      BluetoothDevice? matchedDevice = devices.firstWhere(
            (d) => d.address == address,

      );

      if (matchedDevice != null) {
        await bluetooth.connect(matchedDevice);
        setState(() {
          selectedDevice = matchedDevice;
          _isConnected = true;
        });
        Fluttertoast.showToast(msg: "Auto-connected to ${matchedDevice.name}");
      }
    }
  }


  // Disconnect from the device
  void disconnect() async {
    await bluetooth.disconnect();
    setState(() {
      selectedDevice = null;
      _isConnected = false;
    });
  }
  Future<void> saveLastDeviceAddress(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_connected_device', address);
  }

  void printSample() async {
    if (_isConnected) {
      try {
        bluetooth.writeBytes(Uint8List.fromList([27, 64])); // Initialize printer
        bluetooth.printNewLine();
        bluetooth.printQRcode(
          'UA|${widget.bookingID}|${widget.eventId}|${widget.uuid}',
          300, 300, Aligns.center.val,
        );
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      } catch (e) {
        print('Print error: $e');
        Fluttertoast.showToast(msg: 'Print error: $e');
      }
    } else {
      Fluttertoast.showToast(msg: 'Printer not connected');
      print('Printer not connected');
    }
  }
}

class BookingController extends GetxController {
  final tableList = [].obs;
  final _entranceList = [].obs;

  List get getEntranceList => _entranceList;

  List get getTableList => tableList;

  updateBookingList(List newList) => _entranceList.value = newList;

  updateTableBookingList(List newList) => tableList.value = newList;
}

enum Sizes {
  medium, //normal size text
  bold, //only bold text
  boldMedium, //bold with medium
  boldLarge, //bold with large
  extraLarge //extra large
}

enum Aligns {
  left, //ESC_ALIGN_LEFT
  center, //ESC_ALIGN_CENTER
  right, //ESC_ALIGN_RIGHT
}

extension PrintSize on Sizes {
  int get val {
    switch (this) {
      case Sizes.medium:
        return 0;
      case Sizes.bold:
        return 1;
      case Sizes.boldMedium:
        return 2;
      case Sizes.boldLarge:
        return 3;
      case Sizes.extraLarge:
        return 4;
      default:
        return 0;
    }
  }
}

extension PrintAlign on Aligns {
  int get val {
    switch (this) {
      case Aligns.left:
        return 0;
      case Aligns.center:
        return 1;
      case Aligns.right:
        return 2;
      default:
        return 0;
    }
  }
}



