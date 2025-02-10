import 'package:fe/pages/LoginPage.dart';
import 'package:fe/pages/ProductDetailPage.dart';
import 'package:flutter/material.dart';
import '../models/Auction_Items.dart';
import '../models/Category.dart';
import 'Auction_ItemsDetailPage.dart';
import 'Auction_ItemsPage.dart';
import 'AuctionsPage.dart';
import 'CategoryItemsPage.dart';
import 'FavoritesPage.dart';
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
      return [Auction_ItemsDetailPage(item: _selectedItem!)]; // 🔥 Hiển thị trang chi tiết nếu có sản phẩm
    }
    return [
      const CategoryItemPage(),
      const AuctionsPage(),
      const FavoritesPage(),
      const MyBidsPage(),
      const LoginPage(),
      Auction_ItemsPage(category: Category(category_id: 0, category_name: "All Auctions")), // 🔥 Truyền danh mục mặc định
    ];
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedItem = null; // 🔥 Khi chuyển tab, thoát khỏi trang chi tiết
    });
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
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'My Bids'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
