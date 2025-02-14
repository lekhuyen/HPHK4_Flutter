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

  List<AuctionItems> paidItems = []; // 🔥 Danh sách sản phẩm đã thanh toán
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPaidItems();
  }

  Future<void> _fetchPaidItems() async {
    List<AuctionItems> items = await _apiPaymentService.handlePaymentCallback();
    setState(() {
      paidItems = items;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bids',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Paid'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaidTab(),
          _buildPastTab(),
        ],
      ),
    );
  }

  Widget _buildPaidTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (paidItems.isEmpty) {
      return const Center(
        child: Text(
          "Bạn chưa có sản phẩm nào đã thanh toán!",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: paidItems.length,
      itemBuilder: (context, index) {
        AuctionItems item = paidItems[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Image.network(
              item.images?.isNotEmpty == true ? item.images!.first : 'https://via.placeholder.com/150',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(item.itemName ?? "No Name", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text("Giá: \$${item.startingPrice}"),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
    );
  }

  Widget _buildPastTab() {
    return const Center(
      child: Text(
        'No past bids',
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }
}
