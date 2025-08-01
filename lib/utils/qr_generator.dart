import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

Future<String> barCodeScannerResult() async {
  String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ffffff', 'Cancel', false, ScanMode.QR);
  return barcodeScanRes;
}
