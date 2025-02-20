import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/Auction.dart';

Future<void> generateAuctionCertificate(Auction item) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(
              "Độc lập - Tự do - Hạnh phúc",
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              color: PdfColors.grey300,
              child: pw.Text(
                "GIẤY CHỨNG NHẬN SẢN PHẨM ĐẤU GIÁ THÀNH CÔNG",
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text("Số: ${item.itemId}", style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),
            pw.Text(
              "Căn cứ theo hợp đồng đấu giá số: [Số hợp đồng] ngày ${item.startDate?.toLocal().toString().split(' ')[0]} giữa [LIVEAuction] và ${item.user?.name ?? "Không xác định"};",
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "Chúng tôi, [LIVEAuction], xin xác nhận:",
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),

            // **MỤC 1: NGƯỜI TRÚNG ĐẤU GIÁ**
            pw.Text("1. Người trúng đấu giá:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: "Họ và tên: ${item.user?.name ?? "Không xác định"}"),
            pw.Bullet(text: "CMND/CCCD số: [Số CMND/CCCD]"),
            pw.Bullet(text: "Ngày cấp: [Ngày cấp] tại [Nơi cấp]"),
            pw.Bullet(text: "Địa chỉ: [Địa chỉ người trúng đấu giá]"),
            pw.Bullet(text: "Số điện thoại: [Số điện thoại]"),
            pw.SizedBox(height: 10),

            // **MỤC 2: SẢN PHẨM ĐẤU GIÁ THÀNH CÔNG**
            pw.Text("2. Sản phẩm đấu giá thành công:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: "Tên sản phẩm: ${item.itemName ?? "Không xác định"}"),
            pw.Bullet(text: "Mô tả sản phẩm: ${item.description ?? "Không có mô tả"}"),
            pw.Bullet(text: "Giá trúng đấu giá: ${item.startingPrice?.toStringAsFixed(0)} VND"),
            pw.Bullet(text: "Phương thức thanh toán: [Tiền mặt/Chuyển khoản]"),
            pw.Bullet(text: "Thời gian và địa điểm nhận sản phẩm: [Thời gian, địa điểm]"),
            pw.SizedBox(height: 10),

            // **MỤC 3: XÁC NHẬN THANH TOÁN**
            pw.Text("3. Xác nhận thanh toán:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            item.ispaid == true
                ? pw.Text("✅ Đã thanh toán đầy đủ", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green))
                : pw.Text("❌ Chưa thanh toán (Còn lại: [Số tiền còn lại] VND, hạn thanh toán: [Ngày])",
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
            pw.SizedBox(height: 10),

            // **PHẦN KÝ XÁC NHẬN**
            pw.Text("Xác nhận của đơn vị tổ chức đấu giá",
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text("Ngày ${DateTime.now().toLocal().toString().split(' ')[0]}, tại [Địa điểm]"),
            pw.SizedBox(height: 40),
            pw.Text("Đại diện đơn vị tổ chức đấu giá", style: pw.TextStyle(fontSize: 12)),
            pw.Text("(Ký, đóng dấu)", style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)),
          ],
        );
      },
    ),
  );

  // **LƯU FILE**
  final output = await getExternalStorageDirectory();
  final file = File("${output!.path}/Auction_Certificate_${item.itemId}.pdf");
  await file.writeAsBytes(await pdf.save());

  // **MỞ FILE**
  OpenFile.open(file.path);
}
