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
    bool? paid; // ✅ Thêm trường paid để kiểm tra đã thanh toán hay chưa

    // Add categoryId and categoryName as separate fields
    int? categoryId;
    String? categoryName;  // For the category name

    // Add category as a field of type Category
    Category? category;

    AuctionItems({
      this.paid, // ✅ Thêm vào constructor

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
      map["ispaid"] = paid; // ✅ Thêm vào JSON serialization

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
      currentPrice = json["current_price"] != null
          ? double.tryParse(json["current_price"].toString()) // ✅ Chuyển E notation thành double
          : null;

      if (json["start_date"] is String) {
        startDate = DateTime.parse(json["start_date"]);  // ✅ Chuyển đổi String thành DateTime
      } else {
        startDate = null;
      }

      if (json["end_date"] is String) {
        endDate = DateTime.parse(json["end_date"]);
      } else {
        endDate = null;
      }

      bidStep = json["bid_step"];
      issell = json["sell"];
      paid = json["paid"] ?? false; // ✅ Đọc giá trị paid từ API

      status = json["status"];
      issoldout = json["soldout"];
      width = json["width"];
      height = json["height"];

      // ✅ Kiểm tra createdAt và updatedAt trước khi parse
      if (json["createdAt"] != null) {
        createdat = DateTime.tryParse(json["createdAt"].toString());
      }

      if (json["updatedAt"] != null) {
        updatedat = DateTime.tryParse(json["updatedAt"].toString());
      }

      images = json["images"] != null ? List<String>.from(json["images"]) : [];

      if (json['category'] != null) {
        category = Category.fromJson(json['category']);
      }

      categoryId = json['category'] != null ? json['category']['category_id'] : null;
      categoryName = json['category'] != null ? json['category']['category_name'] : null;
    }
  }
