import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class MessagePreviewBottomSheet extends StatefulWidget {
  final String? couponCode;
  final String validFrom;
  final String validUntil;
  final String couponCategory;
  final String discountPercentage;
  final String eventName;
  final String eventData;
  final String imageUrl;
  final String eventUrl;
  final String? tableCoupon;
  final String? type;

  const MessagePreviewBottomSheet(
      {super.key,
      this.couponCode,
      required this.validFrom,
      required this.validUntil,
      required this.couponCategory,
      required this.eventName,
        required this.discountPercentage,
      required this.eventUrl,
      required this.eventData,
      required this.imageUrl,
      this.tableCoupon, this.type});

  @override
  State<MessagePreviewBottomSheet> createState() =>
      _MessagePreviewBottomSheetState();
}

class _MessagePreviewBottomSheetState extends State<MessagePreviewBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xff6E0E0A),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    Text(
                      'Share the Coupon Code 🎁',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 52.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 28.h,
                    ),
                    Text(
                      'Event Name: \'${widget.eventName}\' \n Event Date: ${widget.eventData}?. \n \n Share this exclusive coupon code and get ready to dive into the Partyon experience !',
                      style: TextStyle(color: Colors.white, fontSize: 40.sp),
                    ),
                    SizedBox(
                      height: 28.h,
                    ),
                    if (widget.type.toString() == 'entry')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              widget.couponCode!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48.sp,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),

                    if (widget.type.toString() == 'table')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              widget.tableCoupon == 'null'?'':widget.tableCoupon.toString(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48.sp,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 10,),
                    SizedBox(
                      width: 1.sw,
                      height: 40,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(

                          backgroundColor: Colors.orangeAccent
                        ),
                        onPressed: () async {
                          String coupon = widget.type.toString() == 'table'
                              ? widget.tableCoupon ?? ''
                              : widget.couponCode ?? '';
                          String message = '';

                          if(widget.type.toString() == 'filler'){
                             message =
                                '🎉 Get Ready to Party Like Never Before! 🎉\n🥂🥂 GRAB YOUR FREE DRINKS 🥂🥂\nThe "${widget.eventName}" is dropping on ${widget.eventData}, and you\'re on the list of fun seekers! \n\n'
                                '💥 Use your exclusive code: *$coupon*\n'
                            // '${widget.tableCoupon != null ? '🪑 Table Management: ${widget.tableCoupon}\n' : ''}'
                                '✅ Flat discount on ${widget.type.toString() == 'table'?'Table Reservation':'Entry Booking '} ${widget.discountPercentage}%\n'
                                '📅 Valid from: ${widget.validFrom}\n'
                                '⏰ Expires: ${widget.validUntil} – Don’t miss out!\n\n'
                                '💃 Unlock your pass now & join the celebration:\n'
                                '🔗 ${widget.eventUrl}\n\n'
                                'Let the beats drop, the lights flash, and the good times roll.\n'
                                '#PartyOn — Where every night is unforgettable.';
                          }else{
                           message =
                              '🎉 Get Ready to Party Like Never Before! 🎉\nThe "${widget.eventName}" is dropping on ${widget.eventData}, and you\'re on the list of fun seekers! \n\n'
                              '💥 Use your exclusive code: *$coupon*\n'
                              // '${widget.tableCoupon != null ? '🪑 Table Management: ${widget.tableCoupon}\n' : ''}'
                              '✅ Flat discount on ${widget.type.toString() == 'table'?'Table Reservation':'Entry Booking '} ${widget.discountPercentage}%\n'
                              '📅 Valid from: ${widget.validFrom}\n'
                               '⏰ Expires: ${widget.validUntil} – Don’t miss out!\n\n'
                               '💃 Unlock your pass now & join the celebration:\n'
                                '🔗 ${widget.eventUrl}\n\n'
                                'Let the beats drop, the lights flash, and the good times roll.\n'
                                '#PartyOn — Where every night is unforgettable.';
                          }
                          final whatsappUrl =
                              "https://wa.me/?text=$message%20${widget.imageUrl}";
                          shareImageAndTextToWhatsApp(imageUrl: widget.imageUrl, message: message);
                        },
                        label: Text('Whatsapp Share'),
                        icon: Icon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                        ),
                      ),
                    )
                  ]),
            )));
  }



  Future<void> shareImageAndTextToWhatsApp({
    required String imageUrl,
    required String message,
    bool toBusiness = false, // true for WhatsApp Business
  }) async {
    try {
      // 1. Ask storage permission (Android 13+)
      // if (Platform.isAndroid) {
      //   final status = await Permission.photos.request();
      //   if (!status.isGranted) {
      //     print("Permission not granted");
      //     return;
      //   }
      // }

      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shared_image.jpg');
      await file.writeAsBytes(bytes);

      const platform = MethodChannel('custom.whatsapp.share');
      await platform.invokeMethod('shareToWhatsApp', {
        'text': message,
        'imagePath': file.path,
        'isBusiness': toBusiness,
      });
    } catch (e) {
      print("Error sharing to WhatsApp: $e");
    }
  }
}
