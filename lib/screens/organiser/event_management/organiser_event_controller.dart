import 'package:get/get.dart';

class OrganiserEventController extends GetxController {
  final _showCity = false.obs;
  final _cityName = ''.obs;

  bool get showCity => _showCity.value;

  String get cityName => _cityName.value;

  void updateShowCity(bool val) {
    _showCity.value = val;
  }

  String changeCityName(String val) => _cityName.value = val;
}
