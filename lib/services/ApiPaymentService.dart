import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  }/// 🟢 Gọi API callback sau khi thanh toán thành công
  Future<void> handlePaymentCallback(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // ✅ Lấy token từ SharedPreferences

    if (token == null) {
      print("🚨 Lỗi: Không tìm thấy token! Người dùng chưa đăng nhập?");
      return;
    }

    final callbackUrl = Uri.parse("$_baseUrl/api/v1/payment/vn-pay-callback").replace(queryParameters: {
      "productId": productId,
    });

    final response = await http.get(
      callbackUrl,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    print("📢 API CALLBACK STATUS: ${response.statusCode}");
    print("📢 API CALLBACK BODY: ${response.body}");

    if (response.statusCode == 200) {
      print("✅ Callback thanh toán thành công, cập nhật MyBidsPage!");
    } else {
      print("🚨 Lỗi callback thanh toán: ${response.body}");
    }
  }
}
