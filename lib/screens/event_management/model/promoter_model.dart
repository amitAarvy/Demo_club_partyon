class PromoterModel {
  PromoterModel({
    this.eventPromotionId,
    this.promoterId,
    this.eventPromotionDetailId,
    this.status,
    this.name,
    this.company,
    this.follower,
    this.galleryImages,

  });

  PromoterModel.fromJson(dynamic json) {
    eventPromotionId = json['eventPromotionId'];
    promoterId = json['promoterId'];
    eventPromotionDetailId = json['eventPromotionDetailId'];
    status = json['status'];
    name = json['name'];
    company = json['company'];
    follower = json['follower'];

    galleryImages = json['galleryImages'] != null
        ? json['galleryImages'].cast<String>()
        : [];

  }

  String? eventPromotionId;
  String? promoterId;
  String? eventPromotionDetailId;
  String? status;
  String? name;
  String? company;
  String? follower;
  List? galleryImages;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['eventPromotionId'] = eventPromotionId;
    map['promoterId'] = promoterId;
    map['eventPromotionDetailId'] = eventPromotionDetailId;
    map['status'] = status;
    map['name'] = name;
    map['company'] = company;
    map['follower'] = follower;
    map['galleryImages'] = galleryImages;

    return map;
  }
}
