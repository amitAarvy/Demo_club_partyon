import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:random_string/random_string.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';


import '../../utils/app_utils.dart';


class Payments extends StatefulWidget {
  final double amount;
  final String userType;
  final planDetail;
  final String planId;

  const Payments({
    required this.amount,
    this.planDetail,
    super.key, required this.userType, required this.planId,
  });

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  static const MethodChannel platform = MethodChannel('razorpay_flutter');

  late Razorpay _razorpay;

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            color: Colors.orange,
          )
        ],
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    if (widget.amount == 0) {
      paymentUpdate();
    } else {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      openCheckout();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  Future<void> openCheckout() async {
    Map<String, Object> options = {
      'key': 'rzp_test_rxNWplsh8FCMMs',
      // 'key': 'rzp_live_um0gFkBW3RX3fA',//production
      // 'secret': 'woOvOOkFDqhRjdxTJtkCux5z',
      'amount': widget.amount * 100,
      'name': 'PartyOn Entertainment PVT LTD',
      'description': 'Payment',
      'retry': {'enabled': true, 'max_count': 1},
      // 'customer_id':uid(),
      'send_sms_hash': true,
      'prefill': {
        FirebaseAuth.instance.currentUser?.phoneNumber ?? "": '',
        'email': ''
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }



    paymentUpdate()async{
      String paymentId = Uuid().v4();
      await FirebaseFirestore.instance.collection('BookingPlan').doc(paymentId).set({
        'id':uid(),
        'type':widget.userType,
        'paymentID': paymentId,
        'userID': uid(),
        'amount': widget.amount,
        'status': 'S',
        'date': FieldValue.serverTimestamp(),
        'planId':widget.planId,
        'planDetail':widget.planDetail
      }, SetOptions(merge: true)).whenComplete(() {
        Fluttertoast.showToast(
          msg: 'Payment Successful',
          toastLength: Toast.LENGTH_SHORT,
        );

        Get.back();
      });
    }


  Future<void> handlePaymentSuccess(PaymentSuccessResponse response) async {
    final String paymentID = 'pay_${randomAlphaNumeric(14)}';
    await FirebaseFirestore.instance.collection('BookingPlan').doc(paymentID).set({
      'id':uid(),
      'type':widget.userType,
      'paymentID': paymentID,
      'userID': uid(),
      'amount': widget.amount,
      'status': 'S',
      'date': FieldValue.serverTimestamp(),
      'planId':widget.planId,
      'planDetail':widget.planDetail
    }, SetOptions(merge: true)).whenComplete(() {
      Fluttertoast.showToast(
        msg: 'Payment Successful',
        toastLength: Toast.LENGTH_SHORT,
      );

      Get.back();
    });

  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    print('check error is ${response.error}');
    print('check error is ${response.message}');
    print('check error is ${response.code}');
    // final String ipv6 = await Ipify.ipv64();
    final String paymentID = 'pay_${randomAlphaNumeric(14)}';

    await FirebaseFirestore.instance.collection('BookingPlan').doc(paymentID).set({
      'id':uid(),
      'type':widget.userType,
      'paymentID': paymentID,
      'userID': uid(),
      'amount': widget.amount,
      'planId':widget.planId,
      'status': 'F',
      'date': FieldValue.serverTimestamp(),
      'planDetail':widget.planDetail
    }, SetOptions(merge: true)).whenComplete(() {
      Fluttertoast.showToast(
        msg: 'Payment Failed',
        toastLength: Toast.LENGTH_SHORT,
      );

      Get.back();
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: 'EXTERNAL_WALLET: ${response.walletName!}',
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
