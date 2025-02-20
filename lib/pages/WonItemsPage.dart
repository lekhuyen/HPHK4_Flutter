import 'package:fe/pages/WonItemDetailPage.dart';
import 'package:fe/services/ApiAuction_ItemsService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Auction.dart';
import '../services/ApiPaymentService.dart';
import 'package:intl/intl.dart';

class WonItemsPage extends StatefulWidget {
  const WonItemsPage({super.key});

  @override
  State<WonItemsPage> createState() => _WonItemsPageState();
}

class _WonItemsPageState extends State<WonItemsPage> {
  final ApiPaymentService _apiPaymentService = ApiPaymentService();
  final ApiAuction_ItemsService apiAuction_ItemsService = ApiAuction_ItemsService();
  List<Auction> wonItems = [];
  bool isLoading = true;
  String selectedSort = "price_desc"; // ✅ Mặc định sắp xếp theo giá cao -> thấp

  @override
  void initState() {
    super.initState();
    _fetchWonItems();
  }

  /// ✅ Gọi API lấy danh sách sản phẩm đã thắng
  Future<void> _fetchWonItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');

    if (userId != null && token != null) {
      List<Auction> items = await _apiPaymentService.getWonItemsByUser();
      setState(() {
        wonItems = items;
        isLoading = false;
      });
      _sortItems(); // ✅ Sắp xếp ngay khi tải dữ liệu

      /// 🔥 Cập nhật dữ liệu từng sản phẩm bằng `fetchItemDetails()`
      for (var item in wonItems) {
        await fetchItemDetails(item);
      }
    } else {
      print("🚨 User chưa đăng nhập!");
      setState(() => isLoading = false);
    }
  }

  /// ✅ Gọi API cập nhật dữ liệu chi tiết từng sản phẩm
  Future<void> fetchItemDetails(Auction item) async {
    try {
      var newItem = await apiAuction_ItemsService.getItemById(item.itemId!);
      if (!mounted) return; // ✅ Ngăn setState nếu widget bị dispose

      setState(() {
        item.user = newItem?.user;
      });
    } catch (e) {
      print("🚨 Lỗi khi tải sản phẩm mới: $e");
    }
  }

  /// ✅ Hàm sắp xếp danh sách theo tiêu chí đã chọn
  void _sortItems() {
    setState(() {
      Comparator<Auction> comparator;
      switch (selectedSort) {
        case "price_desc":
          comparator = (a, b) => (b.startingPrice ?? 0).compareTo(a.startingPrice ?? 0);
          break;
        case "price_asc":
          comparator = (a, b) => (a.startingPrice ?? 0).compareTo(b.startingPrice ?? 0);
          break;
        case "date_desc":
          comparator = (a, b) => (b.startDate ?? DateTime(2000)).compareTo(a.startDate ?? DateTime(2000));
          break;
        case "date_asc":
          comparator = (a, b) => (a.startDate ?? DateTime(2000)).compareTo(b.startDate ?? DateTime(2000));
          break;
        case "name_asc":
          comparator = (a, b) => (a.itemName ?? "").compareTo(b.itemName ?? "");
          break;
        case "name_desc":
          comparator = (a, b) => (b.itemName ?? "").compareTo(a.itemName ?? "");
          break;
        default:
          return;
      }
      wonItems.sort(comparator);
    });
  }

  /// ✅ Hàm tính tổng giá trị đã đấu giá
  double getTotalAmount() {
    return wonItems.fold(0.0, (sum, item) => sum + (item.startingPrice ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sản phẩm đã thắng đấu giá")),
      body: Column(
        children: [
          // ✅ THÊM PHẦN SORT BY
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sort by:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: selectedSort,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSort = newValue!;
                      _sortItems();
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: "price_desc", child: Text("Price: High to Low")),
                    DropdownMenuItem(value: "price_asc", child: Text("Price: Low to High")),
                    DropdownMenuItem(value: "date_desc", child: Text("Date: Newest First")),
                    DropdownMenuItem(value: "date_asc", child: Text("Date: Oldest First")),
                    DropdownMenuItem(value: "name_asc", child: Text("Name: A-Z")),
                    DropdownMenuItem(value: "name_desc", child: Text("Name: Z-A")),
                  ],
                ),
              ],
            ),
          ),

          // ✅ THÊM PHẦN THỐNG KÊ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tổng giá trị đã đấu giá:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("\$${getTotalAmount().toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Số lượng sản phẩm thắng:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("${wonItems.length} sản phẩm", style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ DANH SÁCH SẢN PHẨM
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : wonItems.isEmpty
                ? const Center(child: Text("Bạn chưa thắng sản phẩm nào.", style: TextStyle(fontSize: 16, color: Colors.black54)))
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: wonItems.length,
              itemBuilder: (context, index) {
                Auction item = wonItems[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: item.imagesList != null && item.imagesList!.isNotEmpty
                        ? Image.network(item.imagesList!.first, width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 50),
                    title: Text(item.itemName ?? "Không có tên"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Giá: \$${item.startingPrice ?? 0}"),
                        Text("Người bán: ${item.user?.name ?? "Không xác định"}"),
                      ],
                    ),
                    trailing: const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WonItemDetailPage(item: item),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
