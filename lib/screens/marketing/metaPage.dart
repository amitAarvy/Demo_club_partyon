import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MetaPage extends StatefulWidget {
  const MetaPage({super.key});

  @override
  State<MetaPage> createState() => _MetaPageState();
}

class _MetaPageState extends State<MetaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:  PreferredSize(
        preferredSize: Size.fromHeight(220.h),
        child: AppBar(
          automaticallyImplyLeading: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PartyOn",
                style: GoogleFonts.dancingScript(
                  color: Colors.red,
                  fontSize: 70.sp,
                ),
              ),
              // SizedBox(
              //   width: 400.w,
              // ),

            ],
          ),
          backgroundColor: Colors.black,
          shadowColor: Colors.grey,
        ),
      ),
      body: const Center(
        child: Text('Coming Soon',style: TextStyle(fontSize: 22,color: Colors.white),),
      ),
    );
  }
}
