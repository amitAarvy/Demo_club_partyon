import 'package:get/get.dart';

class HomeController extends GetxController {
  var clubID = "club_001".obs;
  var clubName = "...".obs;
  var organiserName = "...".obs;
  var influencerName = "...".obs;
  var coverImage = "".obs;
  var profileLogo = "".obs;
  var description = "Loading".obs;
  var category = [].obs;
  var clubUid = "".obs;
  var address = "Loading".obs;
  var area = "Loading".obs;
  var landmark = "Loading".obs;
  var state = "Loading".obs;
  var city = "Loading".obs;
  var pinCode = "Loading".obs;
  var openTime = "Loading".obs;
  var closeTime = "Loading".obs;
  var avgCost = "Loading".obs;
  var locality = "Loading".obs;
  var activeStatus = false.obs;
  var gst = "Loading".obs;

  updateClub(String clubID) {
    this.clubID.value = clubID;
  }

  updateStatus(bool val) {
    activeStatus.value = val;
  }

  updateCoveImage(String coverImage) {
    this.coverImage.value = coverImage;
  }
  updateGstImage(String gst) {
    this.gst.value = gst;
  }

  updateClubName(String clubName) {
    this.clubName.value = clubName;
  }
  updateClubUid(String val) {
    clubUid.value = val;
  }
  updateOrganiserName(String organiserName) {
    this.organiserName.value = organiserName;
  }
  updateInfluencerName(String infName) {
    this.influencerName.value = infName;
  }

  updateProfile(String val) {
    profileLogo.value = val;
  }

  updateDescription(String val) {
    description.value = val;
  }

  updateCategory(List val) {
    category.value = val;
  }

  updateAddress(String val) {
    address.value = val;
  }

  updateArea(String val) {
    area.value = val;
  }

  updateLocality(String val) {
    locality.value = val;
  }

  updateLandMark(String val) {
    landmark.value = val;
  }

  updateState(String val) {
    state.value = val;
  }

  updateCity(String val) {
    city.value = val;
  }

  updatePinCode(String val) {
    pinCode.value = val;
  }

  updateOpenTime(String val) {
    openTime.value = val;
  }

  updateCloseTime(String val) {
    closeTime.value = val;
  }

  updateAvgCost(String val) {
    avgCost.value = val;
  }
}
