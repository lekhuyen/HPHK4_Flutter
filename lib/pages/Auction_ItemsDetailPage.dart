import 'package:flutter/material.dart';
import 'package:fe/models/Auction_Items.dart';
import 'package:fe/services/ApiAuction_ItemsService.dart';
import 'package:intl/intl.dart';

import '../services/ApiBiddingService.dart';
import '../services/ApiPaymentService.dart';
import 'HomePage.dart';
import 'PaymentWebView.dart';

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
  late TextEditingController _bidController; // ✅ Ô nhập giá đấu
  bool isPlacingBid = false; // Trạng thái loading khi đặt giá
  AuctionItems? updatedItem; // 🔥 Biến giữ dữ liệu mới


  @override
  void initState() {
    super.initState();
    apiService = ApiAuction_ItemsService();
    _bidController = TextEditingController();
    fetchItemDetails(); // 🔥 Gọi API để lấy giá mới nhất

    ApiBiddingService biddingService = ApiBiddingService();
    biddingService.onNewBidReceived = (double newPrice) {
      print("🔄 WebSocket received new price: $newPrice"); // 🔥 Debug giá mới từ WebSocket
      fetchItemDetails(); // 🔥 Thay vì chỉ cập nhật giá, gọi lại API
    };

    fetchSimilarItems();
    fetchUpcomingItems();
  }

  List<AuctionItems> upcomingItems = [];
  bool isLoadingUpcomingItems = true;

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }


  // 🔥 Hàm mới để cập nhật dữ liệu từ API
  Future<void> fetchItemDetails() async {
    try {
      var newItem = await apiService.getItemById(widget.item.itemId!);

      print("✅ API returned item details: ${newItem.toJson()}"); // 🔥 Debug toàn bộ dữ liệu API trả về

      setState(() {
        updatedItem = newItem; // ✅ Cập nhật dữ liệu mới từ API
      });

      print("✅ Updated item price in UI: ${updatedItem?.currentPrice}"); // 🔥 Kiểm tra giá sau khi cập nhật
    } catch (e) {
      print("🚨 Lỗi khi tải sản phẩm mới: $e");
    }
  }




  Future<void> placeBid() async {
    double? bidAmount = double.tryParse(_bidController.text);
    if (bidAmount == null || bidAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚨 Please enter a valid bid amount")),
      );
      return;
    }

    setState(() => isPlacingBid = true);

    bool success = await ApiBiddingService().placeBid(widget.item.itemId!, bidAmount);
    setState(() => isPlacingBid = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🎉 Bid placed successfully for \$${bidAmount.toStringAsFixed(2)}!")),
      );

      fetchItemDetails(); // 🔥 Gọi lại API để lấy giá mới nhất
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚨 Failed to place bid. Please try again.")),
      );
    }
  }

  /// Gọi API để lấy danh sách sản phẩm sắp tới
  Future<void> fetchUpcomingItems() async {
    try {
      print("🔍 Fetching upcoming auction items...");
      var fetchedItems = await apiService.fetchUpcomingAuctions();
      print("✅ Fetched ${fetchedItems.length} upcoming items.");

      setState(() {
        upcomingItems = fetchedItems;
        isLoadingUpcomingItems = false;
      });
    } catch (e) {
      print("🚨 Lỗi khi tải sản phẩm sắp tới: $e");
      setState(() => isLoadingUpcomingItems = false);
    }
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
    final item = updatedItem ?? widget.item; // 🔥 Sử dụng giá mới nếu có
    @override
    Widget build(BuildContext context) {
      final item = updatedItem ?? widget.item;

      print("🔥 Displaying price in UI: Current Price = ${item.currentPrice}, Starting Price = ${item.startingPrice}"); // 🔥 Debug giá hiển thị trên UI

      return Scaffold(
        appBar: AppBar(title: Text(item.itemName ?? 'Item Details')),
        body: Column(
          children: [
            Text("Price: \$${item.currentPrice ?? item.startingPrice ?? 0}"), // ✅ Hiển thị current_price nếu có
          ],
        ),
      );
    }

    String imageUrl = (widget.item.images != null && widget.item.images!.isNotEmpty)
        ? widget.item.images!.first
        : 'https://via.placeholder.com/150';

    String timeLeft = getTimeLeft(widget.item.endDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.itemName ?? 'Item Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
                MaterialPageRoute(
                builder: (context) => const Homepage(initialIndex: 0), // 🔥 Quay về trang chính
              ),
            );
          },
        ),
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
                    Text('Price: \$${item.currentPrice ?? item.startingPrice ?? 0}', style: const TextStyle(fontSize: 18)),
                    Text('Time Left: $timeLeft', style: const TextStyle(fontSize: 16, color: Colors.red)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// Ô nhập giá đấu giá
            TextField(
              controller: _bidController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter your bid",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            /// Nút đặt giá
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPlacingBid ? null : placeBid,
                child: isPlacingBid
                    ? const CircularProgressIndicator()
                    : const Text("PLACE BID"),
              ),
            ),

            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final apiPaymentService = ApiPaymentService();

                String orderId = DateTime.now().millisecondsSinceEpoch.toString(); // ✅ Tạo orderId duy nhất
                String productId = widget.item.itemId.toString(); // 🔥 Chuyển `int?` thành `String`

                String? paymentUrl = await apiPaymentService.createPayment(
                  productId, // ✅ Đảm bảo `productId` là `String`
                  widget.item.startingPrice ?? 0, // Vẫn giữ `startingPrice` là `double`
                  orderId,
                );

                if (paymentUrl != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentWebView(paymentUrl: paymentUrl, productId: '',)),
                  );
                } else {
                  print("🚨 Lỗi tạo thanh toán VNPay!");
                }
              },
              child: const SizedBox(
                width: double.infinity,
                child: Center(child: Text("Payment")),
              ),
            ),


            const Divider(),

            /// Mô tả sản phẩm
            const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.item.description ?? 'No Description Available.'),
            const Divider(),
            const Text('Upcomming Items Available Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            SizedBox(
              height: 250, // 🔥 Tăng chiều cao nếu cần
              child: isLoadingUpcomingItems
                  ? const Center(child: CircularProgressIndicator())  // Hiển thị vòng xoay nếu đang tải
                  : upcomingItems.isEmpty
                  ? const Center(child: Text("No upcoming items found"))
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: upcomingItems.length,
                itemBuilder: (context, index) {
                  var item = upcomingItems[index];
                  String itemImageUrl = (item.images != null && item.images!.isNotEmpty)
                      ? item.images!.first
                      : 'https://via.placeholder.com/150';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Homepage(initialIndex: 0, selectedItem: item), // 🔥 Mở trong HomePage
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
                              width: 150, // 🔥 Kích thước ảnh
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
            const Divider(),

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
                          builder: (context) => Homepage(initialIndex: 0, selectedItem: item), // 🔥 Mở trong HomePage
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
