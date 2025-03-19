import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyTotalModal extends StatefulWidget {
  final String sellerPhone;
  final double totalMorningMilk;
  final double totalEveningMilk;
  final DateTime month;

  MonthlyTotalModal({
    required this.sellerPhone,
    required this.totalMorningMilk,
    required this.totalEveningMilk,
    required this.month,
  });

  @override
  _MonthlyTotalModalState createState() => _MonthlyTotalModalState();
}

class _MonthlyTotalModalState extends State<MonthlyTotalModal> {
  TextEditingController morningRateController = TextEditingController();
  TextEditingController eveningRateController = TextEditingController();

  double morningRate = 0;
  double eveningRate = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExistingData(); // Load existing data if available
  }

  Future<void> fetchExistingData() async {
    String monthKey = DateFormat('yyyy-MM').format(widget.month);

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.sellerPhone)
        .collection('monthlySummary')
        .doc(monthKey)
        .get();

    if (doc.exists) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        setState(() {
          morningRate = data['morningRate'] ?? 0;
          eveningRate = data['eveningRate'] ?? 0;
          morningRateController.text = morningRate.toString();
          eveningRateController.text = eveningRate.toString();
        });
      }
    }
    setState(() {
      isLoading = false; // Stop loading when data is fetched
    });
  }

  Future<void> saveMonthlyTotal() async {
    String monthKey = DateFormat('yyyy-MM').format(widget.month);

    double morningTotal = widget.totalMorningMilk * morningRate;
    double eveningTotal = widget.totalEveningMilk * eveningRate;
    double grandTotal = morningTotal + eveningTotal;

    try {
      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(widget.sellerPhone)
          .collection('monthlySummary')
          .doc(monthKey)
          .set({
        'month': widget.month,
        'totalMorningMilk': widget.totalMorningMilk,
        'totalEveningMilk': widget.totalEveningMilk,
        'morningRate': morningRate,
        'eveningRate': eveningRate,
        'totalMorningCost': morningTotal,
        'totalEveningCost': eveningTotal,
        'grandTotal': grandTotal,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Monthly total saved successfully!")),
      );
      Navigator.pop(context); // Close modal after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double morningTotal = widget.totalMorningMilk * morningRate;
    double eveningTotal = widget.totalEveningMilk * eveningRate;
    double grandTotal = morningTotal + eveningTotal;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Monthly Total", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Morning Milk:"),
              Text("${widget.totalMorningMilk.toStringAsFixed(2)} L"),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Evening Milk:"),
              Text("${widget.totalEveningMilk.toStringAsFixed(2)} L"),
            ],
          ),

          SizedBox(height: 20),

          TextField(
            controller: morningRateController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Morning Rate per Litre"),
            onChanged: (value) {
              setState(() {
                morningRate = double.tryParse(value) ?? 0;
              });
            },
          ),

          TextField(
            controller: eveningRateController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Evening Rate per Litre"),
            onChanged: (value) {
              setState(() {
                eveningRate = double.tryParse(value) ?? 0;
              });
            },
          ),

          SizedBox(height: 20),

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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white
                ),
                onPressed: (morningRate > 0 || eveningRate > 0) ? saveMonthlyTotal : null,
                child: Text("Save"),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Close"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
