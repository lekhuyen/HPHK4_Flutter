import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Auction_Items.dart';

class ApiPaymentService {
  static const String _baseUrl = "http://192.168.1.30:8080"; // ✅ Đổi thành URL backend của bạn

  Future<String?> createPayment(String productId, double amount, String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // ✅ Lấy token từ SharedPreferences

    if (token == null) {
      print("🚨 Lỗi: Không tìm thấy token! Người dùng chưa đăng nhập?");
      return null;
    }
    final url = Uri.parse("$_baseUrl/api/v1/payment/vn-pay").replace(queryParameters: {
      "productId": productId,
      "amount": amount.toString(),
      "orderId": orderId,
    });

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );
    print("📢 API PAYMENT STATUS: ${response.statusCode}");
    print("📢 API PAYMENT BODY: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // ✅ Sửa lỗi lấy `paymentUrl` từ `data` thay vì `result`
      if (data.containsKey("data") && data["data"].containsKey("paymentUrl")) {
        String paymentUrl = data["data"]["paymentUrl"];
        print("✅ Payment URL: $paymentUrl");
        return paymentUrl;
      } else {
        print("🚨 Lỗi: API không trả về paymentUrl trong `data`!");
        return null;
      }
    } else {
      print("🚨 Lỗi tạo thanh toán: ${response.body}");
      return null;
    }
  }

  Future<Map<String, List<AuctionItems>>?> getUserBids() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');

    if (token == null || userId == null) {
      print("🚨 Không tìm thấy token hoặc userId!");
      return null;
    }

    final url = Uri.parse("http://192.168.1.30:8080/api/v1/payment/bids/$userId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      print("📢 API BID STATUS: ${response.statusCode}");
      print("📢 API BID BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔥 Kiểm tra key JSON để tránh lỗi
        if (!data.containsKey("paid") || !data.containsKey("unpaid")) {
          print("🚨 API trả về dữ liệu không đúng định dạng!");
          return null;
        }

        List<AuctionItems> paidItems = (data["paid"] as List)
            .map((e) => AuctionItems.fromJson(e))
            .toList();

        List<AuctionItems> unpaidItems = (data["unpaid"] as List)
            .map((e) => AuctionItems.fromJson(e))
            .toList();

        return {"paid": paidItems, "unpaid": unpaidItems};
      } else {
        print("🚨 Lỗi lấy danh sách đấu giá: ${response.body}");
        return null;
      }
    } catch (e) {
      print("🚨 Exception khi gọi API: $e");
      return null;
    }
  }


}

