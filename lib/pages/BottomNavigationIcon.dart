import 'package:fe/pages/CategoryItemsPage.dart';
import 'package:flutter/material.dart';

class BottomNavigationIcon extends StatefulWidget {
  const BottomNavigationIcon({super.key});

  @override
  State<StatefulWidget> createState() => _BottomNavigationIconState();
}

class _BottomNavigationIconState extends State<BottomNavigationIcon> {
  int _selectedIndex = 0;  // To track the selected index

  // List of pages for each navigation item
  final List<Widget> _pages = [
    const CategoryItemPage(),  // For Discover
    AuctionPage(),       // For Auction (You'll need to create this page)
    FavoritesPage(),     // For Favorites (You'll need to create this page)
    SearchPage(),        // For Search (You'll need to create this page)
    AccountPage(),       // For Account (You'll need to create this page)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Setting background color for the scaffold (the entire screen)
      backgroundColor: Colors.white,  // You can change this as needed.

      // Displaying the current page based on selected index
      body: _pages[_selectedIndex],

      // Customizing the BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,  // Set background color of the bar
        selectedItemColor: Colors.blue, // Change the color for the selected icon
        unselectedItemColor: Colors.grey, // Change the color for the unselected icons
        showSelectedLabels: true, // Show labels for selected items
        showUnselectedLabels: true, // Show labels for unselected items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),  // Discover icon
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel),  // Auction hammer icon
            label: 'Auction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),  // Favorites icon (example)
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),  // Search icon (example)
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),  // Account icon
            label: 'Your Account',
          ),
        ],
      ),
    );
  }
}

// Placeholder pages (You can replace them with your actual pages)
class AuctionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Auction Page'));
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Favorites Page'));
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Search Page'));
  }
}

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Account Page'));
  }
}
