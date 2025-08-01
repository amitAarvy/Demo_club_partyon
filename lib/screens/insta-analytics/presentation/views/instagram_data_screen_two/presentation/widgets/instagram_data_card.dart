import 'package:flutter/material.dart';

class InstagramDataCard extends StatelessWidget {
  final FutureBuilder? futureBuilder;
  final bool isFutureBuilder;
  final Widget? child;

  const InstagramDataCard(
      {super.key,
      this.futureBuilder,
      required this.isFutureBuilder,
      this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 560,
      // width: 1000,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              // Colors.white,
              Color(0xfff9ce34),
              Color(0xffee2a7b),
              Color(0xff6228d7),
            ]),
      ),
      child: Container(
        margin: const EdgeInsets.all(2.0),
        padding: const EdgeInsets.all(10),
        // height: 560,
        // width: 1000,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: Colors.black54),
        child: isFutureBuilder ? futureBuilder : child,
      ),
    );
  }
}
