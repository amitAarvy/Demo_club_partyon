class ClubModel {
  ClubModel({
    this.category,
    this.clubUID,
    this.state,
    this.coverImage,
    this.logo,
    this.isClub,
    this.pplCert,
    this.description,
    this.city,
    this.area,
    required this.activeStatus,
    required this.bookingActiveStatus,
    this.gstCert,
    this.averageCost,
    this.locality,
    this.longitude,
    this.email,
    this.landmark,
    this.latitude,
    this.pinCode,
    this.clubID,
    required this.galleryImages,
    this.layoutImage,
    this.relationAgreement,
    this.closeTime,
    this.openTime,
    this.clubName,
    this.date,
    this.address,
  });

  ClubModel.fromJson(dynamic json) {
    category = json['category'] != null ? json['category'].cast<String>() : [];
    clubUID = json['clubUID'];
    state = json['state'];
    coverImage = json['coverImage'];
    logo = json['logo'];
    isClub = json['isClub'];
    pplCert = json['pplCert'];
    description = json['description'];
    city = json['city'];
    area = json['area'];
    activeStatus = json['activeStatus'];
    bookingActiveStatus = json.containsKey('bookingActiveStatus')
        ? json['bookingActiveStatus']
        : false;
    gstCert = json['gstCert'];
    averageCost = json['averageCost'] is int
        ? json['averageCost']
        : int.parse(json['averageCost']);
    locality = json['locality'];
    longitude = json['longitude'];
    email = json['email'].toString();
    landmark = json['landmark'].toString();
    latitude = json['latitude'];
    pinCode = json['pinCode'].toString();
    clubID = json['clubID'].toString();
    galleryImages = json['galleryImages'] != null
        ? json['galleryImages'].cast<String>()
        : [];
    layoutImage = json['layoutImage'].toString();
    relationAgreement = json['relationAgreement'];
    closeTime = json['closeTime'];
    openTime = json['openTime'];
    clubName = json['clubName'];
    date = json['date'].toDate();
    address = json['address'];
  }

  List<String>? category;
  String? clubUID;
  String? state;
  String? coverImage;
  String? logo;
  bool? isClub;
  String? pplCert;
  String? description;
  String? city;
  String? area;
  bool? activeStatus;
  bool? bookingActiveStatus;
  String? gstCert;
  int? averageCost;
  String? locality;
  dynamic longitude;
  String? email;
  String? landmark;
  dynamic latitude;
  String? pinCode;
  String? clubID;
  List<String>? galleryImages;
  String? layoutImage;
  String? relationAgreement;
  String? closeTime;
  String? openTime;
  String? clubName;
  DateTime? date;
  String? address;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['category'] = category;
    map['clubUID'] = clubUID;
    map['state'] = state;
    map['coverImage'] = coverImage;
    map['logo'] = logo;
    map['isClub'] = isClub;
    map['pplCert'] = pplCert;
    map['description'] = description;
    map['city'] = city;
    map['area'] = area;
    map['activeStatus'] = activeStatus;
    map['gstCert'] = gstCert;
    map['averageCost'] = averageCost;
    map['locality'] = locality;
    map['longitude'] = longitude;
    map['email'] = email;
    map['landmark'] = landmark;
    map['latitude'] = latitude;
    map['pinCode'] = pinCode;
    map['clubID'] = clubID;
    map['galleryImages'] = galleryImages;
    map['layoutImage'] = layoutImage;
    map['relationAgreement'] = relationAgreement;
    map['closeTime'] = closeTime;
    map['openTime'] = openTime;
    map['clubName'] = clubName;
    map['date'] = date;
    map['address'] = address;
    return map;
  }
}
