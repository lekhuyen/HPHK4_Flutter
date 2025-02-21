import 'package:fe/models/Auction_Items.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiAuction_ItemsService {
  static const String url = "http://192.168.1.20:8080/api";
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

  static Future<List<AuctionItems>> getAuctionItemsBySearch(String query) async {
    try {
      final response = await http.get(Uri.parse("$urlAuctionItems/search?query=$query"));
      print("Searching auction items with query: $query");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<AuctionItems> searchResults = [];

        if (jsonData['result'] != null) {
          List data = jsonData['result']['data'];
          for (var item in data) {
            try {
              searchResults.add(AuctionItems.fromJson(item));
            } catch (e) {
              print("Error parsing search item: $e");
            }
          }
        }
        return searchResults;
      } else {
        throw Exception('Failed to search auction items');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('Error searching auction items: $e');
    }
  }
}

