import 'dart:convert';
import 'package:fe/services/UrlAPI.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Auction.dart';
import '../services/ApiPaymentService.dart';
import 'LoginPage.dart';
import 'package:http/http.dart' as http;

class MyBidsPage extends StatefulWidget {
  const MyBidsPage({super.key});

  @override
  State<MyBidsPage> createState() => _MyBidsPageState();
}

class _MyBidsPageState extends State<MyBidsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiPaymentService _apiPaymentService = ApiPaymentService();
  List<Auction> paidItems = [];
  List<Auction> unpaidItems = [];
  bool isLoading = true;
  String? userId;
  String selectedSort = "price"; // 🔥 Mặc định sắp xếp theo giá

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    setState(() {
      userId = storedUserId;
    });

    if (userId != null) {
      fetchUserBids();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserBids() async {
    if (userId == null) return;

    final response = await http.get(
      Uri.parse("${UrlAPI.url}/v1/payment/bids/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    print("📢 API BID STATUS: ${response.statusCode}");
    print("📢 API BID BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        paidItems = (data["paid"] as List).map((e) => Auction.fromJson(e)).toList();
        unpaidItems = (data["unpaid"] as List).map((e) => Auction.fromJson(e)).toList();
        isLoading = false;
      });

      print("✅ Số lượng sản phẩm đã thanh toán: ${paidItems.length}");
      print("✅ Số lượng sản phẩm chưa thanh toán: ${unpaidItems.length}");
    } else {
      print("🚨 Lỗi tải danh sách đấu giá!");
      setState(() {
        isLoading = false;
      });
    }
    _sortItems(); // 🔥 Gọi hàm sắp xếp ngay sau khi lấy dữ liệu
  }

  /// 🔥 Hàm sắp xếp danh sách theo tiêu chí đã chọn
  void _sortItems() {
    setState(() {
      Comparator<Auction> comparator;
      switch (selectedSort) {
        case "price":
          comparator = (a, b) => (b.startingPrice ?? 0).compareTo(a.startingPrice ?? 0);
          break;
        case "date":
          comparator = (a, b) => (b.startDate ?? DateTime(2000)).compareTo(a.startDate ?? DateTime(2000));
          break;
        case "name":
          comparator = (a, b) => (a.itemName ?? "").compareTo(b.itemName ?? "");
          break;
        default:
          return;
      }
      paidItems.sort(comparator);
      unpaidItems.sort(comparator);
    });
  }

  /// ✅ Tính tổng số tiền đã đấu giá
  double getTotalAmount(List<Auction> items) {
    return items.fold(0.0, (sum, item) => sum + (item.startingPrice ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bids'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Paid'),
            Tab(text: 'Unpaid'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 🔥 Dropdown dưới TabBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sort by: "),
                DropdownButton<String>(
                  value: selectedSort,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSort = newValue!;
                      _sortItems();
                    });
                  },
                  items: [
                    DropdownMenuItem(value: "price", child: Text("Price")),
                    DropdownMenuItem(value: "date", child: Text("Date")),
                    DropdownMenuItem(value: "name", child: Text("Name")),
                  ],
                ),
              ],
            ),
          ),

          // ✅ THÊM PHẦN THỐNG KÊ
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
                    Expanded( // ✅ Ngăn lỗi RenderFlex bằng Expanded
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Tổng giá trị đã được thánh toán:",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("\$${getTotalAmount([...paidItems, ...unpaidItems]).toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded( // ✅ Ngăn lỗi RenderFlex bằng Expanded
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Số lượng đa bán đấu giá",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("${paidItems.length + unpaidItems.length} sản phẩm",
                              style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBidList(paidItems, "No paid items"),
                _buildBidList(unpaidItems, "No unpaid items"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidList(List<Auction> items, String emptyText) {
    return items.isEmpty
        ? Column(
      children: [
        const SizedBox(height: 16),
        Text(emptyText, style: const TextStyle(fontSize: 16, color: Colors.black54)),
      ],
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        Auction item = items[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: item.imagesList != null && item.imagesList!.isNotEmpty
                ? Image.network(item.imagesList!.first, width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 50),
            title: Text(item.itemName ?? "No Name"),
            subtitle: Text("Price: \$${item.startingPrice ?? 0}"),
            trailing: Text(
              (item.ispaid ?? false) ? "Paid ✅" : "Unpaid ❌",
              style: TextStyle(color: (item.ispaid ?? false) ? Colors.green : Colors.red),
            ),
          ),
        );
      },
    );
  }
}
