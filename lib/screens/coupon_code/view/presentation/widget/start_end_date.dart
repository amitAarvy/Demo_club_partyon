import 'package:club/screens/coupon_code/controller/coupon_code_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StartEndDate extends StatefulWidget {
  final bool isStartDate;

  const StartEndDate({super.key, this.isStartDate = false});

  @override
  State<StartEndDate> createState() => _StartEndDateState();
}

class _StartEndDateState extends State<StartEndDate> {
  final CouponCodeController couponCodeController =
      Get.put(CouponCodeController());

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white)),
            onPressed: () async {
              final dateVal = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2050));
              if (dateVal != null) {
                final timeValue = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());
                if (timeValue != null) {
                  final date = DateFormat('dd-MM-yyyy HH:mm').format(DateTime(
                      dateVal.year,
                      dateVal.month,
                      dateVal.day,
                      timeValue.hour,
                      timeValue.minute));

                  if (widget.isStartDate) {
                    couponCodeController.startDate = date;
                  } else {
                    couponCodeController.endDate = date;
                  }
                }
              }
            },
            child: Text(
              'Choose ${widget.isStartDate ? 'Start Date' : 'End Date'}',
              style:
                  const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),),
      ],
    );
  }
}
