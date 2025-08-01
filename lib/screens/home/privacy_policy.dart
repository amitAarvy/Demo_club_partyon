import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: 'Privacy Policy'),
      body: SfPdfViewer.network(
          'https://drive.google.com/uc?export=download&id=1sZhb-agVXXy0Q-NNSKApgngx0xG0ZvoM',
          key: _pdfViewerKey),
    );
  }
}
