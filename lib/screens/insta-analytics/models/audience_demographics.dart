/// id : "a072af5d-367b-4c81-a401-d4f0bb3b5fa2"
/// created_at : "2024-12-03T10:40:53.146273"
/// updated_at : "2024-12-12T10:40:56.497890"
/// user : {"id":"d59cab3c-afaf-44f1-a04a-f5ac7527d812","name":"Lokesh"}
/// account : {"id":"3e113106-afb5-480b-90c3-0ba4e8f807a8","platform_username":"ai4today","username":"ai4today"}
/// work_platform : {"id":"9bb8913b-ddd9-430b-a66a-d74d846e6c66","name":"Instagram","logo_url":"https://cdn.getphyllo.com/platforms_logo/logos/logo_instagram.png"}
/// countries : [{"code":"BA","value":0.51},{"code":"TR","value":3.97},{"code":"RO","value":0.67},{"code":"PL","value":0.98},{"code":"PK","value":1.02},{"code":"AZ","value":0.82},{"code":"NG","value":0.43},{"code":"PH","value":2.16},{"code":"VN","value":1.18},{"code":"CZ","value":0.59},{"code":"PE","value":0.71},{"code":"TH","value":0.9},{"code":"AR","value":2.2},{"code":"CR","value":0.59},{"code":"ES","value":1.61},{"code":"CO","value":1.57},{"code":"MY","value":0.43},{"code":"MX","value":1.77},{"code":"IT","value":0.86},{"code":"AL","value":0.47},{"code":"IR","value":0.55},{"code":"CL","value":0.51},{"code":"ZA","value":0.59},{"code":"IN","value":22.98},{"code":"UZ","value":0.63},{"code":"AE","value":0.59},{"code":"EG","value":0.63},{"code":"EC","value":1.41},{"code":"US","value":1.18},{"code":"CA","value":0.59},{"code":"MK","value":0.47},{"code":"KG","value":10.05},{"code":"ID","value":9.7},{"code":"GB","value":1.14},{"code":"MA","value":0.82},{"code":"SE","value":0.43},{"code":"BR","value":18.5},{"code":"UA","value":1.53},{"code":"HR","value":0.55},{"code":"JP","value":0.9},{"code":"BG","value":0.67},{"code":"PT","value":0.47},{"code":"TW","value":0.43},{"code":"BD","value":0.67},{"code":"NP","value":0.55},{"code":"HU","value":0.43},{"code":"RS","value":0.42}]
/// cities : [{"name":"Hyderabad, Telangana","value":1.56},{"name":"Singapore, Singapore","value":0.78},{"name":"Curitiba, Paraná","value":0.78},{"name":"Bangalore, Karnataka","value":1.95},{"name":"Mumbai, Maharashtra","value":2.73},{"name":"Dubai, Dubai","value":1.3},{"name":"Cairo, Cairo Governorate","value":0.91},{"name":"Santiago, Santiago Metropolitan Region","value":0.78},{"name":"Nagpur, Maharashtra","value":0.65},{"name":"Bandung, West Java","value":0.78},{"name":"Mexico City, Distrito Federal","value":0.65},{"name":"Ankara, Ankara Province","value":0.78},{"name":"Antalya, Antalya Province","value":0.91},{"name":"Chennai, Tamil Nadu","value":0.91},{"name":"Goiânia, Goiás","value":0.65},{"name":"Osh, Osh Region","value":12.61},{"name":"Istanbul, Istanbul Province","value":3.12},{"name":"Ghaziabad, Uttar Pradesh","value":1.3},{"name":"Jaipur, Rajasthan","value":1.04},{"name":"Lima, Lima Region","value":1.69},{"name":"Manila, Metro Manila","value":1.04},{"name":"Gauhati, Assam","value":0.78},{"name":"Lahore, Punjab","value":0.78},{"name":"Tangerang, Banten","value":0.91},{"name":"Delhi, Delhi","value":7.54},{"name":"Guarulhos, São Paulo (state)","value":1.17},{"name":"Baku, Baku","value":1.17},{"name":"Depok, West Java","value":1.95},{"name":"Jakarta, Jakarta","value":5.72},{"name":"Bogotá, Distrito Especial","value":2.21},{"name":"Karachi, Sindh","value":1.17},{"name":"Ludhiana, Punjab region","value":0.65},{"name":"Ahmedabad, Gujarat","value":0.91},{"name":"Lucknow, Uttar Pradesh","value":1.04},{"name":"Navi Mumbai (New Mumbai), Maharashtra","value":0.65},{"name":"Kolkata, West Bengal","value":2.08},{"name":"Rio de Janeiro, Rio de Janeiro (state)","value":1.95},{"name":"Quito, Pichincha Province","value":1.82},{"name":"Guayaquil, Guayas Province","value":1.04},{"name":"Odessa, Odessa Oblast","value":0.91},{"name":"Bishkek, Bishkek","value":18.21},{"name":"São Paulo, São Paulo (state)","value":6.5},{"name":"Dhaka, Dhaka Division","value":1.69},{"name":"Casablanca, Grand Casablanca","value":0.78},{"name":"Kathmandu, Bagmati Zone","value":1.43},{"name":"São Bernardo do Campo, São Paulo (state)","value":0.65},{"name":"Buenos Aires, Ciudad Autónoma de Buenos Aires","value":0.65},{"name":"Quezon City, Metro Manila","value":0.65},{"name":"Ho Chi Minh City, Ho Chi Minh City","value":0.64},{"name":"Pune, Maharashtra","value":0.77},{"name":"Mohali, Punjab region","value":0.64},{"name":"Medan, North Sumatra","value":0.64},{"name":"Rio das Ostras, Rio de Janeiro (state)","value":0.64},{"name":"Banyumas, Central Java","value":0.77},{"name":"Bangkok, Bangkok","value":0.76},{"name":"Porto Alegre, Rio Grande do Sul","value":0.76}]


class RetrieveAudienceDemographics {
  RetrieveAudienceDemographics({
      String? id, 
      String? createdAt, 
      String? updatedAt, 
      User? user, 
      Account? account, 
      WorkPlatform? workPlatform, 
      List<Countries>? countries, 
      List<Cities>? cities, 
      List<GenderAgeDistribution>? genderAgeDistribution,}){
    _id = id;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _user = user;
    _account = account;
    _workPlatform = workPlatform;
    _countries = countries;
    _cities = cities;
    _genderAgeDistribution = genderAgeDistribution;
}

  RetrieveAudienceDemographics.fromJson(dynamic json) {
    _id = json['id'].toString();
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    _account = json['account'] != null ? Account.fromJson(json['account']) : null;
    _workPlatform = json['work_platform'] != null ? WorkPlatform.fromJson(json['work_platform']) : null;
    if (json['countries'] != null) {
      _countries = [];
      json['countries'].forEach((v) {
        _countries?.add(Countries.fromJson(v));
      });
    }
    if (json['cities'] != null) {
      _cities = [];
      json['cities'].forEach((v) {
        _cities?.add(Cities.fromJson(v));
      });
    }
    if (json['gender_age_distribution'] != null) {
      _genderAgeDistribution = [];
      json['gender_age_distribution'].forEach((v) {
        _genderAgeDistribution?.add(GenderAgeDistribution.fromJson(v));
      });
    }
  }
  String? _id;
  String? _createdAt;
  String? _updatedAt;
  User? _user;
  Account? _account;
  WorkPlatform? _workPlatform;
  List<Countries>? _countries;
  List<Cities>? _cities;
  List<GenderAgeDistribution>? _genderAgeDistribution;
RetrieveAudienceDemographics copyWith({  String? id,
  String? createdAt,
  String? updatedAt,
  User? user,
  Account? account,
  WorkPlatform? workPlatform,
  List<Countries>? countries,
  List<Cities>? cities,
  List<GenderAgeDistribution>? genderAgeDistribution,
}) => RetrieveAudienceDemographics(  id: id ?? _id,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
  user: user ?? _user,
  account: account ?? _account,
  workPlatform: workPlatform ?? _workPlatform,
  countries: countries ?? _countries,
  cities: cities ?? _cities,
  genderAgeDistribution: genderAgeDistribution ?? _genderAgeDistribution,
);
  String? get id => _id;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  User? get user => _user;
  Account? get account => _account;
  WorkPlatform? get workPlatform => _workPlatform;
  List<Countries>? get countries => _countries;
  List<Cities>? get cities => _cities;
  List<GenderAgeDistribution>? get genderAgeDistribution => _genderAgeDistribution;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_account != null) {
      map['account'] = _account?.toJson();
    }
    if (_workPlatform != null) {
      map['work_platform'] = _workPlatform?.toJson();
    }
    if (_countries != null) {
      map['countries'] = _countries?.map((v) => v.toJson()).toList();
    }
    if (_cities != null) {
      map['cities'] = _cities?.map((v) => v.toJson()).toList();
    }
    if (_genderAgeDistribution != null) {
      map['gender_age_distribution'] = _genderAgeDistribution?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// gender : "OTHER"
/// age_range : "65-"
/// value : 0.52

class GenderAgeDistribution {
  GenderAgeDistribution({
      String? gender, 
      String? ageRange, 
      num? value,}){
    _gender = gender;
    _ageRange = ageRange;
    _value = value;
}

  GenderAgeDistribution.fromJson(dynamic json) {
    _gender = json['gender'];
    _ageRange = json['age_range'];
    _value = json['value'];
  }
  String? _gender;
  String? _ageRange;
  num? _value;
GenderAgeDistribution copyWith({  String? gender,
  String? ageRange,
  num? value,
}) => GenderAgeDistribution(  gender: gender ?? _gender,
  ageRange: ageRange ?? _ageRange,
  value: value ?? _value,
);
  String? get gender => _gender;
  String? get ageRange => _ageRange;
  num? get value => _value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['gender'] = _gender;
    map['age_range'] = _ageRange;
    map['value'] = _value;
    return map;
  }

}

/// name : "Hyderabad, Telangana"
/// value : 1.56

class Cities {
  Cities({
      String? name, 
      num? value,}){
    _name = name;
    _value = value;
}

  Cities.fromJson(dynamic json) {
    _name = json['name'];
    _value = json['value'];
  }
  String? _name;
  num? _value;
Cities copyWith({  String? name,
  num? value,
}) => Cities(  name: name ?? _name,
  value: value ?? _value,
);
  String? get name => _name;
  num? get value => _value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['value'] = _value;
    return map;
  }

}

/// code : "BA"
/// value : 0.51

class Countries {
  Countries({
      String? code, 
      num? value,}){
    _code = code;
    _value = value;
}

  Countries.fromJson(dynamic json) {
    _code = json['code'];
    _value = json['value'];
  }
  String? _code;
  num? _value;
Countries copyWith({  String? code,
  num? value,
}) => Countries(  code: code ?? _code,
  value: value ?? _value,
);
  String? get code => _code;
  num? get value => _value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    map['value'] = _value;
    return map;
  }

}

/// id : "9bb8913b-ddd9-430b-a66a-d74d846e6c66"
/// name : "Instagram"
/// logo_url : "https://cdn.getphyllo.com/platforms_logo/logos/logo_instagram.png"

class WorkPlatform {
  WorkPlatform({
      String? id, 
      String? name, 
      String? logoUrl,}){
    _id = id;
    _name = name;
    _logoUrl = logoUrl;
}

  WorkPlatform.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _logoUrl = json['logo_url'];
  }
  String? _id;
  String? _name;
  String? _logoUrl;
WorkPlatform copyWith({  String? id,
  String? name,
  String? logoUrl,
}) => WorkPlatform(  id: id ?? _id,
  name: name ?? _name,
  logoUrl: logoUrl ?? _logoUrl,
);
  String? get id => _id;
  String? get name => _name;
  String? get logoUrl => _logoUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['logo_url'] = _logoUrl;
    return map;
  }

}

/// id : "3e113106-afb5-480b-90c3-0ba4e8f807a8"
/// platform_username : "ai4today"
/// username : "ai4today"

class Account {
  Account({
      String? id, 
      String? platformUsername, 
      String? username,}){
    _id = id;
    _platformUsername = platformUsername;
    _username = username;
}

  Account.fromJson(dynamic json) {
    _id = json['id'];
    _platformUsername = json['platform_username'];
    _username = json['username'];
  }
  String? _id;
  String? _platformUsername;
  String? _username;
Account copyWith({  String? id,
  String? platformUsername,
  String? username,
}) => Account(  id: id ?? _id,
  platformUsername: platformUsername ?? _platformUsername,
  username: username ?? _username,
);
  String? get id => _id;
  String? get platformUsername => _platformUsername;
  String? get username => _username;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['platform_username'] = _platformUsername;
    map['username'] = _username;
    return map;
  }

}

/// id : "d59cab3c-afaf-44f1-a04a-f5ac7527d812"
/// name : "Lokesh"

class User {
  User({
      String? id, 
      String? name,}){
    _id = id;
    _name = name;
}

  User.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
  }
  String? _id;
  String? _name;
User copyWith({  String? id,
  String? name,
}) => User(  id: id ?? _id,
  name: name ?? _name,
);
  String? get id => _id;
  String? get name => _name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    return map;
  }

}