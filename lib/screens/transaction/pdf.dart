import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:number_to_words_english/number_to_words_english.dart';


class PdfPreviewPage extends StatefulWidget {
  final String? eventId;

  const PdfPreviewPage({Key? key, this.eventId}) : super(key: key);

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(initialScrollOffset: 0.0);
    fetchInvoiceData();
  }

  ValueNotifier<Map<String,dynamic>?> invoice = ValueNotifier(null);
  
  fetchInvoiceData()async{
   var data= await FirebaseFirestore.instance.collection('InvoiceVenue').doc(widget.eventId).get();
    var invoiceContent = data.data() as Map<String,dynamic>;
    invoice.value = invoiceContent;
    if(invoice.value !=null){
      generateInvoicePdf(invoice.value as Map<String,dynamic> );
    }
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
    double sgst = totalAmount * ((double.tryParse(value['sgst'].toString()) ?? 0) / 100);
    double gst = cgst + sgst;
    double totalWithTax = totalAmount + gst;

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
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Invoice No : ${value['invoiceNumber'] ?? ''}", style: pw.TextStyle(
              fontSize: 14, fontWeight: pw.FontWeight.normal)),
              pw.Text(
                  "Date of issue : ${DateFormat('dd-MM-yyyy').format((value['dateOfIssue'] as Timestamp).toDate())}", style: pw.TextStyle(
              fontSize: 14, fontWeight: pw.FontWeight.normal)),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Customer GSTIN :- ${value['customerGst'] ?? ''}", style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.normal)),
                  pw.SizedBox(height: 5),
                  pw.Text("State Code : ${value['stateCode'] ?? ''}", style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.normal)),
                  pw.SizedBox(height: 5),
                  pw.Text("Customer Name : ${value['customerName'] ?? ''}", style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.normal)),
                  pw.SizedBox(height: 5),
                  pw.Text("Customer Email : ${value['customerEmail'] ?? ''}", style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.normal)),
                  pw.SizedBox(height: 5),
                  pw.Text("Customer Address : ${value['customerAddress'] ?? ''}", style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.normal)),
                ],
              ),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Invoice issued by :${DateFormat('dd-MM-yyyy').format((value['dateOfIssue'] as Timestamp).toDate())}", style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.normal)),
                  pw.SizedBox(height: 5),
                  pw.Text("GSTIN : ${value['GSTIN']}", style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.normal)),
                  pw.SizedBox(height: 5),
                  pw.Text("PAN : ${value['pAN'] ?? ''}", style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.normal)),
                  pw.SizedBox(height: 5),
                  pw.Text("State code : ${value['companyStateCode']}", style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.normal)),
                  pw.SizedBox(height: 5),
                  pw.Text("Company Address : ${value['companyAddress'] ?? ''}", style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.normal)),
                ],
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
                  _headerCell("Taxable Amount"),
                  _headerCell("Total"),
                ],
              ),
              ...productList.map((item) {
                double taxable = item['type'].toString() == 'No Of QR Scans'
                    ? ((double.tryParse(item['qrCharge'].toString()) ?? 0) *
                    (double.tryParse(item['noOfScan'].toString()) ?? 0))
                    : ((double.tryParse(item['price'].toString()) ?? 0) -
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
                    _dataCell(taxable.toStringAsFixed(2)),
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
                  pw.Text("${value['cgst'] ?? '0'}"),
                  pw.SizedBox(height: 5),
                  pw.Text(NumberToWordsEnglish.convert(int.parse(value['cgst'] ?? '0'))),
                ],
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("SGST"),
                  pw.SizedBox(height: 5),
                  pw.Text("${value['sgst'] ?? '0'}"),
                  pw.SizedBox(height: 5),
                  pw.Text(NumberToWordsEnglish.convert(int.parse(value['sgst'] ?? '0'))),
                ],
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("IGST"),
                  pw.Text("${value['igst'] ?? '0'}"),
                  pw.SizedBox(height: 5),
                  pw.Text(NumberToWordsEnglish.convert(int.parse(value['igst'] ?? '0'))),
                ],
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("UT/CESS"),
                  pw.Text("0"),
                  pw.SizedBox(height: 5),
                  pw.Text(NumberToWordsEnglish.convert(0)),

                ],
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  
                  pw.Text("Total"),
                  pw.Text("${(double.tryParse(value['cgst'] ?? '0') ?? 0) + (double.tryParse(value['sgst'] ?? '0') ?? 0) +(double.tryParse(value['igst'] ?? '0') ?? 0)}"),
                  pw.SizedBox(height: 5),
                  pw.Text(
                      NumberToWordsEnglish.convert(
                          (double.tryParse(value['cgst'] ?? '0') ?? 0) +
                              (double.tryParse(value['sgst'] ?? '0') ?? 0) +
                              (double.tryParse(value['igst'] ?? '0') ?? 0)
                      )
                  ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder(
        valueListenable: invoice,
        builder: (context,Map<String,dynamic>? value, child) {
          if(value == null){
            return Center(child: Text('No Data available',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Colors.white),),);
          }

          // generateInvoicePdf(value);
          return Container();
          //   Stack(
          //   children: [
          //     Center(
          //       child: Container(
          //         height: 1.sw,
          //         width: 1.sh,
          //         decoration: BoxDecoration(
          //           image: DecorationImage(image: AssetImage('assets/invoiceLogo.png'),alignment: Alignment.center,opacity: 0.4)
          //         ),
          //       ),
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               Image.asset('assets/invoiceLogo.png',height: 100,width: 100,),
          //               Text('PARTYON \nENTERTAINMENT \nPVT. LTD.',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.orangeAccent,fontSize: 20),
          //               textAlign: TextAlign.end,)
          //             ],
          //           ),
          //           SizedBox(height: 10,),
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               Expanded(child: rowWidget('Invoice Number: ','${value['invoiceNumber']}')),
          //               rowWidget('Issue: ','${DateFormat('dd-MM-yyyy').format((value['dateOfIssue'] as Timestamp).toDate())}'),
          //             ],
          //           ),
          //
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               Expanded(child: rowWidget('State Code: ','${value['stateCode']}')),
          //               rowWidget('Issue Time: ','${value['timeOfissue']??''}'),
          //             ],
          //           ),
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               Expanded(child: rowWidget('Customer Name: ','${value['customerName']}')),
          //               rowWidget('GSTIN : ','${value['GSTIN']??''}'),
          //             ],
          //           ),
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               Expanded(child: rowWidget('Customer Email: ','${value['customerEmail']}')),
          //               rowWidget('PAN : ','${value['pAN']??''}'),
          //             ],
          //           ),
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               Expanded(child: rowWidget('Customer Address: ','${value['customerAddress']}')),
          //               rowWidget('State Code : ','${value['companyStateCode']??''}'),
          //             ],
          //           ),
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.end,
          //             children: [
          //               rowWidget('Company Address : ','${value['companyAddress']??''}'),
          //             ],
          //           ),
          //           SizedBox(height: 30,),
          //           SizedBox(
          //             width: Get.width,
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               children: [
          //                 titleWidget('Product Description'),
          //                 titleWidget('VALUE ON COMMISION / SCAN'),
          //                 titleWidget('HSN CODE'),
          //                 titleWidget('Qty'),
          //                 titleWidget('Price'),
          //                 titleWidget('Discount'),
          //                 titleWidget('Taxable '),
          //                 titleWidget('Total '),
          //
          //               ],
          //             ).paddingAll(20.h),
          //           ),
          //
          //           ListView.builder(
          //             physics: const NeverScrollableScrollPhysics(),
          //             shrinkWrap: true,
          //             itemCount: (value['productDetail'] as List).length,
          //             itemBuilder: (BuildContext context, int index) {
          //               var data =
          //               (value['productDetail'] as List)[index];
          //               return Container(
          //                 height: 300.h,
          //                 width: Get.width,
          //                 decoration: BoxDecoration(
          //                   color: Colors.black,
          //                   borderRadius: BorderRadius.circular(20),
          //                 ),
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                   children: [
          //                     Expanded(
          //                       child: SizedBox(
          //                         child: Center(
          //                           child: Text(
          //                             data['type'].toString(),
          //                             style: GoogleFonts.ubuntu(
          //                               color: Colors.white,
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                     Expanded(
          //                       child: SizedBox(
          //                         child: Center(
          //                           child: Text(
          //                             "${data["qrCharge"]}",
          //                             style: GoogleFonts.ubuntu(
          //                               color: Colors.white,
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                     Expanded(
          //                       child: SizedBox(
          //                         child: Center(
          //                           child: Text(
          //                             "${data?["hsn"]}",
          //                             style: GoogleFonts.ubuntu(
          //                               color: Colors.white,
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                     Expanded(
          //                       child: SizedBox(
          //                         child: Center(
          //                           child:  Text(
          //                             data['noOfScan']??'',
          //                             style: GoogleFonts.ubuntu(
          //                               color: Colors.red,
          //                             ),
          //                           )
          //
          //
          //                         ),
          //                       ),
          //                     ),
          //                     Expanded(
          //                       child: SizedBox(
          //                         child: Center(
          //                           child:  Text(
          //                             data['price']??'',
          //                             style: GoogleFonts.ubuntu(
          //                               color: Colors.red,
          //                             ),
          //                           )
          //
          //
          //                         ),
          //                       ),
          //                     ),
          //                     Expanded(
          //                       child: SizedBox(
          //                         child: Center(
          //                           child:  Text(
          //                             '0',
          //                             style: GoogleFonts.ubuntu(
          //                               color: Colors.red,
          //                             ),
          //                           )
          //
          //
          //                         ),
          //                       ),
          //                     ),
          //                     Expanded(
          //                       child: SizedBox(
          //                         child: Center(
          //                           child:  Text(
          //                             '0',
          //                             style: GoogleFonts.ubuntu(
          //                               color: Colors.red,
          //                             ),
          //                           )
          //                         ),
          //                       ),
          //                     ),
          //                     Expanded(
          //                       child: SizedBox(
          //                         child: Center(
          //                           child:  Text(
          //                             '0',
          //                             style: GoogleFonts.ubuntu(
          //                               color: Colors.red,
          //                             ),
          //                           )
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ).paddingAll(20.h);
          //             },
          //           )
          //
          //
          //
          //
          //         ],
          //       ),
          //     ),
          //   ],
          // );
        },

      ),
    );
  }
  Widget rowWidget(String title,String subtitle){
    return Row(
      children: [
        Text(title,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Colors.white),),
        Text(subtitle,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Colors.white),),

      ],
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
}