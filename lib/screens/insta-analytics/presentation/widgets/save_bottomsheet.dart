import 'package:club/screens/insta-analytics/controller/instagram_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SaveBottomSheet extends StatefulWidget {
  final List<String> accessIds;
  final Function() onTap;

  const SaveBottomSheet(
      {super.key, required this.onTap, required this.accessIds});

  @override
  State<SaveBottomSheet> createState() => _SaveBottomSheetState();
}

class _SaveBottomSheetState extends State<SaveBottomSheet> {
  final TextEditingController textEditingController = TextEditingController();
  final InstagramController instagramController = Get.find();

  @override
  void initState() {
    instagramController.addAllAccessIds(widget.accessIds);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                hintText: 'Enter email or phone of user you want to share',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder())),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => Wrap(
                  children: instagramController.accessIds
                      .map((e) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        e,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 40.sp),
                                      ),
                                      InkWell(
                                          onTap: () => instagramController
                                              .removeAccessId(e),
                                          child: Icon(
                                            FontAwesomeIcons.xmark,
                                            color: Colors.white,
                                            size: 40.sp,
                                          ))
                                    ],
                                  ),
                                )),
                          ))
                      .toList()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                child: ElevatedButton(
                  onPressed: () {
                    instagramController.addAccessId(textEditingController.text);
                    textEditingController.clear();
                  },
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.amber)),
                  child: const Text('Add User'),
                ),
              ),
              ElevatedButton(
                  onPressed: () async => widget.onTap(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Save'),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
