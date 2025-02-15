import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiBiddingService {
  final String apiUrl = "http://192.168.1.30:8080/api/bidding";
  late StompClient stompClient;

  ApiBiddingService() {
    _connectWebSocket();
  }

  void _connectWebSocket() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://192.168.1.30:8080/ws', // 🔥 Đổi từ HTTP sang WS
        onConnect: (StompFrame frame) {
          print("✅ Connected to WebSocket");

          stompClient.subscribe(
            destination: '/topic/newbidding',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                var response = jsonDecode(frame.body!);
                print("🔔 New Bid Received: $response");
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

      var bidRequest = jsonEncode({
        "itemId": itemId,
        "userId": userId,
        "bidAmount": bidAmount,
      });

      stompClient.send(
        destination: '/app/create', // ✅ Kiểm tra nếu backend nhận đúng
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
