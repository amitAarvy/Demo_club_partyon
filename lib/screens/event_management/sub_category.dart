class SubCategoryModel {
  SubCategoryModel(
    this.entryCategoryName,
    this.entryCategoryCount,
    this.entryCategoryCountLeft,
    this.entryCategoryPrice,
  );

  SubCategoryModel.fromJson(dynamic json) {
    entryCategoryName = json['entryCategoryName'] ?? '';
    entryCategoryCount = json['entryCategoryCount'] ?? 0;
    entryCategoryCountLeft = json['entryCategoryCountLeft'] ?? 0;
    entryCategoryPrice = json['entryCategoryPrice'] ?? 0;
  }

  dynamic entryCategoryName;
  late int entryCategoryCount;
  late int entryCategoryCountLeft;
  late int entryCategoryPrice;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['entryCategoryName'] = entryCategoryName;
    map['entryCategoryCount'] = entryCategoryCount;
    map['entryCategoryCountLeft'] = entryCategoryCountLeft;
    map['entryCategoryPrice'] = entryCategoryPrice;
    return map;
  }
}
