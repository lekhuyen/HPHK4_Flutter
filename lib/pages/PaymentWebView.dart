import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/ApiPaymentService.dart';
import 'HomePage.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final String productId; // ✅ Thêm productId để gọi API callback

  const PaymentWebView({super.key, required this.paymentUrl, required this.productId});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  final ApiPaymentService _apiPaymentService = ApiPaymentService();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // ✅ Bật JavaScript
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (url.contains("vnp_ResponseCode=00")) {
              print("✅ Thanh toán thành công, gọi API callback...");
              _apiPaymentService.handlePaymentCallback(widget.productId).then((_) {
                // ✅ Sau khi gọi callback, chuyển về trang MyBidsPage
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Homepage(initialIndex: 3)), // Chuyển về MyBidsPage
                      (route) => false, // Xóa toàn bộ các trang trước đó khỏi stack
                );
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VNPay Payment")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
