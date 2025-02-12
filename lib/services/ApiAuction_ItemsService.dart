import 'package:fe/models/Auction_Items.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiAuction_ItemsService {
  static const String url = "http://173.16.17.55:8080/api";
  static const String urlAuctionItems = "$url/auction";

  Future<List<AuctionItems>> getAllAuctionItems() async {
    try {
      int currentPage = 1;
      int totalPages = 1; // Will update dynamically
      List<AuctionItems> allItems = [];

      do {
        final response = await http.get(Uri.parse('$urlAuctionItems?page=$currentPage&pageSize=3'));
        print("Fetching page $currentPage: ${response.statusCode}");

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);

          if (jsonData['result'] != null) {
            totalPages = jsonData['result']['totalPages']; // Update total pages
            List data = jsonData['result']['data'];

            for (var item in data) {
              try {
                AuctionItems auctionItem = AuctionItems.fromJson(item);
                allItems.add(auctionItem);
                print("Added: ${auctionItem.itemName}");
              } catch (e) {
                print("Error parsing auction item: $e");
              }
            }
          }
        } else {
          throw Exception('Failed to load auction items');
        }

        currentPage++;
      } while (currentPage <= totalPages); // Loop through all pages

      print("Total auction items fetched: ${allItems.length}");
      return allItems;
    } catch (e) {
      print("Error: $e");
      throw Exception('Error fetching auctionItems data: $e');
    }
  }


  Future<List<AuctionItems>> getAllAuctionItemsn() async {
    try {
      final response = await http.get(Uri.parse(urlAuctionItems));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<AuctionItems> list = [];

        print("Decoded auction items data: $data");

        for (var item in data['result']['data']) { // Adjust the data path based on your actual JSON structure
          AuctionItems auctionItems = AuctionItems.fromJson(item);
          list.add(auctionItems);
        }
        print("Fetched ${list.length} auction items.");
        return list;
      } else {
        print("Error: ${response.body}");
        throw Exception('Failed to load auction items data');
      }
    } catch (e) {
      print("Error fetching auction items data: $e");
      throw Exception('Error fetching auction items data: $e');
    }
  }


  Future<AuctionItems?> getAuctionItemById(int id) async {
    try {
      print("Sending GET request to: $urlAuctionItems/$id");

      final response = await http.get(Uri.parse("$urlAuctionItems/$id"));

      print("Received response with status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Response body: ${response.body}");

        var jsonData = json.decode(response.body);
        print("Decoded JSON data: $jsonData");

        // Check if the response contains data (may be an object or array depending on the API design)
        if (jsonData != null) {
          // Parse the data into AuctionItems object
          try {
            return AuctionItems.fromJson(jsonData);
          } catch (e) {
            print("Error parsing auction item: $e");
            return null; // Return null if parsing fails
          }
        } else {
          print("Error: Response data is null.");
          return null;
        }
      } else if (response.statusCode == 404) {
        print("Auction item with ID $id not found.");
        return null; // Return null if the item is not found (404)
      } else {
        print("Error response body: ${response.body}");
        throw Exception('Failed to load auction item. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching auction item by ID: $e");
      throw Exception('Error fetching auction item by ID: $e');
    }
  }

  Future<List<AuctionItems>> fetchFeaturedAuctions() async {
    final response = await http.get(Uri.parse('$urlAuctionItems/featured'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['result'];
      return data.map((item) => AuctionItems.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load featured auctions");
    }
  }

  Future<List<AuctionItems>> fetchUpcomingAuctions() async {
    final response = await http.get(Uri.parse('$urlAuctionItems/upcoming'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['result'];
      return data.map((item) => AuctionItems.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load upcoming auctions");
    }
  }
  Future<List<AuctionItems>> getItemsByCategory(String categoryId) async {
    try {
      final response = await http.get(Uri.parse('$urlAuctionItems/category/$categoryId?size=100'));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<AuctionItems> list = [];

        if (jsonData['result'] != null) {
          for (var item in jsonData['result']['data']) {
            AuctionItems auctionItem = AuctionItems.fromJson(item);
            list.add(auctionItem);
          }
        }
        print("✅ Fetched ${list.length} items from category $categoryId");
        return list;
      } else {
        throw Exception('Failed to load items by category');
      }
    } catch (e) {
      print("🚨 Error fetching items by category: $e");
      throw Exception('Error fetching items by category: $e');
    }
  }


  Future<int?> getCategoryIdByName(String categoryName) async {
    final response = await http.get(Uri.parse('http://173.16.17.55:8080/api/category'));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData['result'] != null && jsonData['result']['data'] != null) {
        List<dynamic> categories = jsonData['result']['data'];

        for (var category in categories) {
          String? apiCategoryName = category['category_name']; // Đọc đúng key từ API

          if (apiCategoryName != null && apiCategoryName.trim() == categoryName.trim()) {
            return category['category_id']; // Trả về ID nếu tìm thấy
          }
        }
      }
    }
    print("⚠️ Không tìm thấy category ID cho $categoryName");
    return null;
  }

  Future<List<AuctionItems>> fetchAuctionsByCreator(String userId) async {
    final response = await http.get(Uri.parse('http://173.16.17.55:8080/api/auction/creator/$userId'));

    print("📢 API RESPONSE STATUS: ${response.statusCode}");
    print("📢 API BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("📢 JSON Result: ${data['result']}"); // ✅ In dữ liệu trả về trước khi parse

      return (data['result'] as List).map((item) {
        print("📢 Item Data: $item"); // ✅ In từng item trước khi parse
        return AuctionItems.fromJson(item);
      }).toList();
    } else {
      throw Exception("API Error: ${response.statusCode} - ${response.body}");
    }
  }






}

