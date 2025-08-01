import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_utils.dart';
import '../account/booking_List.dart';
import '../home/home_utils.dart';
import '../payment_gateWay/payment.dart';
import 'invoice_page.dart';

class TransactionHome extends StatefulWidget {
  const TransactionHome({super.key, });

  @override
  State<TransactionHome> createState() => _TransactionHomeState();
}

class _TransactionHomeState extends State<TransactionHome> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "",showBack:false),
      body: Center(
        child: Row(
          children: [
            tile(
                "My Transaction",
                const Icon(
                  FontAwesomeIcons.moneyBillTransfer,
                  color: Colors.white,
                ),
                page: const BookingList(isOrganiser: 'venue',)
            ),

            tile(
                "Invoice",
                const Icon(
                  FontAwesomeIcons.fileInvoice,
                  color: Colors.white,
                ),
                page: const InvoicePage()
            ),
          ],
        ),
      ),
    );
  }
  }