import 'dart:io';

import 'package:club/screens/organiser/event_management/barter_promotion_detail.dart';
import 'package:club/utils/app_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class InfluStartPromotion extends StatefulWidget {
  final dynamic data;
  const InfluStartPromotion({super.key, this.data});

  @override
  State<InfluStartPromotion> createState() => _InfluStartPromotionState();
}

class _InfluStartPromotionState extends State<InfluStartPromotion> {
  MethodChannel channel = const MethodChannel('instagramshare');

  dynamic mainData;

  bool showPromotionDropdowns = false;
  bool showPromotionalImage = false, showPostsImage = false, showReelImage = false;

  String type = '';
  File? capturedFile;

  Future<void> shareToInstagram(String filePath, String fileType) async {
    try {
      await channel.invokeMethod('share', {'filePath': filePath, 'fileType': fileType});
    } catch (e) {
      print('Error sharing to Instagram: $e');
    }
  }


  Future<void> shareMultipleToInstagram(List<String> filePaths) async {
    try {
      await channel.invokeMethod('shareMultiple', {'filePaths': filePaths});
    } catch (e) {
      print('Error sharing to Instagram: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mainData = widget.data;
    setState(() {});
  }

  Future<String> downloadFile(String url, String fileName, {String defaultExtension = 'jpg'}) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName.$defaultExtension'; // Add a default extension if missing

      // Force content type detection and append extension dynamically
      final response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
      final fileType = response.headers['content-type']?.first ?? 'application/octet-stream';

      String actualExtension;
      if (fileType.startsWith('image')) {
        actualExtension = 'jpg'; // You can refine this further
      } else if (fileType.startsWith('video')) {
        actualExtension = 'mp4'; // Default for videos
      } else {
        actualExtension = defaultExtension; // Fallback
      }

      // Update file path with the detected extension
      final updatedFilePath = '${dir.path}/$fileName.$actualExtension';

      // Write the file
      final file = File(updatedFilePath);
      await file.writeAsBytes(response.data);

      return updatedFilePath;
    } catch (e) {
      print('Error downloading file: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Start Promotion"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   if(!((mainData['promotionImages'] == null || mainData['promotionImages'].isEmpty) && (mainData['postImages'] == null || mainData['postImages'].isEmpty) && (mainData['reelsImages'] == null || mainData['reelsImages'].isEmpty)))
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 20),
                       child: InkWell(
                         overlayColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
                         onTap: () {
                           setState(() {
                             showPromotionDropdowns = !showPromotionDropdowns;
                           });
                         },
                         child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                           Text(
                             "Promotional Data (to be used)",
                             style: GoogleFonts.ubuntu(
                                 fontWeight: FontWeight.bold,
                                 fontSize: 20,
                                 color: Colors.orange),
                           ),
                           IconButton(
                               onPressed: () {
                                 setState(() {
                                   showPromotionDropdowns = !showPromotionDropdowns;
                                 });
                               },
                               icon: Icon(
                                 showPromotionDropdowns == false
                                     ? Icons.arrow_drop_down
                                     : Icons.arrow_drop_up,
                                 color: Colors.white,
                               ))
                         ]),
                       ),
                     ),
                   if(showPromotionDropdowns)
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.stretch,
                         children: [
                           if(mainData['promotionImages'] != null && mainData['promotionImages'].isNotEmpty)
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Row(children: [
                                   Text(
                                     "Story",
                                     style: GoogleFonts.ubuntu(
                                         fontSize: 18,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.orange),
                                   ),
                                   IconButton(
                                       onPressed: () {
                                         setState(() {
                                           showPromotionalImage = !showPromotionalImage;
                                         });
                                       },
                                       icon: Icon(
                                         showPromotionalImage == false
                                             ? Icons.arrow_drop_down
                                             : Icons.arrow_drop_up,
                                         color: Colors.white,
                                       ))
                                 ]),
                                 GestureDetector(
                                   onTap: () async{
                                     List<String> localPaths = [];
                                     for (var i = 0; i < mainData['promotionImages'].length; i++) {
                                       final fileName = 'file_$i.${mainData['promotionImages'][i].split('.').last}';
                                       final localPath = await downloadFile(mainData['promotionImages'][i], fileName);
                                       localPaths.add(localPath);
                                     }
                                     shareMultipleToInstagram(localPaths);
                                   },
                                   child: Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                     decoration: BoxDecoration(
                                       color: Colors.green,
                                       borderRadius: BorderRadius.circular(5)
                                     ),
                                       child: const Text("Share", style: TextStyle(color: Colors.white)),
                                   ),
                                 ),
                               ],
                             ),
                           if(showPromotionalImage && mainData['promotionImages'] != null && mainData['promotionImages'].isNotEmpty)
                             Center(
                               child: SizedBox(
                                 width: kIsWeb ? 300 : null,
                                 child: AspectRatio(
                                   aspectRatio: 9/16,
                                   child: PageView.builder(
                                     reverse: false,
                                     scrollDirection: Axis.horizontal,
                                     itemCount: mainData['promotionImages'].length,
                                     itemBuilder: (context, index) {
                                       Uri url = Uri.parse(mainData['promotionImages'][index]);
                                       if(lookupMimeType(url.path)!.contains("image/")){
                                         return Stack(
                                           alignment: Alignment.bottomRight,
                                           children: [
                                             Center(
                                               child: Image.network(mainData['promotionImages'][index], errorBuilder: (context, error, stackTrace) {
                                                 return const Center(child: Text("some error occurred", style: TextStyle(color: Colors.white)));
                                               },),
                                             ),
                                             InkWell(
                                               onTap: () {
                                                 FileDownloader.downloadFile(
                                                     url: mainData['promotionImages'][index],
                                                     onDownloadCompleted: (path) {
                                                       debugPrint("download complete hua: ${path}");
                                                     },
                                                     onDownloadError: (errorMessage) {
                                                       debugPrint("download complete nhi hua error: ${errorMessage}");
                                                     },
                                                     onProgress: (fileName, progress) {
                                                       debugPrint("download complete in progress");
                                                     },
                                                     notificationType: NotificationType.all
                                                 );
                                               },
                                               child: Container(
                                                 // margin: EdgeInsets.only(right: 20),
                                                 padding: const EdgeInsets.all(10),
                                                 decoration: BoxDecoration(
                                                     color: Colors.green,
                                                     borderRadius: BorderRadius.circular(5)
                                                 ),
                                                 child: const Text("Download", style: TextStyle(color: Colors.white)),
                                               ),
                                             )
                                           ],
                                         );
                                       }else if(lookupMimeType(url.path)!.contains("video/")){
                                         return Stack(
                                           alignment: Alignment.bottomRight,
                                           children: [
                                             Center(child: CustomVideoPlayer(link: mainData['promotionImages'][index])),
                                             InkWell(
                                               onTap: () {
                                                 FileDownloader.downloadFile(
                                                     url: mainData['promotionImages'][index],
                                                     onDownloadCompleted: (path) {
                                                       debugPrint("download complete hua: ${path}");
                                                     },
                                                     onDownloadError: (errorMessage) {
                                                       debugPrint("download complete nhi hua error: ${errorMessage}");
                                                     },
                                                     onProgress: (fileName, progress) {
                                                       debugPrint("download complete in progress");
                                                     },
                                                     notificationType: NotificationType.all
                                                 );
                                               },
                                               child: Container(
                                                 // margin: EdgeInsets.only(right: 20),
                                                 padding: const EdgeInsets.all(10),
                                                 decoration: BoxDecoration(
                                                     color: Colors.green,
                                                     borderRadius: BorderRadius.circular(5)
                                                 ),
                                                 child: const Text("Download", style: TextStyle(color: Colors.white)),
                                               ),
                                             )
                                           ],
                                         );
                                       }else{
                                         return Stack(
                                           alignment: Alignment.bottomRight,
                                           children: [
                                             Center(
                                               child: Image.network(mainData['promotionImages'][index], errorBuilder: (context, error, stackTrace) {
                                                 return CustomVideoPlayer(link: mainData['promotionImages'][index]);
                                               },),
                                             ),
                                             InkWell(
                                               onTap: () {
                                                 FileDownloader.downloadFile(
                                                     url: mainData['promotionImages'][index],
                                                     onDownloadCompleted: (path) {
                                                       debugPrint("download complete hua: ${path}");
                                                     },
                                                     onDownloadError: (errorMessage) {
                                                       debugPrint("download complete nhi hua error: ${errorMessage}");
                                                     },
                                                     onProgress: (fileName, progress) {
                                                       debugPrint("download complete in progress");
                                                     },
                                                     notificationType: NotificationType.all
                                                 );
                                               },
                                               child: Container(
                                                 // margin: EdgeInsets.only(right: 20),
                                                 padding: const EdgeInsets.all(10),
                                                 decoration: BoxDecoration(
                                                     color: Colors.green,
                                                     borderRadius: BorderRadius.circular(5)
                                                 ),
                                                 child: const Text("Download", style: TextStyle(color: Colors.white)),
                                               ),
                                             ),
                                           ],
                                         );
                                       }
                                     },
                                   ),
                                 ),
                               ),
                             ),
                           if(mainData['postImages'] != null && mainData['postImages'].isNotEmpty)
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Row(children: [
                                   Text(
                                     "Posts",
                                     style: GoogleFonts.ubuntu(
                                         fontSize: 18,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.orange),
                                   ),
                                   IconButton(
                                       onPressed: () {
                                         setState(() {
                                           showPostsImage = !showPostsImage;
                                         });
                                       },
                                       icon: Icon(
                                         showPostsImage == false
                                             ? Icons.arrow_drop_down
                                             : Icons.arrow_drop_up,
                                         color: Colors.white,
                                       ))
                                 ]),
                                 GestureDetector(
                                   onTap: () async{
                                     List<String> localPaths = [];
                                     for (var i = 0; i < mainData['postImages'].length; i++) {
                                       final fileName = 'file_$i.${mainData['postImages'][i].split('.').last}';
                                       final localPath = await downloadFile(mainData['postImages'][i], fileName);
                                       localPaths.add(localPath);
                                     }
                                     shareMultipleToInstagram(localPaths);
                                   },
                                   child: Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                     decoration: BoxDecoration(
                                         color: Colors.green,
                                         borderRadius: BorderRadius.circular(5)
                                     ),
                                     child: const Text("Share", style: TextStyle(color: Colors.white)),
                                   ),
                                 ),
                               ],
                             ),
                           if(showPostsImage && mainData['postImages'] != null && mainData['postImages'].isNotEmpty)
                             Center(
                               child: SizedBox(
                                 width: kIsWeb ? 300 : null,
                                 child: AspectRatio(
                                   aspectRatio: 4/5,
                                   child: PageView.builder(
                                     reverse: false,
                                     scrollDirection: Axis.horizontal,
                                     itemCount: mainData['postImages'].length,
                                     itemBuilder: (context, index) {
                                       print(mainData['postImages'][index]);
                                       Uri url = Uri.parse(mainData['postImages'][index]);
                                       if(lookupMimeType(url.path)!.contains("image/")){
                                         return Stack(
                                           alignment: Alignment.bottomRight,
                                           children: [
                                             Center(
                                               child: Image.network(mainData['postImages'][index], errorBuilder: (context, error, stackTrace) {
                                                 return const Center(child: Text("some error occurred", style: TextStyle(color: Colors.white)));
                                               },),
                                             ),
                                             InkWell(
                                               onTap: () {
                                                 FileDownloader.downloadFile(
                                                     url: mainData['postImages'][index],
                                                     onDownloadCompleted: (path) {
                                                       debugPrint("download complete hua: ${path}");
                                                     },
                                                     onDownloadError: (errorMessage) {
                                                       debugPrint("download complete nhi hua error: ${errorMessage}");
                                                     },
                                                     onProgress: (fileName, progress) {
                                                       debugPrint("download complete in progress");
                                                     },
                                                     notificationType: NotificationType.all
                                                 );
                                               },
                                               child: Container(
                                                 // margin: EdgeInsets.only(right: 20),
                                                 padding: const EdgeInsets.all(10),
                                                 decoration: BoxDecoration(
                                                     color: Colors.green,
                                                     borderRadius: BorderRadius.circular(5)
                                                 ),
                                                 child: const Text("Download", style: TextStyle(color: Colors.white)),
                                               ),
                                             ),
                                           ],
                                         );
                                       }else if(lookupMimeType(url.path)!.contains("video/")){
                                         return Stack(
                                           alignment: Alignment.bottomRight,
                                           children: [
                                             Center(child: CustomVideoPlayer(link: mainData['postImages'][index])),
                                             InkWell(
                                               onTap: () {
                                                 FileDownloader.downloadFile(
                                                     url: mainData['postImages'][index],
                                                     onDownloadCompleted: (path) {
                                                       debugPrint("download complete hua: ${path}");
                                                     },
                                                     onDownloadError: (errorMessage) {
                                                       debugPrint("download complete nhi hua error: ${errorMessage}");
                                                     },
                                                     onProgress: (fileName, progress) {
                                                       debugPrint("download complete in progress");
                                                     },
                                                     notificationType: NotificationType.all
                                                 );
                                               },
                                               child: Container(
                                                 // margin: EdgeInsets.only(right: 20),
                                                 padding: const EdgeInsets.all(10),
                                                 decoration: BoxDecoration(
                                                     color: Colors.green,
                                                     borderRadius: BorderRadius.circular(5)
                                                 ),
                                                 child: const Text("Download", style: TextStyle(color: Colors.white)),
                                               ),
                                             ),
                                           ],
                                         );
                                       }else{
                                         return Stack(
                                           alignment: Alignment.bottomRight,
                                           children: [
                                             Center(
                                               child: Image.network(mainData['postImages'][index], errorBuilder: (context, error, stackTrace) {
                                                 return CustomVideoPlayer(link: mainData['postImages'][index]);
                                               },),
                                             ),
                                             InkWell(
                                               onTap: () {
                                                 FileDownloader.downloadFile(
                                                     url: mainData['postImages'][index],
                                                     onDownloadCompleted: (path) {
                                                       debugPrint("download complete hua: $path");
                                                     },
                                                     onDownloadError: (errorMessage) {
                                                       debugPrint("download complete nhi hua error: $errorMessage");
                                                     },
                                                     onProgress: (fileName, progress) {
                                                       debugPrint("download complete in progress");
                                                     },
                                                     notificationType: NotificationType.all
                                                 );
                                               },
                                               child: Container(
                                                 // margin: EdgeInsets.only(right: 20),
                                                 padding: const EdgeInsets.all(10),
                                                 decoration: BoxDecoration(
                                                     color: Colors.green,
                                                     borderRadius: BorderRadius.circular(5)
                                                 ),
                                                 child: const Text("Download", style: TextStyle(color: Colors.white)),
                                               ),
                                             ),
                                           ],
                                         );
                                       }
                                     },
                                   ),
                                 ),
                               ),
                             ),
                           if(mainData['reelsImages'] != null && mainData['reelsImages'].isNotEmpty)
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Row(children: [
                                   Text(
                                     "Reels",
                                     style: GoogleFonts.ubuntu(
                                         fontSize: 18,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.orange),
                                   ),
                                   IconButton(
                                       onPressed: () {
                                         setState(() {
                                           showReelImage = !showReelImage;
                                         });
                                       },
                                       icon: Icon(
                                         showReelImage == false
                                             ? Icons.arrow_drop_down
                                             : Icons.arrow_drop_up,
                                         color: Colors.white,
                                       ))
                                 ]),
                                 GestureDetector(
                                   onTap: () async{
                                     List<String> localPaths = [];
                                     for (var i = 0; i < mainData['reelsImages'].length; i++) {
                                       final fileName = 'file_$i.${mainData['reelsImages'][i].split('.').last}';
                                       final localPath = await downloadFile(mainData['reelsImages'][i], fileName);
                                       localPaths.add(localPath);
                                     }
                                     shareMultipleToInstagram(localPaths);
                                   },
                                   child: Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                     decoration: BoxDecoration(
                                         color: Colors.green,
                                         borderRadius: BorderRadius.circular(5)
                                     ),
                                     child: const Text("Share", style: TextStyle(color: Colors.white)),
                                   ),
                                 ),
                               ],
                             ),
                           if(showReelImage && mainData['reelsImages'] != null && mainData['reelsImages'].isNotEmpty)
                             Center(
                               child: SizedBox(
                                 width: kIsWeb ? 300 : null,
                                 child: AspectRatio(
                                   aspectRatio: 9/16,
                                   child: PageView.builder(
                                     reverse: false,
                                     scrollDirection: Axis.horizontal,
                                     itemCount: mainData['reelsImages'].length,
                                     itemBuilder: (context, index) {
                                       Uri url = Uri.parse(mainData['reelsImages'][index]);
                                       if(lookupMimeType(url.path)!.contains("image/")){
                                         return Stack(
                                           alignment: Alignment.bottomRight,
                                           children: [
                                             Center(
                                               child: Image.network(mainData['reelsImages'][index], errorBuilder: (context, error, stackTrace) {
                                                 return const Center(child: Text("some error occurred", style: TextStyle(color: Colors.white)));
                                               },),
                                             ),
                                             InkWell(
                                               onTap: () {
                                                 FileDownloader.downloadFile(
                                                     url: mainData['reelsImages'][index],
                                                     onDownloadCompleted: (path) {
                                                       debugPrint("download complete hua: ${path}");
                                                     },
                                                     onDownloadError: (errorMessage) {
                                                       debugPrint("download complete nhi hua error: ${errorMessage}");
                                                     },
                                                     onProgress: (fileName, progress) {
                                                       debugPrint("download complete in progress");
                                                     },
                                                     notificationType: NotificationType.all
                                                 );
                                               },
                                               child: Container(
                                                 // margin: EdgeInsets.only(right: 20),
                                                 padding: const EdgeInsets.all(10),
                                                 decoration: BoxDecoration(
                                                     color: Colors.green,
                                                     borderRadius: BorderRadius.circular(5)
                                                 ),
                                                 child: const Text("Download", style: TextStyle(color: Colors.white)),
                                               ),
                                             )
                                           ],
                                         );
                                       }else if(lookupMimeType(url.path)!.contains("video/")){
                                         return Stack(
                                           alignment: Alignment.bottomRight,
                                           children: [
                                             Center(child: CustomVideoPlayer(link: mainData['reelsImages'][index])),
                                             InkWell(
                                               onTap: () {
                                                 FileDownloader.downloadFile(
                                                     url: mainData['reelsImages'][index],
                                                     onDownloadCompleted: (path) {
                                                       debugPrint("download complete hua: ${path}");
                                                     },
                                                     onDownloadError: (errorMessage) {
                                                       debugPrint("download complete nhi hua error: ${errorMessage}");
                                                     },
                                                     onProgress: (fileName, progress) {
                                                       debugPrint("download complete in progress");
                                                     },
                                                     notificationType: NotificationType.all
                                                 );
                                               },
                                               child: Container(
                                                 // margin: EdgeInsets.only(right: 20),
                                                 padding: const EdgeInsets.all(10),
                                                 decoration: BoxDecoration(
                                                     color: Colors.green,
                                                     borderRadius: BorderRadius.circular(5)
                                                 ),
                                                 child: const Text("Download", style: TextStyle(color: Colors.white)),
                                               ),
                                             )
                                           ],
                                         );
                                       }else{
                                         return Stack(
                                           alignment: Alignment.bottomRight,
                                           children: [
                                             Center(
                                               child: Image.network(mainData['reelsImages'][index], errorBuilder: (context, error, stackTrace) {
                                                 return CustomVideoPlayer(link: mainData['reelsImages'][index]);
                                               },),
                                             ),
                                             InkWell(
                                               onTap: () {
                                                 FileDownloader.downloadFile(
                                                     url: mainData['reelsImages'][index],
                                                     onDownloadCompleted: (path) {
                                                       debugPrint("download complete hua: $path");
                                                     },
                                                     onDownloadError: (errorMessage) {
                                                       debugPrint("download complete nhi hua error: $errorMessage");
                                                     },
                                                     onProgress: (fileName, progress) {
                                                       debugPrint("download complete in progress");
                                                     },
                                                     notificationType: NotificationType.all
                                                 );
                                               },
                                               child: Container(
                                                 // margin: EdgeInsets.only(right: 20),
                                                 padding: const EdgeInsets.all(10),
                                                 decoration: BoxDecoration(
                                                     color: Colors.green,
                                                     borderRadius: BorderRadius.circular(5)
                                                 ),
                                                 child: const Text("Download", style: TextStyle(color: Colors.white)),
                                               ),
                                             ),
                                           ],
                                         );
                                       }
                                     },
                                   ),
                                 ),
                               ),
                             ),
                         ],
                       ),
                     ),
                   Center(
                     child: Container(
                       height: capturedFile == null ? 400 : null,
                       width: kIsWeb ? 400 : double.infinity,
                       margin: const EdgeInsets.all(15),
                       decoration: BoxDecoration(
                           border: Border.all(color: Colors.white),
                           borderRadius: BorderRadius.circular(10)
                       ),
                       child: capturedFile == null
                           ? const Icon(Icons.image_outlined, color: Colors.white)
                           : type == 'image'
                           ? ClipRRect(
                         borderRadius: BorderRadius.circular(10),
                           child: kIsWeb ? Image.network(capturedFile!.path) : Image.file(capturedFile!),
                       )
                           : ClipRRect(
                         borderRadius: BorderRadius.circular(10),
                           child: CustomVideoPlayer(link: capturedFile),
                       ),
                     ),
                   ),
                 ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async{
                    if(capturedFile == null){
                      Fluttertoast.showToast(msg: "Capture an image or video first");
                      return;
                    }
                    shareToInstagram(capturedFile!.path, type);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.green
                    ),
                    child: const Center(child: Text("Share", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async{
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.black,
                      showDragHandle: true,
                      barrierColor: Colors.grey,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              onTap: () async{
                                XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
                                if(image!= null){
                                  type = 'image';
                                  capturedFile = File(image.path);
                                  Navigator.of(context).pop();
                                  setState(() {});
                                }
                              },
                              title: const Text("Image", style: TextStyle(color: Colors.white)),
                              leading: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                            ),
                            ListTile(
                              onTap: () async{
                                XFile? image = await ImagePicker().pickVideo(source: ImageSource.camera);
                                if(image!= null){
                                  type = 'video';
                                  capturedFile = File(image.path);
                                  Navigator.of(context).pop();
                                  setState(() {});
                                }
                              },
                              title: const Text("Video", style: TextStyle(color: Colors.white)),
                              leading: const Icon(Icons.videocam_outlined, color: Colors.white),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                        color: Colors.purple
                    ),
                    child: const Center(child: Text("Capture", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
