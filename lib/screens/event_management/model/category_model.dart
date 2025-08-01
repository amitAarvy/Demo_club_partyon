class CategoryModel {
  String clubUID;
  String catID;
  String title;

  CategoryModel({
    required this.clubUID,
    required this.catID,
    required this.title,
    
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      clubUID: json['clubUID'],
      catID: json['catID'],
      title: json['title'],
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clubUID': clubUID,
      'catID': catID,
      'title': title,
    
    };
  }
}