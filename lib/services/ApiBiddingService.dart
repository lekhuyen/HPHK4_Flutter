import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiBiddingService {
  final String apiUrl = "http:// 173.16.16.159:8080/api/bidding";
  // 192.168.1.134
  // 10.130.53.23
  late StompClient stompClient;
  Function(double)? onNewBidReceived; // 🔥 Callback để cập nhật UI

  ApiBiddingService() {
    _connectWebSocket();
  }

  void _connectWebSocket() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://173.16.16.159.159:8080/ws',
        onConnect: (StompFrame frame) {
          print("✅ Connected to WebSocket");

          stompClient.subscribe(
            destination: '/topic/newbidding',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                var response = jsonDecode(frame.body!);
                double newPrice = response['bidAmount'];

                print("🔔 New Bid Received: \$$newPrice");

                // 🔥 Gọi callback để cập nhật UI ngay lập tức
                if (onNewBidReceived != null) {
                  onNewBidReceived!(newPrice);
                }
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => print('WebSocket Error: $error'),
      ),
    );
    stompClient.activate();
  }

  Future<bool> placeBid(int itemId, double bidAmount) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId == null) {
        print("🚨 User not logged in!");
        return false;
      }

      if (!stompClient.connected) {
        print("🚨 WebSocket is not connected. Reconnecting...");
        _connectWebSocket();
        await Future.delayed(const Duration(seconds: 2));
      }

      var bidRequest = jsonEncode({
        "itemId": itemId,
        "userId": userId,
        "bidAmount": bidAmount,
      });

      stompClient.send(
        destination: '/app/create',
        body: bidRequest,
      );

      print("✅ Sent bid request for item $itemId: \$$bidAmount");
      return true;
    } catch (e) {
      print("🚨 Error placing bid: $e");
      return false;
    }
  }
}
