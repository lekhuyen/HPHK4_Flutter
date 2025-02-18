import 'package:fe/services/UrlAPI.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiBiddingService {
  final String apiUrl = "${UrlAPI.url}/bidding";
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
        url: 'ws://192.168.1.134.159:8080/ws',
        onConnect: (StompFrame frame) {
          print("✅ Kết nối WebSocket thành công!");

          stompClient.subscribe(
            destination: '/topic/newbidding',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                var response = jsonDecode(frame.body!);
                double newPrice = response; // Giá đấu giá mới

                print("🔔 Giá mới nhận được: \$$newPrice");

                // 🔥 Gọi callback để cập nhật UI ngay lập tức
                if (onNewBidReceived != null) {
                  onNewBidReceived!(newPrice);
                }
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => print('🚨 Lỗi WebSocket: $error'),
      ),
    );
    stompClient.activate();
  }

  Future<bool> placeBid(int itemId, double bidAmount) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");
      if (userId == null) {
        print("🚨 Người dùng chưa đăng nhập!");
        return false;
      }

      if (!stompClient.connected) {
        print("🚨 WebSocket chưa kết nối. Đang kết nối lại...");
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

      print("✅ Đã gửi yêu cầu đặt giá: \$$bidAmount");
      return true;
    } catch (e) {
      print("🚨 Lỗi đặt giá: $e");
      return false;
    }
  }
}
