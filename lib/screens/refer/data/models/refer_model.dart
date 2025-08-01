/// name : ""
/// uid : ""
/// date : ""
/// type : ""

class ReferModel {
  ReferModel({
    String? name,
    String? uid,
    String? date,
    String? type,
  }) {
    _name = name;
    _uid = uid;
    _date = date;
    _type = type;
  }

  ReferModel.fromJson(dynamic json) {
    _name = json['name'];
    _uid = json['uid'];
    _date = json['date'];
    _type = json['type'];
  }

  String? _name;
  String? _uid;
  String? _date;
  String? _type;

  ReferModel copyWith({
    String? name,
    String? uid,
    String? date,
    String? type,
  }) =>
      ReferModel(
        name: name ?? _name,
        uid: uid ?? _uid,
        date: date ?? _date,
        type: type ?? _type,
      );

  String? get name => _name;

  String? get uid => _uid;

  String? get date => _date;

  String? get type => _type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['uid'] = _uid;
    map['date'] = _date;
    map['type'] = _type;
    return map;
  }
}
