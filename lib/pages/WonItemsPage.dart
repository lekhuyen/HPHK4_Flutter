import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Auction_Items.dart';
import '../services/ApiPaymentService.dart';

class WonItemsPage extends StatefulWidget {
  const WonItemsPage({super.key});

  @override
  State<WonItemsPage> createState() => _WonItemsPageState();
}

class _WonItemsPageState extends State<WonItemsPage> {
  final ApiPaymentService _apiPaymentService = ApiPaymentService();
  List<AuctionItems> wonItems = []; // ✅ Danh sách sản phẩm user đã thanh toán
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWonItems(); // 🔥 Gọi API khi vào trang
  }

  Future<void> _fetchWonItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');

    if (userId != null && token != null) {
      List<AuctionItems> items = await _apiPaymentService.getWonItemsByUser();
      setState(() {
        wonItems = items;
        isLoading = false;
      });
    } else {
      print("🚨 User chưa đăng nhập!");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Won Items")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : wonItems.isEmpty
          ? const Center(child: Text("No won items yet.", style: TextStyle(fontSize: 16, color: Colors.black54)))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: wonItems.length,
        itemBuilder: (context, index) {
          AuctionItems item = wonItems[index];
          return _buildAuctionItemCard(item);
        },
      ),
    );
  }

  /// ✅ Widget hiển thị từng sản phẩm
  Widget _buildAuctionItemCard(AuctionItems item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: item.images != null && item.images!.isNotEmpty
            ? Image.network(item.images!.first, width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.image, size: 50),
        title: Text(item.itemName ?? "No Name"),
        subtitle: Text("Price: \$${item.startingPrice ?? 0}"),
        trailing: const Icon(Icons.emoji_events, color: Colors.amber, size: 28), // 🏆 Icon tượng trưng cho thắng cuộc
      ),
    );
  }
}
