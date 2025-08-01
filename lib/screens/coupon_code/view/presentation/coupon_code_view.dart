import 'package:club/screens/coupon_code/controller/coupon_code_controller.dart';
import 'package:club/screens/coupon_code/view/presentation/widget/shared_coupon_event_list.dart';
import 'package:club/screens/coupon_code/view/presentation/widget/start_end_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../const/const.dart';
import 'widget/coupon.dart';
import 'widget/coupon_card.dart';

class CouponCodeView extends StatefulWidget {
  const CouponCodeView({super.key});

  @override
  State<CouponCodeView> createState() => _CouponCodeViewState();
}

class _CouponCodeViewState extends State<CouponCodeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController? couponCodeNameController =
      TextEditingController();
  final TextEditingController termsNConditionController =
      TextEditingController();
  final TextEditingController? discountController = TextEditingController();
  final CouponCodeController couponCodeController =
      Get.put(CouponCodeController());
  final ScrollController scrollerController = ScrollController();
  String? selectedValue = 'Table Management';

  @override
  void initState() {
    _tabController = TabController(
        length: CouponCodeConst.couponTabList.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollerController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            isScrollable: false,
            padding: const EdgeInsets.all(20.0),
            indicator: BoxDecoration(
              color: const Color(0xff451F55),
              borderRadius: BorderRadius.circular(100),
            ),
            labelStyle: const TextStyle(color: Colors.white),
            controller: _tabController,
            tabs: CouponCodeConst.couponTabList
                .map((String e) => Tab(text: e))
                .toList(),
          ),
          //first tabview
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 800, maxHeight: 1500),
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    CouponCard(
                      titleText: 'Choose the Type of Coupon Code',
                      widget: DropdownButtonFormField<String>(
                          iconEnabledColor: Colors.white,
                          iconDisabledColor: Colors.white,
                          dropdownColor: const Color(0xff1F5545),
                          padding: const EdgeInsets.all(8.0),
                          iconSize: 32,
                          hint: const Text("Select an option"),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 44.sp,
                          ),
                          value: selectedValue,
                          items: const [
                            DropdownMenuItem(
                                value: 'Table Management',
                                child: Text('Table Management')),
                            DropdownMenuItem(
                                value: 'Entry Management',
                                child: Text('Entry Management')),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValue = newValue;
                            });
                          }),
                    ),
                    CouponCard(
                      titleText: 'Create Your Coupon Code',
                      widget: TextField(
                        controller: couponCodeNameController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z]')),
                          LengthLimitingTextInputFormatter(20),
                        ],
                        onChanged: (String value) {
                          couponCodeNameController?.value =
                              couponCodeNameController!.value.copyWith(
                                  text: value.toUpperCase(),
                                  selection: TextSelection(
                                      baseOffset: value.length,
                                      extentOffset: value.length));
                          if (value.length > 20) {
                            Fluttertoast.showToast(
                                msg: 'Maximum of 10 characters allowed!');
                          }
                        },
                        decoration: InputDecoration(
                          fillColor: const Color(0xff451F55),
                          filled: true,
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 36.sp,
                          ),
                          hintText: 'Enter your Unique Coupon Code',
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44.sp,
                        ),
                      ),
                    ),
                    CouponCard(
                      titleText: 'Enter the Discount %',
                      widget: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          // FilteringTextInputFormatter.digitsOnly,
                          // LengthLimitingTextInputFormatter(2),
                        ],
                        controller: discountController,
                        decoration: InputDecoration(
                          fillColor: const Color(0xff451F55),
                          filled: true,
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 36.sp,
                          ),
                          hintText:
                              'How Much Is Your Discount For? Enter the Amount!',
                        ),
                        onChanged: (value) {
                          if(int.parse(value) > 100){
                            discountController!.text = '100';
                          }
                        },
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44.sp,
                        ),
                      ),
                    ),
                    Obx(
                      () => CouponCard(
                          titleText:
                              'Choose Start Date & Time: ${couponCodeController.startDate}',
                          widget: const StartEndDate(isStartDate: true)),
                    ),
                    Obx(
                      () => CouponCard(
                          titleText:
                              'Choose End Date  & Time: ${couponCodeController.endDate}',
                          widget: const StartEndDate()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          String couponCode =
                              '${couponCodeNameController?.text}${discountController?.text}';
                          if (selectedValue != null &&
                              couponCodeNameController != null &&
                              discountController != null &&
                              couponCodeController.startDate.isNotEmpty &&
                              couponCodeController.endDate.isNotEmpty) {
                            final result = await Get.to(Coupon(
                                couponCategory: selectedValue ?? '',
                                validFrom: couponCodeController.startDate,
                                validTill: couponCodeController.endDate,
                                couponCode: couponCode,
                                discount: discountController!.text));
                            if (result == 'saved') {
                              _tabController.animateTo(1);
                              scrollerController.jumpTo(0);
                              couponCodeNameController?.clear();
                              discountController?.clear();
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Kindly fill all the required fields');
                          }
                        },
                        style: ButtonStyle(
                          padding:
                              const WidgetStatePropertyAll(EdgeInsets.all(20)),
                          backgroundColor:
                              const WidgetStatePropertyAll(Color(0xff451F55)),
                          textStyle: WidgetStatePropertyAll(
                            TextStyle(
                                color: Colors.white,
                                fontSize: 56.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        child: const Text(
                          'Generate Coupon Code 👆',
                        ),
                      ),
                    ),
                  ],
                ),
                //second tabview
                // const ViewAllCoupons()
                const SharedCouponEventList(isClub: true,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
