import 'package:flutter/material.dart';
import 'package:fe/models/Auction_Items.dart';
import 'package:fe/services/ApiAuction_ItemsService.dart';
import 'package:intl/intl.dart';

import 'HomePage.dart';

class Auction_ItemsDetailPage extends StatefulWidget {
  final AuctionItems item;
  const Auction_ItemsDetailPage({super.key, required this.item});
  @override
  _Auction_ItemsDetailPageState createState() => _Auction_ItemsDetailPageState();
}

class _Auction_ItemsDetailPageState extends State<Auction_ItemsDetailPage> {
  late ApiAuction_ItemsService apiService;
  List<AuctionItems> similarItems = [];
  bool isLoadingSimilarItems = true;

  @override
  void initState() {
    super.initState();
    apiService = ApiAuction_ItemsService();
    fetchSimilarItems();
  }

  /// Tính thời gian còn lại của phiên đấu giá
  String getTimeLeft(DateTime? endDate) {
    if (endDate == null) return "No End Date";
    final now = DateTime.now();
    final difference = endDate.difference(now);
    if (difference.isNegative) return "Auction has ended";
    if (difference.inDays > 0) return '${difference.inDays} day(s) left';
    if (difference.inHours > 0) return '${difference.inHours} hour(s) left';
    return '${difference.inMinutes} minute(s) left';
  }

  /// Gọi API để lấy danh sách sản phẩm liên quan
  Future<void> fetchSimilarItems() async {
    String? categoryName = widget.item.category?.category_name;
    if (categoryName == null || categoryName.isEmpty) {
      print("⚠️ Category name is null or empty.");
      setState(() => isLoadingSimilarItems = false);
      return;
    }

    int? categoryId = await apiService.getCategoryIdByName(categoryName);
    print("🔍 Category ID found: $categoryId"); // In ID ra console để debug

    if (categoryId == null) {
      print("⚠️ Không tìm thấy ID danh mục cho: $categoryName");
      setState(() => isLoadingSimilarItems = false);
      return;
    }

    try {
      print("🔍 Fetching items for category ID: $categoryId");
      var fetchedItems = await apiService.getItemsByCategory(categoryId.toString());
      print("✅ API Response: ${fetchedItems.length} items");

      setState(() {
        similarItems = fetchedItems;
        isLoadingSimilarItems = false;
      });
    } catch (e) {
      print("🚨 Lỗi khi tải sản phẩm cùng danh mục: $e");
      setState(() => isLoadingSimilarItems = false);
    }
  }




  @override
  Widget build(BuildContext context) {
    String imageUrl = (widget.item.images != null && widget.item.images!.isNotEmpty)
        ? widget.item.images!.first
        : 'https://via.placeholder.com/150';

    String timeLeft = getTimeLeft(widget.item.endDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.itemName ?? 'Item Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),


      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Hình ảnh sản phẩm
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.network('https://via.placeholder.com/150',
                    width: double.infinity, height: 300, fit: BoxFit.cover);
              },
            ),
            const SizedBox(height: 16),

            /// Tiêu đề và giá sản phẩm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.item.itemName ?? 'No Name',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Price: \$${widget.item.startingPrice ?? 0}', style: const TextStyle(fontSize: 18)),
                    Text('Time Left: $timeLeft', style: const TextStyle(fontSize: 16, color: Colors.red)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// Nút đặt giá
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bid placed for ${widget.item.itemName}')),
                  );
                },
                child: const Text('PLACE BID'),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              child: const SizedBox(width: double.infinity, child: Center(child: Text("SAVE ITEM"))),
            ),
            const Divider(),

            /// Mô tả sản phẩm
            const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.item.description ?? 'No Description Available.'),
            const Divider(),
            const Text('Upcomming Items Available Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(
              height: 250,

            ),
            const Divider(),
            /// Danh sách sản phẩm liên quan
            const Text('Similar Items Available Now',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            SizedBox(
              height: 250, // 🔥 Tăng chiều cao nếu cần
              child: isLoadingSimilarItems
                  ? const Center(child: CircularProgressIndicator())
                  : similarItems.isEmpty
                  ? const Center(child: Text("No similar items found"))
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: similarItems.length, // 🔥 Hiển thị tất cả sản phẩm
                itemBuilder: (context, index) {
                  var item = similarItems[index];
                  String itemImageUrl = (item.images != null && item.images!.isNotEmpty)
                      ? item.images!.first
                      : 'https://via.placeholder.com/150';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Auction_ItemsDetailPage(item: item),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              itemImageUrl,
                              width: 150, // 🔥 Tăng kích thước ảnh nếu cần
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/placeholder.jpg', width: 150, height: 120, fit: BoxFit.cover);
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(item.itemName ?? 'No Name', maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text("\$${item.startingPrice ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("${item.bidStep ?? 0} Bids", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),


          ],
        ),
      ),
    );
  }
}
