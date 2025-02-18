import 'package:flutter/material.dart';

class OtherMsgWithImagesWidget extends StatelessWidget {
  final String msg;
  final List<String> images;

  const OtherMsgWithImagesWidget({
    super.key,
    required this.msg,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.grey[300],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Render văn bản
              Text(
                msg,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              // Render ảnh
              ...images.map(
                (image) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Image.network(
                    image,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
