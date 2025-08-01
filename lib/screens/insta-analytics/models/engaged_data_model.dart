/// data : [{"name":"engaged_audience_demographics","period":"lifetime","title":"Engaged audience demographics","description":"The demographic characteristics of the engaged audience, including countries, cities and gender distribution.","total_value":{"breakdowns":[{"dimension_keys":["city"],"results":[{"dimension_values":["Bhinmal, Rajasthan"],"value":1},{"dimension_values":["São Paulo, São Paulo (state)"],"value":3},{"dimension_values":["Jacksonville, Florida"],"value":6},{"dimension_values":["Batam, Riau Islands Province"],"value":1},{"dimension_values":["Muara, West Sumatra"],"value":1},{"dimension_values":["Pematangpanggang, South Sumatra"],"value":1},{"dimension_values":["Saint Petersburg, Florida"],"value":3},{"dimension_values":["Kolkata, West Bengal"],"value":1},{"dimension_values":["Maceió, Alagoas"],"value":2},{"dimension_values":["Taldykorgan, Almaty Region"],"value":2},{"dimension_values":["Pskent, Tashkent Region"],"value":1},{"dimension_values":["Cikupa, Banten"],"value":1},{"dimension_values":["Vientiane, Vientiane Prefecture"],"value":1},{"dimension_values":["Cikarang, West Java"],"value":1},{"dimension_values":["Campo Erê, Santa Catarina"],"value":1},{"dimension_values":["Imbituba, Santa Catarina"],"value":1},{"dimension_values":["Jakarta, Jakarta"],"value":1},{"dimension_values":["Dushanbe, Districts of Republican Subordination"],"value":1},{"dimension_values":["Port Saint Lucie, Florida"],"value":2},{"dimension_values":["Ho Chi Minh City, Ho Chi Minh City"],"value":3},{"dimension_values":["Delhi, Delhi"],"value":1},{"dimension_values":["Gurugram, Haryana"],"value":1},{"dimension_values":["Kingston, Saint Andrew Parish"],"value":1},{"dimension_values":["Palmas, Tocantins"],"value":1},{"dimension_values":["Vera y Pintado, Santa Fe"],"value":1},{"dimension_values":["Morro do Chapéu do Piauí, Piauí"],"value":1},{"dimension_values":["Kaskelen, Almaty Region"],"value":2},{"dimension_values":["Wamba, Nasarawa State"],"value":1},{"dimension_values":["Türkistan, South Kazakhstan Region"],"value":2},{"dimension_values":["Ben Cat, Bình Dương Province"],"value":2},{"dimension_values":["Nhu Ang, Thanh Hóa Province"],"value":1},{"dimension_values":["Tampa, Florida"],"value":5},{"dimension_values":["Basavakalyan, Karnataka"],"value":1},{"dimension_values":["San Miguel de Tucumán, Tucuman"],"value":2},{"dimension_values":["Champasak, Champasak Province"],"value":1},{"dimension_values":["Três Lagoas, Mato Grosso do Sul"],"value":1},{"dimension_values":["Kibray, Tashkent Region"],"value":2},{"dimension_values":["Santo André, São Paulo (state)"],"value":1},{"dimension_values":["Salar, Tashkent Region"],"value":2},{"dimension_values":["Cape Coral, Florida"],"value":9},{"dimension_values":["Paulínia, São Paulo (state)"],"value":1},{"dimension_values":["Chorwoq, Tashkent Region"],"value":1},{"dimension_values":["Taraz, Jambyl Region"],"value":2},{"dimension_values":["Tashkent, Tashkent Region"],"value":3},{"dimension_values":["Caloocan, Metro Manila"],"value":1}]}]},"id":"17841465310046401/insights/engaged_audience_demographics/lifetime"}]

class EngagedDataModel {
  EngagedDataModel({
      List<Data>? data,}){
    _data = data;
}

  EngagedDataModel.fromJson(dynamic json) {
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  List<Data>? _data;
EngagedDataModel copyWith({  List<Data>? data,
}) => EngagedDataModel(  data: data ?? _data,
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

/// name : "engaged_audience_demographics"
/// period : "lifetime"
/// title : "Engaged audience demographics"
/// description : "The demographic characteristics of the engaged audience, including countries, cities and gender distribution."
/// total_value : {"breakdowns":[{"dimension_keys":["city"],"results":[{"dimension_values":["Bhinmal, Rajasthan"],"value":1},{"dimension_values":["São Paulo, São Paulo (state)"],"value":3},{"dimension_values":["Jacksonville, Florida"],"value":6},{"dimension_values":["Batam, Riau Islands Province"],"value":1},{"dimension_values":["Muara, West Sumatra"],"value":1},{"dimension_values":["Pematangpanggang, South Sumatra"],"value":1},{"dimension_values":["Saint Petersburg, Florida"],"value":3},{"dimension_values":["Kolkata, West Bengal"],"value":1},{"dimension_values":["Maceió, Alagoas"],"value":2},{"dimension_values":["Taldykorgan, Almaty Region"],"value":2},{"dimension_values":["Pskent, Tashkent Region"],"value":1},{"dimension_values":["Cikupa, Banten"],"value":1},{"dimension_values":["Vientiane, Vientiane Prefecture"],"value":1},{"dimension_values":["Cikarang, West Java"],"value":1},{"dimension_values":["Campo Erê, Santa Catarina"],"value":1},{"dimension_values":["Imbituba, Santa Catarina"],"value":1},{"dimension_values":["Jakarta, Jakarta"],"value":1},{"dimension_values":["Dushanbe, Districts of Republican Subordination"],"value":1},{"dimension_values":["Port Saint Lucie, Florida"],"value":2},{"dimension_values":["Ho Chi Minh City, Ho Chi Minh City"],"value":3},{"dimension_values":["Delhi, Delhi"],"value":1},{"dimension_values":["Gurugram, Haryana"],"value":1},{"dimension_values":["Kingston, Saint Andrew Parish"],"value":1},{"dimension_values":["Palmas, Tocantins"],"value":1},{"dimension_values":["Vera y Pintado, Santa Fe"],"value":1},{"dimension_values":["Morro do Chapéu do Piauí, Piauí"],"value":1},{"dimension_values":["Kaskelen, Almaty Region"],"value":2},{"dimension_values":["Wamba, Nasarawa State"],"value":1},{"dimension_values":["Türkistan, South Kazakhstan Region"],"value":2},{"dimension_values":["Ben Cat, Bình Dương Province"],"value":2},{"dimension_values":["Nhu Ang, Thanh Hóa Province"],"value":1},{"dimension_values":["Tampa, Florida"],"value":5},{"dimension_values":["Basavakalyan, Karnataka"],"value":1},{"dimension_values":["San Miguel de Tucumán, Tucuman"],"value":2},{"dimension_values":["Champasak, Champasak Province"],"value":1},{"dimension_values":["Três Lagoas, Mato Grosso do Sul"],"value":1},{"dimension_values":["Kibray, Tashkent Region"],"value":2},{"dimension_values":["Santo André, São Paulo (state)"],"value":1},{"dimension_values":["Salar, Tashkent Region"],"value":2},{"dimension_values":["Cape Coral, Florida"],"value":9},{"dimension_values":["Paulínia, São Paulo (state)"],"value":1},{"dimension_values":["Chorwoq, Tashkent Region"],"value":1},{"dimension_values":["Taraz, Jambyl Region"],"value":2},{"dimension_values":["Tashkent, Tashkent Region"],"value":3},{"dimension_values":["Caloocan, Metro Manila"],"value":1}]}]}
/// id : "17841465310046401/insights/engaged_audience_demographics/lifetime"

class Data {
  Data({
      String? name, 
      String? period, 
      String? title, 
      String? description, 
      TotalValue? totalValue, 
      String? id,}){
    _name = name;
    _period = period;
    _title = title;
    _description = description;
    _totalValue = totalValue;
    _id = id;
}

  Data.fromJson(dynamic json) {
    _name = json['name'];
    _period = json['period'];
    _title = json['title'];
    _description = json['description'];
    _totalValue = json['total_value'] != null ? TotalValue.fromJson(json['total_value']) : null;
    _id = json['id'];
  }
  String? _name;
  String? _period;
  String? _title;
  String? _description;
  TotalValue? _totalValue;
  String? _id;
Data copyWith({  String? name,
  String? period,
  String? title,
  String? description,
  TotalValue? totalValue,
  String? id,
}) => Data(  name: name ?? _name,
  period: period ?? _period,
  title: title ?? _title,
  description: description ?? _description,
  totalValue: totalValue ?? _totalValue,
  id: id ?? _id,
);
  String? get name => _name;
  String? get period => _period;
  String? get title => _title;
  String? get description => _description;
  TotalValue? get totalValue => _totalValue;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['period'] = _period;
    map['title'] = _title;
    map['description'] = _description;
    if (_totalValue != null) {
      map['total_value'] = _totalValue?.toJson();
    }
    map['id'] = _id;
    return map;
  }

}

/// breakdowns : [{"dimension_keys":["city"],"results":[{"dimension_values":["Bhinmal, Rajasthan"],"value":1},{"dimension_values":["São Paulo, São Paulo (state)"],"value":3},{"dimension_values":["Jacksonville, Florida"],"value":6},{"dimension_values":["Batam, Riau Islands Province"],"value":1},{"dimension_values":["Muara, West Sumatra"],"value":1},{"dimension_values":["Pematangpanggang, South Sumatra"],"value":1},{"dimension_values":["Saint Petersburg, Florida"],"value":3},{"dimension_values":["Kolkata, West Bengal"],"value":1},{"dimension_values":["Maceió, Alagoas"],"value":2},{"dimension_values":["Taldykorgan, Almaty Region"],"value":2},{"dimension_values":["Pskent, Tashkent Region"],"value":1},{"dimension_values":["Cikupa, Banten"],"value":1},{"dimension_values":["Vientiane, Vientiane Prefecture"],"value":1},{"dimension_values":["Cikarang, West Java"],"value":1},{"dimension_values":["Campo Erê, Santa Catarina"],"value":1},{"dimension_values":["Imbituba, Santa Catarina"],"value":1},{"dimension_values":["Jakarta, Jakarta"],"value":1},{"dimension_values":["Dushanbe, Districts of Republican Subordination"],"value":1},{"dimension_values":["Port Saint Lucie, Florida"],"value":2},{"dimension_values":["Ho Chi Minh City, Ho Chi Minh City"],"value":3},{"dimension_values":["Delhi, Delhi"],"value":1},{"dimension_values":["Gurugram, Haryana"],"value":1},{"dimension_values":["Kingston, Saint Andrew Parish"],"value":1},{"dimension_values":["Palmas, Tocantins"],"value":1},{"dimension_values":["Vera y Pintado, Santa Fe"],"value":1},{"dimension_values":["Morro do Chapéu do Piauí, Piauí"],"value":1},{"dimension_values":["Kaskelen, Almaty Region"],"value":2},{"dimension_values":["Wamba, Nasarawa State"],"value":1},{"dimension_values":["Türkistan, South Kazakhstan Region"],"value":2},{"dimension_values":["Ben Cat, Bình Dương Province"],"value":2},{"dimension_values":["Nhu Ang, Thanh Hóa Province"],"value":1},{"dimension_values":["Tampa, Florida"],"value":5},{"dimension_values":["Basavakalyan, Karnataka"],"value":1},{"dimension_values":["San Miguel de Tucumán, Tucuman"],"value":2},{"dimension_values":["Champasak, Champasak Province"],"value":1},{"dimension_values":["Três Lagoas, Mato Grosso do Sul"],"value":1},{"dimension_values":["Kibray, Tashkent Region"],"value":2},{"dimension_values":["Santo André, São Paulo (state)"],"value":1},{"dimension_values":["Salar, Tashkent Region"],"value":2},{"dimension_values":["Cape Coral, Florida"],"value":9},{"dimension_values":["Paulínia, São Paulo (state)"],"value":1},{"dimension_values":["Chorwoq, Tashkent Region"],"value":1},{"dimension_values":["Taraz, Jambyl Region"],"value":2},{"dimension_values":["Tashkent, Tashkent Region"],"value":3},{"dimension_values":["Caloocan, Metro Manila"],"value":1}]}]

class TotalValue {
  TotalValue({
      List<Breakdowns>? breakdowns,}){
    _breakdowns = breakdowns;
}

  TotalValue.fromJson(dynamic json) {
    if (json['breakdowns'] != null) {
      _breakdowns = [];
      json['breakdowns'].forEach((v) {
        _breakdowns?.add(Breakdowns.fromJson(v));
      });
    }
  }
  List<Breakdowns>? _breakdowns;
TotalValue copyWith({  List<Breakdowns>? breakdowns,
}) => TotalValue(  breakdowns: breakdowns ?? _breakdowns,
);
  List<Breakdowns>? get breakdowns => _breakdowns;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_breakdowns != null) {
      map['breakdowns'] = _breakdowns?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// dimension_keys : ["city"]
/// results : [{"dimension_values":["Bhinmal, Rajasthan"],"value":1},{"dimension_values":["São Paulo, São Paulo (state)"],"value":3},{"dimension_values":["Jacksonville, Florida"],"value":6},{"dimension_values":["Batam, Riau Islands Province"],"value":1},{"dimension_values":["Muara, West Sumatra"],"value":1},{"dimension_values":["Pematangpanggang, South Sumatra"],"value":1},{"dimension_values":["Saint Petersburg, Florida"],"value":3},{"dimension_values":["Kolkata, West Bengal"],"value":1},{"dimension_values":["Maceió, Alagoas"],"value":2},{"dimension_values":["Taldykorgan, Almaty Region"],"value":2},{"dimension_values":["Pskent, Tashkent Region"],"value":1},{"dimension_values":["Cikupa, Banten"],"value":1},{"dimension_values":["Vientiane, Vientiane Prefecture"],"value":1},{"dimension_values":["Cikarang, West Java"],"value":1},{"dimension_values":["Campo Erê, Santa Catarina"],"value":1},{"dimension_values":["Imbituba, Santa Catarina"],"value":1},{"dimension_values":["Jakarta, Jakarta"],"value":1},{"dimension_values":["Dushanbe, Districts of Republican Subordination"],"value":1},{"dimension_values":["Port Saint Lucie, Florida"],"value":2},{"dimension_values":["Ho Chi Minh City, Ho Chi Minh City"],"value":3},{"dimension_values":["Delhi, Delhi"],"value":1},{"dimension_values":["Gurugram, Haryana"],"value":1},{"dimension_values":["Kingston, Saint Andrew Parish"],"value":1},{"dimension_values":["Palmas, Tocantins"],"value":1},{"dimension_values":["Vera y Pintado, Santa Fe"],"value":1},{"dimension_values":["Morro do Chapéu do Piauí, Piauí"],"value":1},{"dimension_values":["Kaskelen, Almaty Region"],"value":2},{"dimension_values":["Wamba, Nasarawa State"],"value":1},{"dimension_values":["Türkistan, South Kazakhstan Region"],"value":2},{"dimension_values":["Ben Cat, Bình Dương Province"],"value":2},{"dimension_values":["Nhu Ang, Thanh Hóa Province"],"value":1},{"dimension_values":["Tampa, Florida"],"value":5},{"dimension_values":["Basavakalyan, Karnataka"],"value":1},{"dimension_values":["San Miguel de Tucumán, Tucuman"],"value":2},{"dimension_values":["Champasak, Champasak Province"],"value":1},{"dimension_values":["Três Lagoas, Mato Grosso do Sul"],"value":1},{"dimension_values":["Kibray, Tashkent Region"],"value":2},{"dimension_values":["Santo André, São Paulo (state)"],"value":1},{"dimension_values":["Salar, Tashkent Region"],"value":2},{"dimension_values":["Cape Coral, Florida"],"value":9},{"dimension_values":["Paulínia, São Paulo (state)"],"value":1},{"dimension_values":["Chorwoq, Tashkent Region"],"value":1},{"dimension_values":["Taraz, Jambyl Region"],"value":2},{"dimension_values":["Tashkent, Tashkent Region"],"value":3},{"dimension_values":["Caloocan, Metro Manila"],"value":1}]

class Breakdowns {
  Breakdowns({
      List<String>? dimensionKeys, 
      List<Results>? results,}){
    _dimensionKeys = dimensionKeys;
    _results = results;
}

  Breakdowns.fromJson(dynamic json) {
    _dimensionKeys = json['dimension_keys'] != null ? json['dimension_keys'].cast<String>() : [];
    if (json['results'] != null) {
      _results = [];
      json['results'].forEach((v) {
        _results?.add(Results.fromJson(v));
      });
    }
  }
  List<String>? _dimensionKeys;
  List<Results>? _results;
Breakdowns copyWith({  List<String>? dimensionKeys,
  List<Results>? results,
}) => Breakdowns(  dimensionKeys: dimensionKeys ?? _dimensionKeys,
  results: results ?? _results,
);
  List<String>? get dimensionKeys => _dimensionKeys;
  List<Results>? get results => _results;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['dimension_keys'] = _dimensionKeys;
    if (_results != null) {
      map['results'] = _results?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// dimension_values : ["Bhinmal, Rajasthan"]
/// value : 1

class Results {
  Results({
      List<String>? dimensionValues, 
      num? value,}){
    _dimensionValues = dimensionValues;
    _value = value;
}

  Results.fromJson(dynamic json) {
    _dimensionValues = json['dimension_values'] != null ? json['dimension_values'].cast<String>() : [];
    _value = json['value'];
  }
  List<String>? _dimensionValues;
  num? _value;
Results copyWith({  List<String>? dimensionValues,
  num? value,
}) => Results(  dimensionValues: dimensionValues ?? _dimensionValues,
  value: value ?? _value,
);
  List<String>? get dimensionValues => _dimensionValues;
  num? get value => _value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['dimension_values'] = _dimensionValues;
    map['value'] = _value;
    return map;
  }

}