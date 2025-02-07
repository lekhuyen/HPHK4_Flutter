class Category {
  int? category_id;
  String? category_name;
  String? description;
  DateTime? createdat;
  DateTime? updateat;

  Category(
      {this.category_id, this.category_name, this.description, this.createdat, this.updateat});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["category_id"] = category_id;
    map["category_name"] = category_name;
    map["description"] = description;
    map["createdAt"] = createdat?.toIso8601String();
    map["updateAt"] = updateat?.toIso8601String();
    return map;
  }

  Category.fromJson(dynamic json) {
    category_id = json["category_id"];
    category_name = json["category_name"];
    description = json["description"];
    createdat = json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null;
    updateat = json["updateAt"] != null ? DateTime.parse(json["updateAt"]) : null;
  }
}
