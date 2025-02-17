import 'dart:convert';
// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';
import '../pages/LoginPage.dart';

class ApiUserService {
  static const String baseUrl = "http://173.16.16.135:8080/api/users";
  static const String loginUrl = "http://173.16.16.135:8080/api/auth";
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
      Uri.parse("http://173.16.16.135:8080/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    print("📢 API LOGIN STATUS: ${response.statusCode}");
    print("📢 API LOGIN BODY: ${response.body}");
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData.containsKey('result')) {
        var result = responseData['result'];
        if (result.containsKey('userId') && result.containsKey('token')) {
          String userId = result['userId'];
          String token = result['token'];
          String username = result['username'];
          print("✅ Lưu thông tin đăng nhập:");
          print("🆔 User ID: $userId");
          print("🔑 Token: $token");
          print("👤 Username: $username");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          try {
            String? userId = prefs.getString('userId');

            if (userId != null) {
              await prefs.setString("userId", userId);
              print("✅ Saved Seller ID: $userId");
            } else {
              print("❌ Error: userId not found in JWT payload");
            }
          } catch (e) {
            print("❌ JWT Decode Error: $e");
          }
          await prefs.setString('userId', userId);
          await prefs.setString('token', token);
          await prefs.setString('username', username);
          return responseData;
        } else {
          print("🚨 Lỗi: userId hoặc token không có trong response!");
          return null;
        }
      } else {
        print("🚨 Lỗi: Response không chứa key 'result'!");
        return null;
      }
    } else {
      print("🚨 Lỗi đăng nhập: ${response.body}");
      return null;
    }
  }

  // Đăng xuất người dùng
  Future<void> logoutUser() async {
    print("🚨 Đang thực hiện logout!");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('userId');
    await prefs.remove('token');

    print("📢 Đã xóa dữ liệu đăng nhập!");
  }
}
