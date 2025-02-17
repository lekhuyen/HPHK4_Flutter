import 'package:flutter/material.dart';

class MyAccountPage extends StatefulWidget {
  final String username;
  final String userId;
  final String token;

  const MyAccountPage({
    Key? key,
    required this.username,
    required this.userId,
    required this.token,
  }) : super(key: key);

  @override
  MyAccountPageState createState() => MyAccountPageState();
}

class MyAccountPageState extends State<MyAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "User Information",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Username: ${widget.username}", style: const TextStyle(fontSize: 18, color: Colors.teal)),
            Text("User ID: ${widget.userId}", style: const TextStyle(fontSize: 18, color: Colors.teal)),
            Text("Token: ${widget.token}", style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Return to previous screen
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Back", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
