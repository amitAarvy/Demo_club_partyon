/// data : [{"name":"impressions","period":"lifetime","values":[{"value":0}],"title":"Impressions","description":"The number of times that your post was on screen.","id":"18035502233201033/insights/impressions/lifetime"},{"name":"reach","period":"lifetime","values":[{"value":0}],"title":"Accounts reached","description":"The number of unique accounts that have seen this post at least once. Reach is different from impressions, which may include multiple views of your post by the same accounts. This metric is estimated.","id":"18035502233201033/insights/reach/lifetime"},{"name":"saved","period":"lifetime","values":[{"value":0}],"title":"Saved","description":"The number of saves of your post.","id":"18035502233201033/insights/saved/lifetime"},{"name":"likes","period":"lifetime","values":[{"value":1}],"title":"Likes","description":"The number of likes on your post.","id":"18035502233201033/insights/likes/lifetime"},{"name":"comments","period":"lifetime","values":[{"value":0}],"title":"Comments","description":"The number of comments on your post.","id":"18035502233201033/insights/comments/lifetime"}]

class InstagramMediaModel {
  InstagramMediaModel({
      List<Data>? data,}){
    _data = data;
}

  InstagramMediaModel.fromJson(dynamic json) {
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  List<Data>? _data;
InstagramMediaModel copyWith({  List<Data>? data,
}) => InstagramMediaModel(  data: data ?? _data,
);
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// name : "impressions"
/// period : "lifetime"
/// values : [{"value":0}]
/// title : "Impressions"
/// description : "The number of times that your post was on screen."
/// id : "18035502233201033/insights/impressions/lifetime"

class Data {
  Data({
      String? name, 
      String? period, 
      List<Values>? values, 
      String? title, 
      String? description, 
      String? id,}){
    _name = name;
    _period = period;
    _values = values;
    _title = title;
    _description = description;
    _id = id;
}

  Data.fromJson(dynamic json) {
    _name = json['name'];
    _period = json['period'];
    if (json['values'] != null) {
      _values = [];
      json['values'].forEach((v) {
        _values?.add(Values.fromJson(v));
      });
    }
    _title = json['title'];
    _description = json['description'];
    _id = json['id'];
  }
  String? _name;
  String? _period;
  List<Values>? _values;
  String? _title;
  String? _description;
  String? _id;
Data copyWith({  String? name,
  String? period,
  List<Values>? values,
  String? title,
  String? description,
  String? id,
}) => Data(  name: name ?? _name,
  period: period ?? _period,
  values: values ?? _values,
  title: title ?? _title,
  description: description ?? _description,
  id: id ?? _id,
);
  String? get name => _name;
  String? get period => _period;
  List<Values>? get values => _values;
  String? get title => _title;
  String? get description => _description;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['period'] = _period;
    if (_values != null) {
      map['values'] = _values?.map((v) => v.toJson()).toList();
    }
    map['title'] = _title;
    map['description'] = _description;
    map['id'] = _id;
    return map;
  }

}

/// value : 0

class Values {
  Values({
      num? value,}){
    _value = value;
}

  Values.fromJson(dynamic json) {
    _value = json['value'];
  }
  num? _value;
Values copyWith({  num? value,
}) => Values(  value: value ?? _value,
);
  num? get value => _value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['value'] = _value;
    return map;
  }

}