import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';

class ApiUserService {
  static const String baseUrl = "http://192.168.1.30:8080/api/users";
  static const String loginUrl = "http://192.168.1.30:8080/api/auth";

  Future<bool> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse("http://192.168.1.30:8080/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    print("📢 API LOGIN STATUS: ${response.statusCode}");
    print("📢 API LOGIN BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // ✅ Decode JSON trước khi trả về
    } else {
      print("🚨 Lỗi đăng nhập: ${response.body}");
      return null;
    }
  }

  // Đăng xuất người dùng
  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }


}
