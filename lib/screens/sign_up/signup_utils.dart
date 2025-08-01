import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

Future<Position> getGeoLocationPosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    await Geolocator.openLocationSettings();
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      Fluttertoast.showToast(msg: 'Location permissions are denied');
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    Fluttertoast.showToast(
        msg:
        'Location permissions are permanently denied. Go to app settings and enable location permissions');
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}