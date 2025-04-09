import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MilkReportService {

  Future<void> showDatePickerAndGenerateReport(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023), // Adjust the range as needed
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor: Colors.black, // Header background color
            hintColor: Colors.black, // Selected day highlight color
            colorScheme: ColorScheme.dark(
              primary: Colors.grey, // Header color
              onPrimary: Colors.white, // Text color on header
              onSurface: Colors.white, // Normal text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Buttons (CANCEL, OK) color
              ),
            ),
          ), // Customize theme if needed
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      String selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      // Generate and show the report immediately after selecting the date
      await generateDailyReport(selectedDate);
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch sellers' milk data for today
  Future<List<Map<String, dynamic>>> fetchTodaySellersData(String selectedDate) async {
    List<Map<String, dynamic>> sellersList = [];
    // String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    QuerySnapshot sellersSnapshot = await _firestore.collection("sellers").get();

    for (var sellerDoc in sellersSnapshot.docs) {
      String phoneNumber = sellerDoc.id;
      var sellerData = sellerDoc.data() as Map<String, dynamic>;

      // Fetch today's milk data for this seller
      DocumentSnapshot milkDoc = await _firestore
          .collection("sellers")
          .doc(phoneNumber)
          .collection("milkData")
          .doc(selectedDate)
          .get();

      double morningMilk = 0.0;
      double eveningMilk = 0.0;
      if (milkDoc.exists) {
        var milkEntry = milkDoc.data() as Map<String, dynamic>;
        morningMilk = (milkEntry["morning"] ?? 0).toDouble();
        eveningMilk = (milkEntry["evening"] ?? 0).toDouble();
      }

      double totalMilk = morningMilk + eveningMilk;

      sellersList.add({
        "name": sellerData["name"] ?? "Unknown",
        "phoneNumber": phoneNumber,
        "morningMilk": morningMilk,
        "eveningMilk": eveningMilk,
        "totalMilk": totalMilk,
      });
    }

    return sellersList;
  }

  /// Generate and save a PDF report for today
  Future<void> generateDailyReport(String selectedDate) async {
    try {
      final poppinsRegular =
      pw.Font.ttf(await rootBundle.load("assets/fonts/Poppins-Regular.ttf"));
      final poppinsBold =
      pw.Font.ttf(await rootBundle.load("assets/fonts/Poppins-Bold.ttf"));

      List<Map<String, dynamic>> sellers = await fetchTodaySellersData(selectedDate);
      final pdf = pw.Document();
      // final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Text("Milk Collection Report - $selectedDate",
                  style: pw.TextStyle(
                      font: poppinsBold, fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              // Table Header & Data
              pw.Table.fromTextArray(
                headers: ["Seller Name", "Phone", "Morning (L)", "Evening (L)", "Total (L)"],
                data: sellers.map((seller) {
                  return [
                    seller["name"],
                    seller["phoneNumber"],
                    seller["morningMilk"].toStringAsFixed(2),
                    seller["eveningMilk"].toStringAsFixed(2),
                    seller["totalMilk"].toStringAsFixed(2),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(font: poppinsBold, fontSize: 12),
                cellStyle: pw.TextStyle(font: poppinsRegular, fontSize: 10),
              ),
            ];
          },
        ),
      );

      final Uint8List pdfBytes = await pdf.save();

      final directory = Directory("/storage/emulated/0/Download");
      final filePath = "${directory.path}/Milk_Report_$selectedDate.pdf";
      final File file = File(filePath);
      await file.writeAsBytes(pdfBytes, flush: true);
      await OpenFilex.open(filePath, type: "application/pdf");

    } catch (e) {
      print("⚠️ Error generating PDF: $e");
    }
  }
}
