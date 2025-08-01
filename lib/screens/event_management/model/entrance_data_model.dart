import '../sub_category.dart';

class EntranceDataModel {

  EntranceDataModel(
      this.categoryName,
      this.subCategory,
      );

  EntranceDataModel.fromJson(dynamic json) {
    categoryName = json['categoryName'];
    if (json['subCategory'] != null) {
      subCategory = [];
      json['subCategory'].forEach((v) {
        subCategory.add(SubCategoryModel.fromJson(v));
      });
    }
  }

  String categoryName='';
  List<SubCategoryModel> subCategory=[];

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['categoryName'] = categoryName;
    if (subCategory.isNotEmpty) {
      map['subCategory'] = subCategory.map((v) => v.toJson()).toList();
    }
    return map;
  }

}