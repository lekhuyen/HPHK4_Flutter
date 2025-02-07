import 'package:flutter/material.dart';
import 'package:fe/pages/Auction_ItemsDetailPage.dart';
import 'package:fe/models/Category.dart';
import 'package:fe/models/Auction_Items.dart';
import 'package:fe/services/ApiCategoryService.dart';
import 'package:fe/services/ApiAuction_ItemsService.dart';
import 'package:fe/pages/Auction_ItemsPage.dart';

class CategoryItemPage extends StatefulWidget {
  const CategoryItemPage({super.key});

  @override
  State<StatefulWidget> createState() => _CategoryItemPageState();
}

class _CategoryItemPageState extends State<CategoryItemPage> {
  final ApiCategoryService apiService = ApiCategoryService();
  final ApiAuction_ItemsService auctionService = ApiAuction_ItemsService();
  late Future<List<Category>> futureCategories;
  late Future<List<AuctionItems>> futureAuctionItems;

  @override
  void initState() {
    super.initState();
    futureCategories = apiService.getAllCategory();
    futureAuctionItems = auctionService.getAllAuctionItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Category>>(
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
              return FutureBuilder<List<AuctionItems>>(
                future: futureAuctionItems,
                builder: (context, itemSnapshot) {
                  if (itemSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (itemSnapshot.hasError) {
                    return Center(child: Text('Error: ${itemSnapshot.error}'));
                  }

                  List<AuctionItems> auctionItems = itemSnapshot.data!
                      .where((item) => item.category?.category_id == categories[index].category_id)
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              categories[index].category_name ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Auction_ItemsPage(
                                      category: categories[index],
                                    ),
                                  ),
                                );
                              },
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: auctionItems.length,
                          itemBuilder: (context, itemIndex) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Auction_ItemsDetailPage(
                                      item: auctionItems[itemIndex],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        auctionItems[itemIndex].images?.isNotEmpty ?? false
                                            ? auctionItems[itemIndex].images!.first
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
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
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
    );
  }
}
