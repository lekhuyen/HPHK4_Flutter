import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Auction_Items.dart';
import '../services/ApiAuction_ItemsService.dart';

class MyAuctionPage extends StatefulWidget {
  final String userId; // Truyền userId khi mở trang

  const MyAuctionPage({super.key, required this.userId});

  @override
  _MyAuctionPageState createState() => _MyAuctionPageState();
}

class _MyAuctionPageState extends State<MyAuctionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AuctionItems> ongoingAuctions = [];
  List<AuctionItems> expiredAuctions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    print("📢 userId truyền vào MyAuctionPage: ${widget.userId}"); // ✅ In userId để kiểm tra

    if (widget.userId.isEmpty) {
      print("🚨 Lỗi: Không có userId để tải dữ liệu!");
    } else {
      _fetchMyAuctions();
    }
  }

  Future<void> _fetchMyAuctions() async {
    try {
      ApiAuction_ItemsService apiService = ApiAuction_ItemsService();
      List<AuctionItems> auctions = await apiService.fetchAuctionsByCreator(widget.userId);

      DateTime now = DateTime.now();
      List<AuctionItems> ongoing = [];
      List<AuctionItems> expired = [];

      for (var auction in auctions) {
        if (auction.startDate != null && auction.endDate != null) {
          if (auction.startDate!.isAfter(auction.endDate!)) {
            print("🚨 LỖI: startDate (${auction.startDate}) > endDate (${auction.endDate})");
            // ✅ Hoán đổi nếu bị lỗi
            DateTime temp = auction.startDate!;
            auction.startDate = auction.endDate;
            auction.endDate = temp;
            print("✅ Đã hoán đổi: startDate (${auction.startDate}) - endDate (${auction.endDate})");
          }

          if (auction.endDate!.isAfter(now)) {
            ongoing.add(auction);
          } else {
            expired.add(auction);
          }
        }
      }

      setState(() {
        ongoingAuctions = ongoing;
        expiredAuctions = expired;
        isLoading = false;
      });
    } catch (e) {
      print("🚨 Lỗi tải dữ liệu đấu giá: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Auctions", style: TextStyle(color: Colors.black, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.teal,
          tabs: const [
            Tab(text: "Auction Now"),
            Tab(text: "Auction Over"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAuctionList(ongoingAuctions, false), // Đấu giá đang diễn ra
          _buildAuctionList(expiredAuctions, true), // Đấu giá đã hết hạn
        ],
      ),
    );
  }

  Widget _buildAuctionList(List<AuctionItems> auctions, bool isSold) {
    return ListView.builder(
      itemCount: auctions.length,
      itemBuilder: (context, index) {
        final auction = auctions[index];

        // ✅ Định dạng ngày bắt đầu và ngày kết thúc
        String formattedStartDate = auction.startDate != null
            ? DateFormat.yMMMd().format(auction.startDate!)
            : "No Start Date";

        String formattedEndDate = auction.endDate != null
            ? DateFormat.yMMMd().format(auction.endDate!)
            : "No End Date";
        return _buildAuctionItem(
          auction.itemName ?? "No Name",
          auction.startingPrice != null ? "\$${auction.startingPrice}" : "No Price",
          formattedEndDate, // ✅ Truyền vào String, không phải Text()
          formattedStartDate,
          auction.images != null && auction.images!.isNotEmpty ? auction.images!.first : "",
          isSold,
        );
      },
    );
  }


  Widget _buildAuctionItem(String title, String price, String startDate, String endDate, String imageUrl, bool isSold) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: imageUrl.isNotEmpty
            ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover)
            : Container(width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.image, color: Colors.grey)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Start Date: $startDate", style: const TextStyle(color: Colors.blue)), // ✅ Hiển thị ngày bắt đầu
            Text("End Date: $endDate", style: const TextStyle(color: Colors.red)), // ✅ Hiển thị ngày kết thúc
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: isSold ? const Text("SOLD", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)) : null,
      ),
    );
  }


}
