import 'dart:convert';
import 'package:fe/services/UrlAPI.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Auction_Items.dart';
import '../services/ApiPaymentService.dart';
import 'LoginPage.dart';
import 'package:http/http.dart' as http;

class MyBidsPage extends StatefulWidget {
  const MyBidsPage({super.key});

  @override
  State<MyBidsPage> createState() => _MyBidsPageState();
}

class _MyBidsPageState extends State<MyBidsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiPaymentService _apiPaymentService = ApiPaymentService();
  List<AuctionItems> paidItems = [];
  List<AuctionItems> unpaidItems = [];
  bool isLoading = true;
  String? userId;

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
        paidItems = (data["paid"] as List)
            .map((e) => AuctionItems.fromJson(e))
            .toList();
        unpaidItems = (data["unpaid"] as List)
            .map((e) => AuctionItems.fromJson(e))
            .toList();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bids',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                if (userId == null)
                  _buildLoginPrompt(), // ✅ Hiển thị đăng nhập trên cùng
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

  /// ✅ Widget thông báo yêu cầu đăng nhập
  Widget _buildLoginPrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        children: [
          const Text(
            "Log in to save items, follow searches, place bids, and register for auctions.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text("LOG IN",
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBidList(List<AuctionItems> items, String emptyText) {
    return items.isEmpty
        ? Column(
            children: [
              const SizedBox(height: 16),
              Text(emptyText,
                  style: const TextStyle(fontSize: 16, color: Colors.black54)),
            ],
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              AuctionItems item = items[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: item.images != null && item.images!.isNotEmpty
                      ? Image.network(item.images!.first,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 50),
                  title: Text(item.itemName ?? "No Name"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Price: \$${item.startingPrice ?? 0}"),
                      if (item.ispaid ?? false)
                        Text("Buyer: ${item.buyerName}",
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight
                                    .bold)), // ✅ Hiển thị tên người thanh toán
                    ],
                  ),
                  trailing: Text(
                    (item.ispaid ?? false) ? "Paid ✅" : "Unpaid ❌",
                    style: TextStyle(
                        color:
                            (item.ispaid ?? false) ? Colors.green : Colors.red),
                  ),
                ),
              );
            },
          );
  }
}
