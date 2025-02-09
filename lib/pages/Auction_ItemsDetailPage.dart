import 'package:flutter/material.dart';
import 'package:fe/models/Auction_Items.dart';
import 'package:intl/intl.dart';  // Import for date formatting and calculating time left

class Auction_ItemsDetailPage extends StatefulWidget {
  final AuctionItems item;

  const Auction_ItemsDetailPage({super.key, required this.item});

  @override
  _Auction_ItemsDetailPageState createState() => _Auction_ItemsDetailPageState();
}

class _Auction_ItemsDetailPageState extends State<Auction_ItemsDetailPage> {
  // Function to calculate the time remaining
  String getTimeLeft(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      return "Auction has ended";
    }

    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) left';
    } else {
      return '${difference.inMinutes} minute(s) left';
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.item.images?.isNotEmpty ?? false ? widget.item.images!.first : 'https://via.placeholder.com/150';
    String formattedEndDate = widget.item.endDate != null ? DateFormat('MM/dd/yyyy').format(widget.item.endDate!) : 'No End Date';
    String timeLeft = widget.item.endDate != null ? getTimeLeft(widget.item.endDate!) : 'No End Date';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.itemName ?? 'Item Details'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,  // Set the background color to white
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display image
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.network('https://via.placeholder.com/150', width: double.infinity, height: 300, fit: BoxFit.cover);
              },
            ),
            const SizedBox(height: 16),

            // Title and price with time left
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Item name
                Expanded(
                  child: Text(
                    widget.item.itemName ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Price and time left
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Price: \$${widget.item.startingPrice ?? 0}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Time Left: $timeLeft',
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // "PLACE BID" Button
            SizedBox(
              width: double.infinity, // This makes the button take up the full width
              child: ElevatedButton(
                onPressed: () {
                  // You can handle the bidding logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bid placed for ${widget.item.itemName}')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button color
                  padding: EdgeInsets.symmetric(vertical: 15), // Adjust padding for height
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('PLACE BID'),
              ),
            ),

            const SizedBox(height: 16),  // Space between the button and divider

            // Divider between price/time left and description
            const Divider(),

            // Description section
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                widget.item.description ?? 'No Description Available.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
