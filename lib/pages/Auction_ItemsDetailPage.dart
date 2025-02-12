import 'package:flutter/material.dart';
import 'package:fe/models/Auction_Items.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class Auction_ItemsDetailPage extends StatefulWidget {
  final AuctionItems item;
  final List<AuctionItems> allItems;

  const Auction_ItemsDetailPage({super.key, required this.item, required this.allItems});

  @override
  _Auction_ItemsDetailPageState createState() => _Auction_ItemsDetailPageState();
}

class _Auction_ItemsDetailPageState extends State<Auction_ItemsDetailPage> {
  String getTimeLeft(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      return "Auction has ended";
    }

    if (difference.inDays > 0) {
      return '📅 ${difference.inDays} day(s) left';
    } else if (difference.inHours > 0) {
      return '⌚ ${difference.inHours} hour(s) left';
    } else {
      return '⏳ ${difference.inMinutes} minute(s) left';
    }
  }

  @override
  void initState() {
    super.initState();
    print("Total items available: ${widget.allItems.length}");
  }

  List<AuctionItems> getSimilarItems() {
    String currentCategoryName = widget.item.category?.category_name ?? 'Unknown';
    List<AuctionItems> filteredItems = widget.allItems
        .where((item) => item.category?.category_name == currentCategoryName && item.itemId != widget.item.itemId)
        .toList();

    filteredItems.shuffle(Random());
    return filteredItems.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.item.images?.isNotEmpty ?? false ? widget.item.images!.first : 'https://via.placeholder.com/150';
    String timeLeft = widget.item.endDate != null ? getTimeLeft(widget.item.endDate!) : 'No End Date';
    List<AuctionItems> similarItems = getSimilarItems();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.itemName ?? 'Item Details'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network('https://via.placeholder.com/150', width: double.infinity, height: 300, fit: BoxFit.cover);
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.item.itemName != null && (widget.item.itemName!.length > 20)
                          ? '${widget.item.itemName!.substring(0, 20)}...'
                          : widget.item.itemName ?? 'No Name',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Time Left: $timeLeft', style: const TextStyle(fontSize: 16, color: Colors.red)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bid placed for ${widget.item.itemName}')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Reducing roundness
                      side: BorderSide(color: Colors.black, width: 1), // Adding a border
                    ),
                    elevation: 2, // Slight shadow for depth
                  ),
                  child: const Text(
                    'PLACE BID',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.description ?? 'No description available.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'There is more you like',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (similarItems.isNotEmpty)
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: similarItems.length,
                    itemBuilder: (context, index) {
                      final item = similarItems[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Auction_ItemsDetailPage(item: item, allItems: widget.allItems),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.images?.isNotEmpty ?? false ? item.images!.first : 'https://via.placeholder.com/100',
                                  width: 120,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                item.itemName != null && (item.itemName!.length > 15)
                                    ? '${item.itemName!.substring(0, 15)}...'
                                    : item.itemName ?? 'Unnamed',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Price: \$${item.startingPrice ?? 0}',
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                              ),
                              Text(
                                item.endDate != null ? getTimeLeft(item.endDate!) : 'No End Date',
                                style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Text('No similar items found.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
