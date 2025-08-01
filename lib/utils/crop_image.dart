import 'package:club/screens/event_management/create_event_promotion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<CroppedFile?> cropImage() async {
  CroppedFile? croppedFile;
  await ImagePicker()
      .pickImage(
    source: ImageSource.gallery,
    maxWidth: 1920,
    maxHeight: 1080,
  )
      .then((value) async {
    croppedFile = await ImageCropper().cropImage( compressQuality: 100,
      sourcePath: (value?.path).toString(),
      aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
        ),
      ],
    );
  });
  return croppedFile;
}

Future<List<CroppedFile>> cropImageMultiple(bool iSNineSixteen, {PromotionType? promotionType, BuildContext? context}) async {
  List<CroppedFile> croppedFile = [];
  await ImagePicker()
      .pickMultiImage(
    maxWidth: 1920,
    maxHeight: 1080
  )
      .then((value) async {
    for (int i = 0; i < value.length; i++) {
      await ImageCropper().cropImage( compressQuality: 100,
        sourcePath: (value[i].path).toString(),
        aspectRatio: promotionType == null
            ? const CropAspectRatio(ratioX: 16, ratioY: 9)
            : promotionType == PromotionType.story || promotionType == PromotionType.reel ? const CropAspectRatio(ratioX: 9, ratioY: 16)  : const CropAspectRatio(ratioX: 4, ratioY: 5),
        // aspectRatioPresets: [
        //   iSNineSixteen
        //       ? CropAspectRatioPreset.ratio16x9
        //       : CropAspectRatioPreset.ratio16x9
        // ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.ratio16x9,
              lockAspectRatio: false),
          IOSUiSettings(title: 'Cropper'),
          if(kIsWeb)
          WebUiSettings(
              context: context!,
            size: CropperSize(height: 200, width: 200),
          ),
        ],
      ).then((value) => croppedFile.add(value!));
    }
  });
  return croppedFile;
}
