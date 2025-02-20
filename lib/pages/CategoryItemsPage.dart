import 'package:flutter/material.dart';
import 'package:fe/pages/Auction_ItemsDetailPage.dart';
import 'package:fe/models/Category.dart';
import 'package:fe/models/Auction_Items.dart';
import 'package:fe/services/ApiCategoryService.dart';
import 'package:fe/services/ApiAuction_ItemsService.dart';
import 'package:fe/pages/Auction_ItemsPage.dart';
import 'package:fe/pages/CategoryItemSearchPage.dart';

import '../models/Auction.dart';
import 'HomePage.dart';

class CategoryItemPage extends StatefulWidget {
  const CategoryItemPage({super.key});

  @override
  State<StatefulWidget> createState() => _CategoryItemPageState();
}

class _CategoryItemPageState extends State<CategoryItemPage> {
  final ApiCategoryService apiService = ApiCategoryService();
  final ApiAuction_ItemsService auctionService = ApiAuction_ItemsService();
  late Future<List<Category>> futureCategories;
  late Future<List<Auction>> futureAuctionItems;
  late Future<List<Auction>> futureAuction;
  @override
  void initState() {
    super.initState();
    futureCategories = apiService.getAllCategory();

    futureAuctionItems = auctionService.getAllAuctionItems();

    futureAuction = auctionService.getAllAuction();
    // futureAuction.then((items) {
    //   print("📡 Fetched Auction Items: ${items.length} items"); // 🔥 Log số lượng item
    //   for (var item in items) {
    //     print("🔍 Item ID:  $item");
    //   }
    // }).catchError((error) {
    //   print("🚨 Error fetching auction items: $error");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Set nền trắng
      appBar: AppBar(
        elevation: 0, // ✅ Xóa bóng dưới AppBar
        backgroundColor: Colors.white, // ✅ Set AppBar màu trắng
        centerTitle: true,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            children: [
              TextSpan(text: "live", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: "auctioneers", style: TextStyle(fontWeight: FontWeight.normal)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryItemSearchPage(),
                  ),
                );
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200], // ✅ Màu nền xám nhạt
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Search items & auction houses",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF005870), // ✅ Màu xanh dương của icon search
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔥 Gạch ngang dưới thanh tìm kiếm
          const Divider(thickness: 1.0, color: Colors.grey),

          // 📌 Hiển thị danh sách danh mục và sản phẩm đấu giá
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: futureCategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories found.'));
                }

                List<Category> categories = snapshot.data!;

                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<List<Auction>>(
                      future: futureAuction,
                      builder: (context, itemSnapshot) {
                        if (itemSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (itemSnapshot.hasError) {
                          return Center(child: Text('Error: ${itemSnapshot.error}'));
                        }

                        List<Auction> auctionItems = itemSnapshot.data!
                            .where((item) => item.category?.category_id == categories[index].category_id)
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔥 Tiêu đề danh mục & "See All"
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    categories[index].category_name ?? '',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Auction_ItemsPage(category: categories[index]),
                                        ),
                                      );
                                    },
                                    child: const Text('See All', style: TextStyle(color: Colors.blue)),
                                  ),
                                ],
                              ),
                            ),

                            // 🔥 Danh sách sản phẩm đấu giá (theo danh mục)
                            SizedBox(
                              height: 250,
                              child: auctionItems.isEmpty
                                  ? const Center(child: Text("No items found."))
                                  : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: auctionItems.length,
                                itemBuilder: (context, itemIndex) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Homepage(initialIndex: 0, selectedItem: auctionItems[itemIndex]),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                      width: 150,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            child: Image.network(
                                              auctionItems[itemIndex].imagesList?.isNotEmpty ?? false
                                                  ? auctionItems[itemIndex].imagesList!.first
                                                  : 'https://via.placeholder.com/150',
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              auctionItems[itemIndex].itemName ?? 'No Name',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );  }
}
