import 'package:fe/pages/CategoryItemsPage.dart';
import 'package:fe/pages/CreateAuctionItemsPage.dart';
import 'package:fe/pages/Login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      home: CategoryItemPage(),
    );
  }
}
