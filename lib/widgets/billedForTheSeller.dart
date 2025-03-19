import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showMonthlyTotalBottomSheet(BuildContext context, {
  required String sellerPhone,
  required double totalMorningMilk,
  required double totalEveningMilk,
  required DateTime month,
  required double morningRate,
  required double eveningRate,
}) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      double morningTotal = totalMorningMilk * morningRate;
      double eveningTotal = totalEveningMilk * eveningRate;
      double grandTotal = morningTotal + eveningTotal;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Monthly Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),

            Text("Seller: $sellerPhone", style: TextStyle(fontWeight: FontWeight.w500)),

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Month:"),
                Text(DateFormat('MMMM yyyy').format(month)),
              ],
            ),

            Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Morning Milk:"),
                Text("${totalMorningMilk.toStringAsFixed(2)} L"),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Evening Milk:"),
                Text("${totalEveningMilk.toStringAsFixed(2)} L"),
              ],
            ),

            Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Morning Rate per Litre:"),
                Text("₹${morningRate.toStringAsFixed(2)}"),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Evening Rate per Litre:"),
                Text("₹${eveningRate.toStringAsFixed(2)}"),
              ],
            ),

            Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Morning Total:"),
                Text("₹${morningTotal.toStringAsFixed(2)}"),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Evening Total:"),
                Text("₹${eveningTotal.toStringAsFixed(2)}"),
              ],
            ),

            Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Grand Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₹${grandTotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),

            SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ),
          ],
        ),
      );
    },
  );
}
