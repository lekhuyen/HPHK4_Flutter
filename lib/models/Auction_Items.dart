  import 'Category.dart';

  class AuctionItems {
    int? itemId;
    String? itemName;
    String? description;
    double? startingPrice;
    double? currentPrice;
    DateTime? startDate;
    DateTime? endDate;
    String? bidStep;
    bool? issell;
    bool? status;
    bool? issoldout;
    double? width;
    double? height;
    DateTime? createdat;
    DateTime? updatedat;
    List<String>? images;

    // Add categoryId and categoryName as separate fields
    int? categoryId;
    String? categoryName;  // For the category name

    // Add category as a field of type Category
    Category? category;

    AuctionItems({
      this.itemId,
      this.itemName,
      this.description,
      this.startingPrice,
      this.currentPrice,
      this.startDate,
      this.endDate,
      this.bidStep,
      this.issell,
      this.status,
      this.issoldout,
      this.width,
      this.height,
      this.createdat,
      this.updatedat,
      this.images,
      this.categoryId,
      this.categoryName,
      this.category,  // Include category in the constructor
    });

    Map<String, dynamic> toJson() {
      final map = <String, dynamic>{};
      map["item_id"] = itemId;
      map["item_name"] = itemName;
      map["description"] = description;
      map["starting_price"] = startingPrice;
      map["current_price"] = currentPrice;
      map["start_date"] = startDate?.toIso8601String();
      map["end_date"] = endDate?.toIso8601String();
      map["bid_step"] = bidStep;
      map["isSell"] = issell;
      map["status"] = status;
      map["isSoldout"] = issoldout;
      map["width"] = width;
      map["height"] = height;
      map["createdAt"] = createdat?.toIso8601String();
      map["updatedAt"] = updatedat?.toIso8601String();
      map["images"] = images;

      // Include categoryId and categoryName in the JSON serialization
      map["category_id"] = categoryId;
      map["category_name"] = categoryName;

      // Convert category object to JSON (if it's available)
      if (category != null) {
        map["category"] = category?.toJson();
      }

      return map;
    }

    // Update the fromJson constructor to handle category properly
    AuctionItems.fromJson(Map<String, dynamic> json) {
      itemId = json["item_id"];
      itemName = json["item_name"];
      description = json["description"];
      startingPrice = json["starting_price"];
      currentPrice = json["current_price"];

      // Handle the startDate and endDate as a list and convert to DateTime
      startDate = json["start_date"] != null
          ? DateTime(json["start_date"][0], json["start_date"][1], json["start_date"][2])
          : null;
      endDate = json["end_date"] != null
          ? DateTime(json["end_date"][0], json["end_date"][1], json["end_date"][2])
          : null;

      bidStep = json["bid_step"];
      issell = json["sell"];
      status = json["status"];
      issoldout = json["soldout"];
      width = json["width"];
      height = json["height"];

      // Convert string date to DateTime objects for createdAt and updatedAt
      createdat = json["createdAt"] != null ? DateTime.parse(json["createdAt"].toString()) : null;
      updatedat = json["updatedAt"] != null ? DateTime.parse(json["updatedAt"].toString()) : null;

      // Handling images as List<String>
      images = json["images"] != null ? List<String>.from(json["images"]) : [];

      // Handle category as an instance of Category
      if (json['category'] != null) {
        category = Category.fromJson(json['category']);
      }

      // Optionally, if you want to also keep categoryId and categoryName separately
      categoryId = json['category'] != null ? json['category']['category_id'] : null;
      categoryName = json['category'] != null ? json['category']['category_name'] : null;
    }
  }
