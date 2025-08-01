import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AnimationProvider extends ChangeNotifier {
  bool floatingButton = false;

  void changeFloating(bool val) {
    floatingButton = val;
    notifyListeners();
  }
}

class LoginProvider extends GetxController {
  final clubName = "".obs,
      email = "".obs,
      description = "".obs,
      category = "".obs,
      address = "".obs,
      locality = "".obs,
      landmark = "".obs,
      state = "".obs,
      gst = "".obs,
      city = "".obs;

  void changeLogin(
      {String clubName = "",
      email = "",
      description = "",
      category = "",
      address = "",
      locality = "",
      landmark = "",
        gst = '',
      state = "",
      city = ""}) {
    this.clubName.value = clubName;
    this.email.value = email;
    this.description.value = description;
    this.category.value = category;
    this.address.value = address;
    this.locality.value = locality;
    this.landmark.value = landmark;
    this.state.value = state;
    this.city.value = city;
  }
}

class LogoProvider extends ChangeNotifier {
  dynamic logo = "";

  void changeLogo(String logo) {
    this.logo = logo;
    notifyListeners();
  }
}
