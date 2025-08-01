import 'package:club/utils/app_utils.dart';
import 'package:club/screens/organiser/event_management/organiser_event_controller.dart';
import 'package:club/utils/app_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class SearchCity extends StatefulWidget {
  final TextEditingController searchCity;

  const SearchCity({Key? key, required this.searchCity}) : super(key: key);

  @override
  State<SearchCity> createState() => _SearchCityState();
}

class _SearchCityState extends State<SearchCity> {
  final organiserEventController=Get.put(OrganiserEventController());
  @override
  void dispose() {
    // TODO: implement dispose
    widget.searchCity.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List popularCityList = widget.searchCity.text.isEmpty
        ? popularCities
        : popularCities.where((element) => element
        .toLowerCase()
        .startsWith(widget.searchCity.text.toLowerCase())).toList();
    return Container(
      color: matte(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: 100.h,
            ),
            SizedBox(
              height: 200.h,
              width: Get.width - 100.w,
              child: TextField(
                controller: widget.searchCity,
                onChanged: (val) {
                  setState(() {});
                },
                style: GoogleFonts.ubuntu(color: Colors.white),
                decoration: InputDecoration(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  labelText: 'Enter city name',
                  labelStyle: GoogleFonts.ubuntu(color: Colors.white),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white70,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (widget.searchCity.text.isNotEmpty) {
                  organiserEventController
                    ..changeCityName(
                      widget.searchCity.text
                          .toLowerCase()
                          .capitalizeFirstOfEach,
                    )
                    ..updateShowCity(false);
                } else {
                  Fluttertoast.showToast(
                    msg: 'Enter a valid name',
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                      (Set<MaterialState> states) => Colors.green,
                ),
              ),
              child: const Text('Continue'),
            ),
            ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 50.h),
              shrinkWrap: true,
              itemCount: popularCityList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                popularCities.sort();
                if (popularCities[index] == 'Other') {
                  return Container();
                } else {
                  return GestureDetector(
                    onTap: () {
                      organiserEventController
                        ..changeCityName(popularCityList[index])
                        ..updateShowCity(false);
                      // setState(() {});
                    },
                    child: Container(
                      height: 150.h,
                      decoration: BoxDecoration(
                        color: matte(),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: Text(
                          widget.searchCity.text.isEmpty
                              ? popularCities[index]
                              : popularCityList[index],
                          style: GoogleFonts.ubuntu(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}