import 'package:fe/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Auction_Items.dart';
import '../models/Category.dart';
import 'Auction_ItemsDetailPage.dart';
import 'Auction_ItemsPage.dart';
import 'AuctionsPage.dart';
import 'CategoryItemsPage.dart';
import 'MyAuctionPage.dart';
import 'MyBidsPage.dart';

class Homepage extends StatefulWidget {
  final int initialIndex;
  final AuctionItems? selectedItem; // 🔥 Thêm tham số này

  const Homepage({super.key, this.initialIndex = 0, this.selectedItem});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late int _selectedIndex;
  AuctionItems? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _selectedItem = widget.selectedItem;
  }

  List<Widget> _getPages() {
    if (_selectedItem != null) {
      return [Auction_ItemsDetailPage(item: _selectedItem!)]; // 🔥 Nếu có sản phẩm, hiển thị trang chi tiết
    }
    return [
      const CategoryItemPage(),
      const AuctionsPage(),
      const MyAuctionPage(userId: '',),
      const MyBidsPage(),
      const LoginPage(),
    ];
  }

  Future<void> _onItemTapped(int index) async {
    if (index == 2) { // Nếu "MyAuction" ở vị trí thứ 3
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      print("📢 userId từ SharedPreferences: $userId"); // ✅ In ra để kiểm tra

      if (userId != null && userId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyAuctionPage(userId: userId)),
        );
      } else {
        print("⚠️ User chưa đăng nhập hoặc không có userId!");
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel), label: 'Auctions'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_sharp), label: 'MyAuction'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'My Bids'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
