class CouponModel {
  String? _couponCategory;
  String? _discount;
  String? _validFrom;
  String? _validTill;
  String? _couponCode;
  String? _uid;
  String? _type;

  CouponModel({
    String? couponCategory,
    String? discount,
    String? validFrom,
    String? validTill,
    String? couponCode,
    String? uid,
    String? type,
  }) {
    _couponCategory = couponCategory;
    _discount = discount;
    _validFrom = validFrom;
    _validTill = validTill;
    _couponCode = couponCode;
    _uid = uid;
    _type = type;
  }

  CouponModel.fromJson(dynamic json) {
    _couponCategory = json['couponCategory'];
    _discount = json['discount'];
    _validFrom = json['validFrom'];
    _validTill = json['validTill'];
    _couponCode = json['couponCode'];
    _uid = json['uid'];
    _type = json['type'];
  }

  CouponModel copyWith({
    String? couponCategory,
    String? discount,
    String? validFrom,
    String? validTill,
    String? couponCode,
    String? uid,
    String? type,
  }) =>
      CouponModel(
        couponCategory: couponCategory ?? _couponCategory,
        discount: discount ?? _discount,
        validFrom: validFrom ?? _validFrom,
        validTill: validTill ?? _validTill,
        couponCode: couponCode ?? _couponCode,
        uid: uid ?? _uid,
        type: type ?? _type,
      );

  String? get couponCategory => _couponCategory;
  String? get discount => _discount;
  String? get validFrom => _validFrom;
  String? get validTill => _validTill;
  String? get couponCode => _couponCode;
  String? get uid => _uid;
  String? get type => _type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['couponCategory'] = _couponCategory;
    map['discount'] = _discount;
    map['validFrom'] = _validFrom;
    map['validTill'] = _validTill;
    map['couponCode'] = _couponCode;
    map['uid'] = _uid;
    map['type'] = _type;
    return map;
  }
}