import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("February Sale"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset('assets/giraffe.jpg', width: double.infinity, fit: BoxFit.cover),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black54,
                    child: const Text("1 of 2", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Peter Beard - Giraffes in Mirage of the Taru Desert, Photographic Print",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text("Est. \$2,000 - \$3,000", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text("\$1,000", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const SizedBox(width: double.infinity, child: Center(child: Text("PLACE BID"))),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: const SizedBox(width: double.infinity, child: Center(child: Text("SAVE ITEM"))),
                  ),
                  const SizedBox(height: 8),
                  const Text("5 bidders watching this item", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text("Get approved to bid live on Thu, Feb 13 3:00 AM +07.", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () {}, child: const Text("Register for Auction", style: TextStyle(color: Colors.blue))),
                  const Divider(),

                  const Text(
                    'description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A Gold Charm Bracelet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('ASK A QUESTION'),
                  ),


                  const SizedBox(height: 16),
                  const Text(
                    'Shipping & Pickup Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Auction Curated By", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage("assets/tom_burstein.jpg")),
                    title: Text("Tom Burstein"),
                    subtitle: Text("Director, Jewelry & Watches"),
                  ),
                  const ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage("assets/kelly_sitek.jpg")),
                    title: Text("Kelly Sitek"),
                    subtitle: Text("Specialist, Jewelry & Watches"),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("More Items From This Auction", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        AuctionItem(image: "assets/item1.jpg", title: "A group of whimsical anim...", price: "\$400", bids: "3 Bids"),
                        AuctionItem(image: "assets/item2.jpg", title: "An 18K Bi-Color Gold and Dia...", price: "\$900", bids: "4 Bids"),
                        AuctionItem(image: "assets/item3.jpg", title: "A Pair of 18K Gold and Dia...", price: "\$425", bids: "4 Bids"),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Similar Items Available Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        AuctionItem(image: "assets/similar1.jpg", title: "Gold Charm Bracelet", price: "\$350", bids: "2 Bids"),
                        AuctionItem(image: "assets/similar2.jpg", title: "Gemstone Necklace", price: "\$600", bids: "5 Bids"),
                        AuctionItem(image: "assets/similar3.jpg", title: "Vintage Gold Bracelet", price: "\$450", bids: "3 Bids"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}
class AuctionItem extends StatelessWidget {
  final String image;
  final String title;
  final String price;
  final String bids;

  const AuctionItem({
    required this.image,
    required this.title,
    required this.price,
    required this.bids,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(image, width: 120, height: 100, fit: BoxFit.cover),
          ),
          const SizedBox(height: 5),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(bids, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
