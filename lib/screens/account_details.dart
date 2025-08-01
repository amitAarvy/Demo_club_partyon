import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails({Key? key}) : super(key: key);

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  final TextEditingController _accountNumber = TextEditingController();
  final TextEditingController _confirmAccountNumber = TextEditingController();
  final TextEditingController _ifscCode = TextEditingController();
  final TextEditingController _accountName = TextEditingController();
  final c = Get.put(HomeController());

  @override
  void initState() {
    // TODO: implement initState
    FirebaseFirestore.instance
        .collection("Club")
        .doc(uid())
        .get()
        .then((value) {
      if (kDebugMode) {
        print(value.data()?["accountDetail"]["accountNumber"]);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Account Details"),
      drawer: drawer(context: context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          textField("Account Name", _accountName),
          textField("Account Number", _accountNumber, isNum: true),
          textField("Confirm Account Number", _confirmAccountNumber,
              isNum: true),
          textField("IFSC Code", _ifscCode),
          ElevatedButton(
            onPressed: () {
              if (_accountNumber.text.isNotEmpty &&
                  _confirmAccountNumber.text.isNotEmpty &&
                  _ifscCode.text.isNotEmpty &&
                  _accountName.text.isNotEmpty) {
                if (_accountName.text != _confirmAccountNumber.text) {
                  EasyLoading.show();
                  FirebaseFirestore.instance
                      .collection("Club")
                      .doc(uid())
                      .set({
                    "accountDetail": {
                      "accountNumber": _accountNumber.text,
                      "accountIFSC": _ifscCode.text,
                      "accountName": _accountName.text,
                      "dateTime": FieldValue.serverTimestamp()
                    }
                  }, SetOptions(merge: true)).whenComplete(() {
                    EasyLoading.dismiss();
                    Fluttertoast.showToast(msg: "Updated Successfully");
                  });
                } else {
                  Fluttertoast.showToast(msg: "Account details do not match");
                }
              } else {
                Fluttertoast.showToast(msg: "Kindly fill all required fields");
              }
            },
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.green)),
            child: const Text("Update Account"),
          )
        ],
      ),
    );
  }
}
