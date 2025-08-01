import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../authentication/login_page.dart';

class DeactivateAccountScreen extends StatefulWidget {
  const DeactivateAccountScreen({super.key});

  @override
  State<DeactivateAccountScreen> createState() => _DeactivateAccountScreenState();
}

class _DeactivateAccountScreenState extends State<DeactivateAccountScreen> {
  final TextEditingController _reasonController = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20),
                  //   child: TextField(
                  //     keyboardType: TextInputType.text,
                  //     textInputAction: TextInputAction.done,
                  //     onSubmitted: (value) {
                  //       FocusManager.instance.primaryFocus!.unfocus();
                  //     },
                  //     controller: _reasonController,
                  //     decoration: InputDecoration(
                  //       hintText: 'Please specify the reason...',
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //       contentPadding: const EdgeInsets.all(16),
                  //     ),
                  //     maxLines: 4,
                  //   ),
                  // ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: Text(
                        // 'All your personal data will be automatically deleted from our servers within 24 hours. To continue using the application after your data is deleted, you will need to register with us again.',
                        'Are you sure want to delete account ?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'NO',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: ()async {
                              SharedPreferences pref = await SharedPreferences.getInstance();
                              // if(_reasonController.text.isEmpty){
                              //   Fluttertoast.showToast(msg: 'Please enter specify reason..');
                              //   // toast('Please enter specify reason..');
                              // }else{
                                pref.clear();
                                await FirebaseAuth.instance.signOut();
                                await const FlutterSecureStorage().deleteAll();
                                await FacebookAuth.instance.logOut();
                                await FirebaseAuth.instance.signOut();
                                await GoogleSignIn().signOut();
                                await Hive.deleteFromDisk();
                                Get.off(const LoginPage());
                                Fluttertoast.showToast(msg: 'Your account has been deleted successfully.');
                                // toast('Your account has been deleted successfully.');
                              // }
                            },
                            child: const Text(
                              'YES',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}