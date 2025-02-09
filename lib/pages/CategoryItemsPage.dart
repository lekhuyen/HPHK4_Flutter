import 'package:flutter/material.dart';
import 'package:fe/pages/Auction_ItemsDetailPage.dart';
import 'package:fe/models/Category.dart';
import 'package:fe/models/Auction_Items.dart';
import 'package:fe/services/ApiCategoryService.dart';
import 'package:fe/services/ApiAuction_ItemsService.dart';
import 'package:fe/pages/Auction_ItemsPage.dart';
import 'package:fe/pages/CategoryItemSearchPage.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.white,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryItemSearchPage(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 45.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Text(
                      'Search items',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const Divider(thickness: 1.0, color: Colors.grey),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: futureCategories,
              builder: (context, categorySnapshot) {
                if (categorySnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (categorySnapshot.hasError) {
                  return Center(child: Text('Error: ${categorySnapshot.error}'));
                } else if (!categorySnapshot.hasData || categorySnapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories found.'));
                }

                return FutureBuilder<List<AuctionItems>>(
                  future: futureAuctionItems,
                  builder: (context, auctionSnapshot) {
                    if (auctionSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (auctionSnapshot.hasError) {
                      return Center(child: Text('Error: ${auctionSnapshot.error}'));
                    }

                    List<Category> categories = categorySnapshot.data!;
                    List<AuctionItems> auctionItems = auctionSnapshot.data ?? [];

                    return ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        List<AuctionItems> filteredItems = auctionItems
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
                              child: filteredItems.isNotEmpty
                                  ? ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: filteredItems.length,
                                itemBuilder: (context, itemIndex) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Auction_ItemsDetailPage(
                                            item: filteredItems[itemIndex],
                                            allItems: filteredItems,
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
                                              filteredItems[itemIndex].images?.isNotEmpty ?? false
                                                  ? filteredItems[itemIndex].images!.first
                                                  : 'https://via.placeholder.com/150',
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              filteredItems[itemIndex].itemName ?? 'No Name',
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
                              )
                                  : const Center(child: Text('No items available')),
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
    );
  }
}
