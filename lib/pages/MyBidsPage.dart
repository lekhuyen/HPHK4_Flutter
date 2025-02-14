import 'package:flutter/material.dart';
import '../models/Auction_Items.dart';
import '../services/ApiPaymentService.dart';

class MyBidsPage extends StatefulWidget {
  const MyBidsPage({super.key});

  @override
  State<MyBidsPage> createState() => _MyBidsPageState();
}

class _MyBidsPageState extends State<MyBidsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiPaymentService _apiPaymentService = ApiPaymentService();
  List<AuctionItems> paidItems = [];
  List<AuctionItems> unpaidItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUserBids();
_buildPaidTab(paidItems);
  }

  Future<void> fetchUserBids() async {
    var bids = await _apiPaymentService.getUserBids();
    if (bids != null) {
      print("✅ Bids Loaded Successfully!");
      setState(() {
        paidItems = bids["paid"] ?? [];
        unpaidItems = bids["unpaid"] ?? [];
      });
    } else {
      print("🚨 Lỗi tải dữ liệu đấu giá!");
    }
  }


  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Widget _buildPaidTab(List<AuctionItems> paidItems) {
    if (paidItems.isEmpty) {
      return const Center(child: Text("No paid items found"));
    }

    return ListView.builder(
      itemCount: paidItems.length,
      itemBuilder: (context, index) {
        var item = paidItems[index];

        return ListTile(
          title: Text(item.itemName ?? 'Unknown Item'),
          trailing: const Text("Paid", style: TextStyle(color: Colors.green)),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bids', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Paid'),
            Tab(text: 'Unpaid'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildBidList(paidItems, "No paid items"),
          _buildBidList(unpaidItems, "No unpaid items"),
        ],
      ),
    );
  }

  Widget _buildBidList(List<AuctionItems> items, String emptyText) {
    return items.isEmpty
        ? Center(child: Text(emptyText, style: const TextStyle(fontSize: 16, color: Colors.black54)))
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
                ? Image.network(item.images!.first, width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 50),
            title: Text(item.itemName ?? "No Name"),
            subtitle: Text("Price: \$${item.startingPrice ?? 0}"),
            trailing: Text(
              (item.issoldout ?? false) ? "Paid" : "Unpaid",
              style: TextStyle(color: (item.issoldout ?? false) ? Colors.green : Colors.red),
            ),
          ),
        );
      },
    );
  }
}
