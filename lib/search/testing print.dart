// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
// import 'package:print_bluetooth_thermal/post_code.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:image/image.dart' as img;
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal_windows.dart';
//
//
// class MyApps extends StatefulWidget {
//   const MyApps({super.key});
//
//   @override
//   MyAppsState createState() => MyAppsState();
// }
//
// class MyAppsState extends State<MyApps> {
//   String _info = "";
//   String _msj = '';
//   bool connected = false;
//   List<BluetoothInfo> items = [];
//   final List<String> _options = ["permission bluetooth granted", "bluetooth enabled", "connection status", "update info"];
//
//   String _selectSize = "2";
//   final _txtText = TextEditingController(text: "Hello developer");
//   bool _progress = false;
//   String _msjprogress = "";
//
//   String optionprinttype = "58 mm";
//   List<String> options = ["58 mm", "80 mm"];
//
//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Plugin example app'),
//         actions: [
//           PopupMenuButton(
//             elevation: 3.2,
//             //initialValue: _options[1],
//             onCanceled: () {
//               print('You have not chossed anything');
//             },
//             tooltip: 'Menu',
//             onSelected: (Object select) async {
//               String sel = select as String;
//               if (sel == "permission bluetooth granted") {
//                 bool status = await PrintBluetoothThermal.isPermissionBluetoothGranted;
//                 setState(() {
//                   _info = "permission bluetooth granted: $status";
//                 });
//                 //open setting permision if not granted permision
//               } else if (sel == "bluetooth enabled") {
//                 bool state = await PrintBluetoothThermal.bluetoothEnabled;
//                 setState(() {
//                   _info = "Bluetooth enabled: $state";
//                 });
//               } else if (sel == "update info") {
//                 initPlatformState();
//               } else if (sel == "connection status") {
//                 final bool result = await PrintBluetoothThermal.connectionStatus;
//                 connected = result;
//                 setState(() {
//                   _info = "connection status: $result";
//                 });
//               }
//             },
//             itemBuilder: (BuildContext context) {
//               return _options.map((String option) {
//                 return PopupMenuItem(
//                   value: option,
//                   child: Text(option),
//                 );
//               }).toList();
//             },
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             // spacing: 3,
//             children: [
//               Text('info: $_info\n '),
//               Text(_msj),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Type print"),
//                   const SizedBox(width: 10),
//                   DropdownButton<String>(
//                     value: optionprinttype,
//                     items: options.map((String option) {
//                       return DropdownMenuItem<String>(
//                         value: option,
//                         child: Text(option),
//                       );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         optionprinttype = newValue!;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   // spacing: 5,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         getBluetoots();
//                       },
//                       child: Row(
//                         children: [
//                           Visibility(
//                             visible: _progress,
//                             child: const SizedBox(
//                               width: 25,
//                               height: 25,
//                               child: CircularProgressIndicator.adaptive(strokeWidth: 1, backgroundColor: Colors.blue),
//                             ),
//                           ),
//                           const SizedBox(width: 5),
//                           Text(_progress ? _msjprogress : "Search"),
//                         ],
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: connected ? disconnect : null,
//                       child: const Text("Disconnect"),
//                     ),
//                     ElevatedButton(
//                       onPressed: connected ? printTest : null,
//                       child: const Text("Test"),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                   height: 200,
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.all(Radius.circular(10)),
//                     color: Colors.grey.withAlpha(50),
//                   ),
//                   child: ListView.builder(
//                     itemCount: items.isNotEmpty ? items.length : 0,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         onTap: () {
//                           String mac = items[index].macAdress;
//                           connect(mac);
//                         },
//                         title: Text('Name: ${items[index].name}'),
//                         subtitle: Text("macAddress: ${items[index].macAdress}"),
//                       );
//                     },
//                   )),
//               const SizedBox(height: 10),
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.all(Radius.circular(10)),
//                   color: Colors.grey.withAlpha(50),
//                 ),
//                 child: Column(children: [
//                   const Text("Text size without the library without external packets, print images still it should not use a library"),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _txtText,
//                           decoration: const InputDecoration(
//                             border: OutlineInputBorder(),
//                             labelText: "Text",
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 5),
//                       DropdownButton<String>(
//                         hint: const Text('Size'),
//                         value: _selectSize,
//                         items: <String>['1', '2', '3', '4', '5'].map((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                         onChanged: (String? select) {
//                           setState(() {
//                             _selectSize = select.toString();
//                           });
//                         },
//                       )
//                     ],
//                   ),
//                   ElevatedButton(
//                     onPressed: connected ? printWithoutPackage : null,
//                     child: const Text("Print"),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> initPlatformState() async {
//     String platformVersion;
//     int porcentbatery = 0;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       platformVersion = await PrintBluetoothThermal.platformVersion;
//       //print("patformversion: $platformVersion");
//       porcentbatery = await PrintBluetoothThermal.batteryLevel;
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }
//
//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;
//
//     final bool result = await PrintBluetoothThermal.bluetoothEnabled;
//     print("bluetooth enabled: $result");
//     if (result) {
//       _msj = "Bluetooth enabled, please search and connect";
//     } else {
//       _msj = "Bluetooth not enabled";
//     }
//
//     setState(() {
//       _info = "$platformVersion ($porcentbatery% battery)";
//     });
//   }
//
//   Future<void> getBluetoots() async {
//     setState(() {
//       _progress = true;
//       _msjprogress = "Wait";
//       items = [];
//     });
//     final List<BluetoothInfo> listResult = await PrintBluetoothThermal.pairedBluetooths;
//
//     /*await Future.forEach(listResult, (BluetoothInfo bluetooth) {
//       String name = bluetooth.name;
//       String mac = bluetooth.macAdress;
//     });*/
//
//     setState(() {
//       _progress = false;
//     });
//
//     if (listResult.length == 0) {
//       _msj = "There are no bluetoohs linked, go to settings and link the printer";
//     } else {
//       _msj = "Touch an item in the list to connect";
//     }
//
//     setState(() {
//       items = listResult;
//     });
//   }
//
//   Future<void> connect(String mac) async {
//     setState(() {
//       _progress = true;
//       _msjprogress = "Connecting...";
//       connected = false;
//     });
//     final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
//     print("state conected $result");
//     if (result) connected = true;
//     setState(() {
//       _progress = false;
//     });
//   }
//
//   Future<void> disconnect() async {
//     final bool status = await PrintBluetoothThermal.disconnect;
//     setState(() {
//       connected = false;
//     });
//     print("status disconnect $status");
//   }
//
//   Future<void> printTest() async {
//     /*if (kDebugMode) {
//       bool result = await PrintBluetoothThermalWindows.writeBytes(bytes: "Hello \n".codeUnits);
//       return;
//     }*/
//
//     bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
//     //print("connection status: $conexionStatus");
//     if (conexionStatus) {
//       bool result = false;
//       if (Platform.isWindows) {
//         List<int> ticket = await testWindows();
//         result = await PrintBluetoothThermalWindows.writeBytes(bytes: ticket);
//       } else {
//         List<int> ticket = await testTicket();
//         result = await PrintBluetoothThermal.writeBytes(ticket);
//       }
//       print("print test result:  $result");
//     } else {
//       print("print test conexionStatus: $conexionStatus");
//       setState(() {
//         disconnect();
//       });
//       //throw Exception("Not device connected");
//     }
//   }
//
//   Future<void> printString() async {
//     bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
//     if (conexionStatus) {
//       String enter = '\n';
//       await PrintBluetoothThermal.writeBytes(enter.codeUnits);
//       //size of 1-5
//       String text = "Hello";
//       await PrintBluetoothThermal.writeString(printText: PrintTextSize(size: 1, text: text));
//       await PrintBluetoothThermal.writeString(printText: PrintTextSize(size: 2, text: "$text size 2"));
//       await PrintBluetoothThermal.writeString(printText: PrintTextSize(size: 3, text: "$text size 3"));
//     } else {
//       //desconectado
//       print("desconectado bluetooth $conexionStatus");
//     }
//   }
//
//   Future<List<int>> testTicket() async {
//     List<int> bytes = [];
//     // Using default profile
//     final profile = await CapabilityProfile.load();
//     final generator = Generator(optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);
//     //bytes += generator.setGlobalFont(PosFontType.fontA);
//     bytes += generator.reset();
//
//     final ByteData data = await rootBundle.load('assets/mylogo.jpg');
//     final Uint8List bytesImg = data.buffer.asUint8List();
//     img.Image? image = img.decodeImage(bytesImg);
//
//     if (Platform.isIOS) {
//       // Resizes the image to half its original size and reduces the quality to 80%
//       final resizedImage = img.copyResize(image!, width: image.width ~/ 1.3, height: image.height ~/ 1.3, interpolation: img.Interpolation.nearest);
//       final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
//       //image = img.decodeImage(bytesimg);
//     }
//
//     //Using `ESC *`
//     //bytes += generator.image(image!);
//
//     bytes += generator.text('Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//     bytes += generator.text('Special 1: ñÑ àÀ èÈ éÉ üÜ çÇ ôÔ', styles: const PosStyles(codeTable: 'CP1252'));
//     bytes += generator.text('Special 2: blåbærgrød', styles: const PosStyles(codeTable: 'CP1252'));
//
//     bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
//     bytes += generator.text('Reverse text', styles: const PosStyles(reverse: true));
//     bytes += generator.text('Underlined text', styles: const PosStyles(underline: true), linesAfter: 1);
//     bytes += generator.text('Align left', styles: const PosStyles(align: PosAlign.left));
//     bytes += generator.text('Align center', styles: const PosStyles(align: PosAlign.center));
//     bytes += generator.text('Align right', styles: const PosStyles(align: PosAlign.right), linesAfter: 1);
//
//     bytes += generator.row([
//       PosColumn(
//         text: 'col3',
//         width: 3,
//         styles: const PosStyles(align: PosAlign.center, underline: true),
//       ),
//       PosColumn(
//         text: 'col6',
//         width: 6,
//         styles: const PosStyles(align: PosAlign.center, underline: true),
//       ),
//       PosColumn(
//         text: 'col3',
//         width: 3,
//         styles: const PosStyles(align: PosAlign.center, underline: true),
//       ),
//     ]);
//
//     //barcode
//
//     final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
//     bytes += generator.barcode(Barcode.upcA(barData));
//
//     //QR code
//     bytes += generator.qrcode('example.com');
//
//     bytes += generator.text(
//       'Text size 50%',
//       styles: const PosStyles(
//         fontType: PosFontType.fontB,
//       ),
//     );
//     bytes += generator.text(
//       'Text size 100%',
//       styles: const PosStyles(
//         fontType: PosFontType.fontA,
//       ),
//     );
//     bytes += generator.text(
//       'Text size 200%',
//       styles: const PosStyles(
//         height: PosTextSize.size2,
//         width: PosTextSize.size2,
//       ),
//     );
//
//     bytes += generator.feed(2);
//     //bytes += generator.cut();
//     return bytes;
//   }
//
//   Future<List<int>> testWindows() async {
//     List<int> bytes = [];
//
//     bytes += PostCode.text(text: "Size compressed", fontSize: FontSize.compressed);
//     bytes += PostCode.text(text: "Size normal", fontSize: FontSize.normal);
//     bytes += PostCode.text(text: "Bold", bold: true);
//     bytes += PostCode.text(text: "Inverse", inverse: true);
//     bytes += PostCode.text(text: "AlignPos right", align: AlignPos.right);
//     bytes += PostCode.text(text: "Size big", fontSize: FontSize.big);
//     bytes += PostCode.enter();
//
//     //List of rows
//     bytes += PostCode.row(texts: ["PRODUCT", "VALUE"], proportions: [60, 40], fontSize: FontSize.compressed);
//     for (int i = 0; i < 3; i++) {
//       bytes += PostCode.row(texts: ["Item $i", "$i,00"], proportions: [60, 40], fontSize: FontSize.compressed);
//     }
//
//     bytes += PostCode.line();
//
//     bytes += PostCode.barcode(barcodeData: "123456789");
//     bytes += PostCode.qr("123456789");
//
//     bytes += PostCode.enter(nEnter: 5);
//
//     return bytes;
//   }
//
//   Future<void> printWithoutPackage() async {
//     //impresion sin paquete solo de PrintBluetoothTermal
//     bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
//     if (connectionStatus) {
//       String text = "${_txtText.text}\n";
//       bool result = await PrintBluetoothThermal.writeString(printText: PrintTextSize(size: int.parse(_selectSize), text: text));
//       print("status print result: $result");
//       setState(() {
//         _msj = "printed status: $result";
//       });
//     } else {
//       //no conectado, reconecte
//       setState(() {
//         _msj = "no connected device";
//       });
//       print("no conectado");
//     }
//   }
// }

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

import '../screens/bookings/booking_details.dart';

class BluetoothService {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  bool isConnected = false;

  Function(bool)? onConnectionChanged;
  BuildContext context;

  BluetoothService({required this.context, this.onConnectionChanged});

  /// Initialize and get paired devices
  Future<void> initBluetooth() async {
    try {
      await autoReconnectToLastDevice();

      bool? alreadyConnected = await bluetooth.isConnected;

      if (alreadyConnected == true) {
        List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
        String name = bondedDevices.isNotEmpty ? bondedDevices.first.name ?? "Bluetooth Printer" : "Bluetooth Printer";

        isConnected = true;
        onConnectionChanged?.call(true);
        Fluttertoast.showToast(msg: 'Connected to $name');
        return;
      }

      devices = await bluetooth.getBondedDevices();

      if (devices.isEmpty) {
        Fluttertoast.showToast(msg: 'No Bluetooth devices found');
        return;
      }

      bluetooth.onStateChanged().listen((state) {
        if (state == BlueThermalPrinter.CONNECTED) {
          isConnected = true;
          onConnectionChanged?.call(true);
        } else {
          isConnected = false;
          onConnectionChanged?.call(false);
        }
      });

      _showDeviceDialog();
    } catch (e) {
      print("Bluetooth Init Error: $e");
      Fluttertoast.showToast(msg: 'Bluetooth Error: $e');
    }
  }

  /// Show device selection dialog
  void _showDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Material(
            color: Colors.black,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(11)),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: devices.map((device) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          connectToDevice(device);
                        },
                        child: Text(
                          device.name ?? "Unknown Device",
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Connect to device and save address
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await bluetooth.connect(device);
      bool? connected = await bluetooth.isConnected;

      if (connected == true) {
        await _saveLastDeviceAddress(device.address.toString());
        selectedDevice = device;
        isConnected = true;
        onConnectionChanged?.call(true);
        Fluttertoast.showToast(msg: 'Device Connected: ${device.name}');
      } else {
        Fluttertoast.showToast(msg: 'Failed to connect');
      }
    } catch (e) {
      print('Connection Error: $e');
      Fluttertoast.showToast(msg: 'Connection Error: $e');
    }
  }

  /// Auto reconnect to last saved device
  Future<void> autoReconnectToLastDevice() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? address = prefs.getString('last_connected_device');

      if (address != null) {
        List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
        BluetoothDevice? matched = bondedDevices.firstWhere(
              (d) => d.address == address,
        );

        if (matched != null) {
          await bluetooth.connect(matched);
          bool? connected = await bluetooth.isConnected;
          if (connected == true) {
            selectedDevice = matched;
            isConnected = true;
            onConnectionChanged?.call(true);
            Fluttertoast.showToast(msg: "Auto-connected to ${matched.name}");
          }
        }
      }
    } catch (e) {
      print("Auto Connect Error: $e");
    }
  }

  /// Disconnect
  Future<void> disconnect() async {
    await bluetooth.disconnect();
    isConnected = false;
    selectedDevice = null;
    onConnectionChanged?.call(false);
  }

  /// Save address to preferences
  Future<void> _saveLastDeviceAddress(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_connected_device', address);
  }

  /// Print QR Code Sample
  Future<void> printSample({
    required String bookingID,
    required String eventId,
    required String uuid,
   String alignment = 'center'
  }) async {
    if (!isConnected) {
      Fluttertoast.showToast(msg: 'Printer not connected');
      return;
    }
    try {
      String tspl ='';
      //center

      if(alignment =='center'){
         tspl = '''
        SIZE 85 mm,15 mm
        GAP 3 mm,2 mm
        CLS
        QRCODE 328,36,L,2,A,0,"UA|$bookingID|$eventId|$uuid"
        PRINT 1
        ''';
      }
      if(alignment =='right'){
         tspl = '''
          SIZE 85 mm,15 mm
          GAP 3 mm,2 mm
          CLS
          QRCODE 76,36,L,2,A,0,"UA|$bookingID|$eventId|$uuid"
          PRINT 1
          ''';
      }




      bluetooth.write(tspl);
      bluetooth.write(tspl); // Paper cut
    } catch (e) {
      print('Print Error: $e');
      Fluttertoast.showToast(msg: 'Print Error: $e');
    }
  }
}
