import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_utils.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:number_to_words_english/number_to_words_english.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key, });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  List clubBookingList = [];
  late TabController tabController;
  ValueNotifier<bool> isLoadingBooking = ValueNotifier(false);
  ValueNotifier<bool> plan = ValueNotifier(true);

  void fetchUpcomingMonthEventData() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var planData =pref.getString('planData')??'';

    plan.value = planData ==''?false:true;

    isLoadingBooking.value =true;
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('Events')
        .where('clubUID', isEqualTo:uid() )
        .get();
    clubBookingList = data.docs;
    setState(() {});
    isLoadingBooking.value =false;
    print('check booking event is ${clubBookingList}');
  }


  final Map<String, String> indianStateCodes = {
    "Andhra Pradesh": "AP",
    "Arunachal Pradesh": "AR",
    "Assam": "AS",
    "Bihar": "BR",
    "Chhattisgarh": "CG",
    "Goa": "GA",
    "Gujarat": "GJ",
    "Haryana": "HR",
    "Himachal Pradesh": "HP",
    "Jharkhand": "JH",
    "Karnataka": "KA",
    "Kerala": "KL",
    "Madhya Pradesh": "MP",
    "Maharashtra": "MH",
    "Manipur": "MN",
    "Meghalaya": "ML",
    "Mizoram": "MZ",
    "Nagaland": "NL",
    "Delhi NCR":'Dl',
    "Odisha": "OR",
    "Punjab": "PB",
    "Rajasthan": "RJ",
    "Sikkim": "SK",
    "Tamil Nadu": "TN",
    "Telangana": "TG",
    "Tripura": "TR",
    "Uttar Pradesh": "UP",
    "Uttarakhand": "UK",
    "West Bengal": "WB",
    "Delhi": "DL",
    "Jammu and Kashmir": "JK",
    "Ladakh": "LA",
    "Puducherry": "PY",
    "Chandigarh": "CH",
    "Andaman and Nicobar Islands": "AN",
    "Dadra and Nagar Haveli and Daman and Diu": "DN",
    "Lakshadweep": "LD"
  };


  String getStateCode(String stateName) {
    return indianStateCodes[stateName] ?? '';
  }
  
   createInvoice(String eventId,current)async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var planData =pref.getString('planData')??'';
    var plans = jsonDecode(planData);
    int serialNo = 0;
    var data = await FirebaseFirestore.instance.collection('InvoiceVenue').get();
    var booingList = await FirebaseFirestore.instance.collection('Bookings').get();
    var venueDetail = await FirebaseFirestore.instance.collection('Club').doc(uid()).get();
    var checkInOut = await FirebaseFirestore.instance.collection('CheckInOut').doc(eventId).get();
    var tax = await FirebaseFirestore.instance.collection('TaxCharges').doc('adminTax').get();
    var companyDetail = await FirebaseFirestore.instance.collection('CompanyDetail').doc('adminTax').get();

    if(booingList.docs.isNotEmpty){
      print('check event id is ${data.docs.where((element) => element.id.toString()== eventId,).isNotEmpty}');
      if(data.docs.where((element) => element.id.toString()== eventId,).isNotEmpty==false){
        var venue = venueDetail.data() as Map<String,dynamic>;
        var qrScan =checkInOut.data()==null?{}: checkInOut.data() as Map<String,dynamic>;
        var taxPercentage = tax.data() as Map<String,dynamic>;
        var company = companyDetail.data() as Map<String,dynamic>;
        double entryPrice = 0.0;
        double tablePrice = 0.0;
        List bookingEntry = [];


        for(var doc in booingList.docs){
          if(doc['eventID'].toString() == eventId.toString() &&
              (int.tryParse(doc['totalEntranceCount']?.toString() ?? '0') ?? 0) > 0){

            if(doc.data().containsKey('type')== false){
              if(doc.data()['amount'].toString() =='0'){
                for(var check in qrScan['checkInList'] as List){
                  if(doc.data()['bookingID'].toString() == check['bookingId'].toString()){
                    bookingEntry.add(doc);
                  }
                }

              }else{
                bookingEntry.add(doc);
              }

            }else{
              if(doc['type'].toString() != 'filler'){
                if(doc.data()['amount'].toString() =='0'){
                  for(var check in qrScan['checkInList'] as List){
                    if(doc.data()['bookingID'].toString() == check['bookingId'].toString()){
                      bookingEntry.add(doc);
                    }
                  }
                }else{
                  bookingEntry.add(doc);
                }
              }
            }
          }
        }

        //  bookingEntry = booingList.docs
        //     .where((doc) =>
        // doc['eventID'].toString() == eventId.toString() &&
        //     (int.tryParse(doc['totalEntranceCount']?.toString() ?? '0') ?? 0) > 0).
        // where((element) => element.data().containsKey('type')== false,).
        // where((element) =>element.data().containsKey('type')== true && element['type'].toString() !='filler' ,)
        //     .toList();

        List bookingTable = [];

        for(var doc in booingList.docs){
          if (doc['eventID'].toString() == eventId.toString() &&
              (int.tryParse(doc['totalTableCount']?.toString() ?? '0') ?? 0) > 0) {
            if(doc.data()['amount'].toString() =='0'){
              for(var check in qrScan['checkInList'] as List){
                if(doc.data()['bookingID'].toString() == check['bookingId'].toString()){
                  bookingTable.add(doc);
                }
              }
            }else{
              bookingTable.add(doc);
            }
          }

        }

        // List bookingTable = booingList.docs
        //     .where((doc) =>
        // doc['eventID'].toString() == eventId.toString() &&
        //     (int.tryParse(doc['totalTableCount']?.toString() ?? '0') ?? 0) > 0)
        //     .toList();

        List fillerCouponList =[];

        for(var doc in booingList.docs){
          if(doc['eventID'].toString() == eventId.toString() &&
              (int.tryParse(doc['totalEntranceCount']?.toString() ?? '0') ?? 0) > 0){
            if(doc.data().containsKey('type')== true){
              if(doc['type'].toString() == 'filler'){
                print('yes check it is');
                fillerCouponList.add(doc);
              }
            }
          }
        }


        // List fillerCouponList = booingList.docs
        //     .where((doc) =>
        // doc['eventID'].toString() == eventId.toString() && doc.data().containsKey('type') &&
        //     doc['type'].toString()=='filler')
        //     .toList();

        List fillerList = [];
        for(var fillerContent in fillerCouponList){
          // print('check coupon apply ${fillerContent['bookingId']}');
          if(qrScan.isEmpty){
            fillerContent = [];
            return;
          }
          for(var check in qrScan['checkInList'] as List){
            if(fillerContent['bookingID'].toString() == check['bookingId'].toString()){
              print('check booking id is ');
              fillerList.add(fillerContent);
            }
          }
        }

        print('check bookin entry ${bookingTable.length}');
        print('check bookin entry ${bookingEntry.length}');

        for (var price in bookingEntry) {
          print('amoutn is ${price['amount']?.toString() }');
          final amount = double.tryParse(price['amount']?.toString() ?? '0') ?? 0;
          entryPrice += amount;
        }

        for (var price in bookingTable) {
          final amount = double.tryParse(price['amount']?.toString() ?? '0') ?? 0;
          tablePrice += amount;
        }

        print('Total Entry Price: $entryPrice');
        print('Total Table Price: $tablePrice');


        debugPrint('venue Detail is ${venue}');
        serialNo = data.docs
            .map((e) => e["serialNo"] as int)
            .reduce((a, b) => a > b ? a : b);

        await FirebaseFirestore.instance.collection('InvoiceVenue').doc(eventId).set({
          "serialNo":serialNo+current,
          'invoiceNumber':'TI${DateTime.now().year%100}${(DateTime.now().year+1) % 100}${getStateCode(venueDetail['state']??'')}${venueDetail.data()!.containsKey('sq')?venueDetail['sq']??'':''}/${serialNo+current}',
          "dateOfIssue":DateTime.now(),
          "customerGst":venue['gst']??'',
          "timeOfIssue:":'${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}',
          "stateCode":getStateCode(venue['state']??''),
          "customerName":venue['clubName']??'',
          "customerEmail":venue['email']??'',
          "customerAddress":'${venue['address']??''},${venue['area']??''} ${venue['city']??''} ${venue['state']??''} }' ,
          "invoiceIssuedBy":'',
          "GSTIN":company['gst']??'',
          "pAN":company['pan']??'',
          "cgst":taxPercentage['cgst'],
          "sgst": taxPercentage['sgst'],
          "igst": taxPercentage['igst'],
          "ugst":taxPercentage['ugst'],
          "convenienceFees":taxPercentage['convenienceFees'],
          "platForm":taxPercentage['platForm'],
          'gateWayCharge':taxPercentage['gateWayCharge'],
          "companyStateCode":company['stateCode']??'',
          "companyAddress":company['address']??'',
          "productDetail":[
            {
              "type":"No Of QR Scans",
              "noOfScan": qrScan.isEmpty?0:(qrScan['checkInList'] as List).length,
              "qrCharge":plans['perQrScan']??'',
              "price":plans['perQrScan']??'',
              "hsn":taxPercentage['hsn']??'',

            },
            {
              "type":"Commission On Entry",
              "noOfScan": bookingEntry.length,
              "qrCharge":plans['entryManagement']==null?'':plans['entryManagement']['percentageOfEntry']??'',
              "price": entryPrice,
              "hsn":taxPercentage['hsn']??''
            },
            {
              "type":"Commission On Table",
              "noOfScan": bookingTable.length,
              "qrCharge":plans['tableManagement']==null?'':plans['tableManagement']['percentageOfTable']??'',
              "price": tablePrice,
              "hsn":taxPercentage['hsn']??''
            }, {
              "type":"Commission On Filler",
              "noOfScan": (fillerList.isEmpty?0:fillerList.length),
              "qrCharge":0,
              "price": 800  ,
              "hsn":taxPercentage['hsn']??''
            }
          ],
          // "Entry":{
          //   "noOfScan": bookingEntry.length,
          //   "qrCharge":plans['entryManagement']==null?'':plans['entryManagement']['percentageOfEntry']??'',
          //   "price": entryPrice * entryPercent,
          //   "hsn":taxPercentage['hsn']??''
          // },
          // "Table":{
          //   "noOfScan": bookingTable.length,
          //   "qrCharge":plans['tableManagement']==null?'':plans['tableManagement']['percentageOfTable']??'',
          //   "price": tablePrice * tablePercent,
          //   "hsn":taxPercentage['hsn']??''
          // }


        });
      }
    }else{
      return false;
    }


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUpcomingMonthEventData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "",showBack:true),
      body: eventList()
    );
  }

  Widget eventList(){
    return ValueListenableBuilder(
      valueListenable: isLoadingBooking,
      builder: (context, bool isLoading, child) {
        if(isLoading){
          return Center(
            child: CircularProgressIndicator(color: Colors.orangeAccent,),
          );
        }
        if(clubBookingList.isEmpty){
          return Center(
            child:  Text(
              'No Bookings found',
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 60.sp,
              ),
            ),
          );
        }
        List past = clubBookingList.where((e) {
          DateTime bookingDate = e['date'].toDate();
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);
          return bookingDate.isBefore(today);
        }).toList();
        if(past.isEmpty){
          return Center(
            child:  Text(
              'No Bookings found',
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 60.sp,
              ),
            ),
          );
        }

        past.sort((a, b) => b['date'].toDate().compareTo(a['date'].toDate()));

        return  ValueListenableBuilder(
          valueListenable: plan,
          builder: (context, bool isPlan, child) {
            if(isPlan ==false){
              return Center(
                child:  Text(
                  'No Plan found',
                  style: GoogleFonts.ubuntu(
                    color: Colors.white,
                    fontSize: 60.sp,
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: past.length,
              itemBuilder: (BuildContext context, int index) {
                QueryDocumentSnapshot<Object?>? data =
                past[index];
                DateTime date = data?['date'].toDate();
              createInvoice(data!.id,index+1);
                return
                  GestureDetector(
                      onTap: () {
                        print('event id check ${data.id}');
                        fetchInvoiceData(data.id);
                        // Get.to(
                        //   PdfPreviewPage(
                        //     eventId: data.id,
                        //   ),
                        // );
                        // Get.to(
                        //   BookingInfo(
                        //     eventName: data!['title'],
                        //     eventId: data.id,
                        //     eventType: event,
                        //   ),
                        // );
                      },
                      child: SizedBox(
                        width: Get.width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Expanded(
                            //   child: SizedBox(
                            //       child: Center(
                            //           child: CachedNetworkImage(
                            //             imageUrl: data[''],
                            //             fit: BoxFit.fill,
                            //           ))),
                            // ),
                            Expanded(
                              child: SizedBox(
                                  child: Center(
                                      child: Text(
                                        "${data!["title"]}".toString().capitalizeFirstOfEach,
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
                            Expanded(
                              child: SizedBox(
                                  child: Center(
                                      child: Text(
                                        "Invoice",
                                        style: GoogleFonts.ubuntu(color: Colors.orangeAccent),
                                      ))),
                            ),
                          ],
                        ).paddingSymmetric(vertical: 60.h),
                      )
                  );
              },
            );
          },

        );
      },
    );
  }

  ValueNotifier<Map<String,dynamic>?> invoice = ValueNotifier(null);

  fetchInvoiceData(String eventId)async{
    var data= await FirebaseFirestore.instance.collection('InvoiceVenue').doc(eventId).get();
    // if(data.exists) {
      var invoiceContent = data.data() as Map<String, dynamic>;
      invoice.value = invoiceContent;
      if (invoice.value != null) {
        generateInvoicePdf(invoice.value as Map<String, dynamic>);
      }
    // }else{
    //   Fluttertoast.showToast(msg: 'No bookings are available for this event.');
    // }
  }


  Future<Uint8List> generateInvoicePdf(Map<String, dynamic> value) async {
    final pdf = pw.Document();
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/invoiceLogo.png')).buffer.asUint8List(),
    );


    final productList = value['productDetail'] as List;

    // Calculate totals
    double totalAmount = 0;
    for (var item in productList) {
      double taxable = item['type'].toString() == 'No Of QR Scans'
          ? ((double.tryParse(item['qrCharge'].toString()) ?? 0) *
          (double.tryParse(item['noOfScan'].toString()) ?? 0))
          : ((double.tryParse(item['price'].toString()) ?? 0) -
          ((double.tryParse(item['price'].toString()) ?? 0) *
              ((double.tryParse(item['qrCharge'].toString()) ?? 0) / 100)));
      totalAmount += taxable;
    }

    double cgst = totalAmount * ((double.tryParse(value['cgst'].toString()) ?? 0) / 100);
    double igst = totalAmount * ((double.tryParse(value['igst'].toString()) ?? 0) / 100);
    double sgst = totalAmount * ((double.tryParse(value['sgst'].toString()) ?? 0) / 100);
    double gst = cgst + sgst;
    double totalWithTax = totalAmount + gst;
    double totalTax =  cgst +igst+sgst;

    String amountInWords = NumberToWordsEnglish.convert(totalWithTax.round());
    // NumberToWord().convert('en-in', totalWithTax.round());

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(20),
          buildBackground: (context) => pw.Center(
            child: pw.Opacity(
              opacity: 0.1,
              child: pw.Image(logo, width: 400),
            ),
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 40),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(logo, width: 80, height: 80),
                pw.Center(
                  child: pw.Text('PARTYON ENTERTAINMENT PVT. LTD.',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Center(
                  child: pw.Text('',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ),
              ]
          ),
          pw.SizedBox(height: 30),

          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Invoice No : ${value['invoiceNumber'] ?? ''}", style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.normal)),

                    pw.Text("Customer GSTIN :- ${value['customerGst'] ?? ''}", style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 5),
                    pw.Text("State Code : ${value['stateCode'] ?? ''}", style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 5),
                    pw.Text("Customer Name : ${value['customerName'] ?? ''}", style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 5),
                    pw.Text("Customer Email : ${value['customerEmail'] ?? ''}", style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 5),
                    pw.Text("Customer Address : ${value['customerAddress'] ?? ''}", style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              pw.SizedBox(width: 20), // optional spacing between columns
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 5),
                    pw.Text(
                        "Date of issue : ${DateFormat('dd-MM-yyyy').format((value['dateOfIssue'] as Timestamp).toDate())}", style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.normal)),
                    pw.SizedBox(height: 5),
                    pw.Text("GSTIN : ${value['GSTIN'] ?? ''}", style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 5),
                    pw.Text("PAN : ${value['pAN'] ?? ''}", style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 5),
                    pw.Text("State Code : ${value['companyStateCode'] ?? ''}", style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 5),
                    pw.Text("Company Address : ${value['companyAddress'] ?? ''}", style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 30),
          pw.Table(
            // No borders
            border: pw.TableBorder(), // or just remove this line
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _headerCell("Product Description"),
                  _headerCell("VALUE ON\nCOMMISSION / SCAN"),
                  _headerCell("HSN CODE"),
                  _headerCell("Qty"),
                  _headerCell("Price"),
                  _headerCell("Discount"),
                  _headerCell("Commission Amount"),
                  _headerCell("Total"),
                ],
              ),
              ...productList.map((item) {
                double taxable = item['type'].toString() == 'No Of QR Scans'
                    ? ((double.tryParse(item['qrCharge'].toString()) ?? 0) *
                    (double.tryParse(item['noOfScan'].toString()) ?? 0))
                    : (
                    // double.tryParse(item['price'].toString()) ?? 0) -
                    ((double.tryParse(item['price'].toString()) ?? 0) *
                        ((double.tryParse(item['qrCharge'].toString()) ?? 0) / 100)));
                  double totalAmount = item['type'].toString() == 'No Of QR Scans'
                      ? ((double.tryParse(item['qrCharge'].toString()) ?? 0) *
                      (double.tryParse(item['noOfScan'].toString()) ?? 0))
                      : item['type'].toString() == 'Commission On Filler'
                      ? (double.tryParse(item['price'].toString()) ?? 0) * (double.tryParse(item['noOfScan'].toString()) ?? 0)
                      :((double.tryParse(item['price'].toString()) ?? 0) -
                      ((double.tryParse(item['price'].toString()) ?? 0) *
                          ((double.tryParse(item['qrCharge'].toString()) ?? 0) / 100)));
                return pw.TableRow(
                  children: [
                    _dataCell("${item['type']}"),
                    _dataCell("${item['qrCharge']}"),
                    _dataCell("${item['hsn'] ?? ''}"),
                    _dataCell("${item['noOfScan'] ?? '0'}"),
                    _dataCell("${item['price'] ?? '0'}"),
                    _dataCell("0"),
                    _dataCell(taxable.toStringAsFixed(2)),
                    _dataCell(totalAmount.toStringAsFixed(2)),
                  ],
                );
              }).toList(),
            ],
          ),

          pw.SizedBox(height: 30),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                    children: [
                      pw.Text("Sub Total : ${totalAmount.toStringAsFixed(2)}"),
                      pw.SizedBox(height: 10),
                      pw.Text("Total Amount before Tax : ${totalAmount.toStringAsFixed(2)}"),
                      pw.SizedBox(height: 10),
                      pw.Text("Add. CGST : @ ${value['cgst']}% : ${cgst.toStringAsFixed(2)}"),
                      pw.SizedBox(height: 10),
                      pw.Text("Add. SGST : @ ${value['sgst']}% : ${sgst.toStringAsFixed(2)}"),
                      pw.SizedBox(height: 10),
                      pw.Text("Total Amount : GST : ${gst.toStringAsFixed(2)}"),
                      pw.SizedBox(height: 10),
                      pw.Text("Total Amount after Tax : ${totalWithTax.toStringAsFixed(2)}"),
                      pw.SizedBox(height: 10),
                    ]
                )
              ]
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Percentage"),
                  pw.SizedBox(height: 5),
                  pw.Text("Amount In Words"),
                ],
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("CGST"),
                  pw.SizedBox(height: 5),
                  pw.Text("${cgst.toStringAsFixed(2) ?? '0'}"),
                  pw.SizedBox(height: 5),
                  // pw.Text(NumberToWordsEnglish.convert(int.parse(value['cgst'] ?? '0'))),
                ],
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("SGST"),
                  pw.SizedBox(height: 5),
                  pw.Text("${sgst.toStringAsFixed(2 )?? '0'}"),
                  pw.SizedBox(height: 5),
                  // pw.Text(NumberToWordsEnglish.convert(int.parse(value['sgst'] ?? '0'))),
                ],
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("IGST"),
                  pw.Text("${igst.toStringAsFixed(2) ?? '0'}"),
                  pw.SizedBox(height: 5),
                  // pw.Text(NumberToWordsEnglish.convert(int.parse(value['igst'] ?? '0'))),
                ],
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("UT/CESS"),
                  pw.Text("0"),
                  pw.SizedBox(height: 5),
                  // pw.Text(NumberToWordsEnglish.convert(0)),

                ],
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Total"),
                  pw.Text("${totalTax}"),
                  pw.SizedBox(height: 5),
                  // pw.Text(
                  //     NumberToWordsEnglish.convert(
                  //         (double.tryParse(value['cgst'] ?? '0') ?? 0) +
                  //             (double.tryParse(value['sgst'] ?? '0') ?? 0) +
                  //             (double.tryParse(value['igst'] ?? '0') ?? 0)
                  //     )
                  // ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
              "Total amount after tax (in words): ${amountInWords.toUpperCase()} ONLY"),
          pw.SizedBox(height: 20),
          pw.Text("Note:"),
          pw.Text("1. Certified that the particulars given above are true and correct"),
          pw.Text("2. Raised invoice to be cleared within 7 days of issue date"),
          pw.SizedBox(height: 30),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text("Authorised signatory"),
            ],
          ),
        ],
      ),
    );
    final pdfPreview = PdfPreview(
      build: (format) => pdf.save(),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
    return pdf.save();
  }

  pw.Widget _headerCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
  );

  pw.Widget _dataCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(text,
        textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9)),
  );
}