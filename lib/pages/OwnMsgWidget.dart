import 'package:fe/models/ChatMessageResponse.dart';
import 'package:flutter/material.dart';

class OwnMsgWidget extends StatelessWidget {
  final String sender;
  final String msg;
  // final List<ChatMessageResponse>? images;
  const OwnMsgWidget({
    super.key,
    required this.msg,
    required this.sender,
    // required this.images
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 100,
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.teal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  msg,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),

                // if (images != null && images!.isNotEmpty)
                //   ...images!.map(
                //     (image) => Padding(
                //       padding: const EdgeInsets.symmetric(vertical: 5),
                //       child: Image.network(
                //         image,
                //         width: 150,
                //         height: 150,
                //         fit: BoxFit.cover,
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
