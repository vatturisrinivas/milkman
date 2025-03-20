import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milkman/screens/signUpAndLoginScreens/ownerandsellerloginpage.dart';
import 'package:milkman/widgets/addingAndFetchingSellersData.dart';
import 'package:milkman/widgets/billedForTheSeller.dart';
import 'package:milkman/widgets/userManager.dart';

class sellerHomeScreen extends StatefulWidget {
  sellerHomeScreen({super.key});

  @override
  _sellerHomeScreenState createState() => _sellerHomeScreenState();
}

class _sellerHomeScreenState extends State<sellerHomeScreen> {
  String sellerPhone="Loading...";
  String sellerName = "Loading...";
  late PageController _pageController;
  DateTime currentDate = DateTime.now();
  int baseMonthIndex = 0; // This will store the current month index for PageView
  Map<String, Map<String, dynamic>> milkEntries = {};
  double morningRate = 0;
  double eveningRate = 0;
  double morningMilk = 0;
  double eveningMilk = 0;
  double grandTotal = 0;
  bool isLoading = true;


  // AddingAndFetchingSellersData sellerData = AddingAndFetchingSellersData(
  //   currentDate: DateTime.now(),
  //   sellerPhone: "sellerPhoneNumber",
  // );
  late AddingAndFetchingSellersData sellerData;

  @override
  void initState() {
    super.initState();
    sellerData = AddingAndFetchingSellersData();
    baseMonthIndex = (currentDate.year * 12 + currentDate.month) - (2024 * 12 + 1); // Relative to Jan 2024
    _pageController = PageController(initialPage: baseMonthIndex);
    fetchSellerPhoneAndName();
    fetchSellerData();
  }


  Future<void> fetchSellerData() async {
    if (sellerPhone == null) return; // Ensure it's not null
    await sellerData.fetch(currentDate, sellerPhone!);
    setState(() {
      morningRate = sellerData.morningRatePerLitre;
      eveningRate = sellerData.eveningRatePerLitre;
      morningMilk = sellerData.morningMilkAmount;
      eveningMilk = sellerData.eveningMilkAmount;
      grandTotal = sellerData.grandTotal;
      isLoading = false;
    });
  }

  Future<void> fetchSellerPhoneAndName() async {
    String? phone = await userManager().getUserPhone();
    String? name= await userManager().getUserName();
    setState(() {
      sellerPhone=phone??"No Contact Info";
      sellerName=name??"unknown user";
    });
    if (sellerPhone != null) {
      await fetchSellerData();
      await fetchMilkEntries();
    }
  }

  Future<void> fetchMilkEntries() async {
    String monthPrefix = DateFormat('yyyy-MM').format(currentDate);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerPhone)
        .collection('milkData')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: "$monthPrefix-01")
        .where(FieldPath.documentId, isLessThanOrEqualTo: "$monthPrefix-31")
        .orderBy(FieldPath.documentId)
        .get();

    setState(() {
      milkEntries = {};
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>? ?? {};
        double? morningLacto = data.containsKey('morning_lactometer') ? data['morning_lactometer'].toDouble() : null;
        double? eveningLacto = data.containsKey('evening_lactometer') ? data['evening_lactometer'].toDouble() : null;
        milkEntries[doc.id] = {
          'morning': data['morning'] ?? 0,
          'morning_lactometer': morningLacto,
          'evening': data['evening'] ?? 0,
          'evening_lactometer': eveningLacto,
        };
      }
    });
  }

  /// Updates the displayed month when swiping
  void onPageChanged(int index) {
    setState(() {
      // currentDate = DateTime(2024, 1).add(Duration(days: index * 30)); // Adjusts for months dynamically
      // int newYear = 2024 + (index ~/ 12);  // Calculate year based on index
      // int newMonth = (index % 12) + 1;     // Get the correct month (1-12)
      //
      // currentDate = DateTime(newYear, newMonth, 1); // Always set the 1st day of the month
      DateTime baseDate = DateTime(2024, 1, 1);
      currentDate = DateTime(baseDate.year + (index ~/ 12), (index % 12) + 1, 1);

      fetchSellerData();
      fetchMilkEntries();
    });
  }

  /// Generates a list of dates for the selected month
  List<Map<String, dynamic>> generateMonthData() {
    int daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    List<Map<String, dynamic>> monthData = [];

    DateTime today = DateTime.now(); // Get current date

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDateDay = DateTime(currentDate.year, currentDate.month, day);

      // Exclude future dates
      if (currentDateDay.isAfter(today)) break;

      String dateStr = DateFormat('yyyy-MM-dd').format(currentDateDay);
      monthData.add({
        'date': dateStr,
        'morning': milkEntries[dateStr]?['morning'] ?? 0,
        'morning_lactometer': milkEntries[dateStr]?['morning_lactometer'] ?? '-',
        'evening': milkEntries[dateStr]?['evening'] ?? 0,
        'evening_lactometer': milkEntries[dateStr]?['evening_lactometer'] ?? '-',
      });
    }

    return monthData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy').format(currentDate),), // Display selected month
        actions: [
          TextButton(
              onPressed: () {
                showMonthlyTotalBottomSheet(
                  context,
                  sellerPhone: sellerPhone!,
                  totalMorningMilk: morningMilk,
                  totalEveningMilk: eveningMilk,
                  month: currentDate,
                  morningRate: morningRate,
                  eveningRate: eveningRate,
                );
              },
              child: Row(
                children: [
                  Icon(Icons.currency_rupee),
                  Text(
                    isLoading ? "Loading..." : "${sellerData.grandTotal}",
                  ),

                ],
              )
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(sellerName),  // Replace with actual data
              accountEmail: Text(sellerPhone), // Replace with actual email
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.black),
              ),
              decoration: BoxDecoration(
                color: Colors.black87,
              ),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("History (Comming Soon...)"),
              onTap: () {
                // Navigate to Milk Sales History Screen
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                userManager().clearUserData();
                Navigator.push(context, MaterialPageRoute(builder: (context) => ownerandsellerloginpage()));
              },
            ),
          ],
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: onPageChanged, // Detect when user swipes
        itemBuilder: (context, index) {
          List<Map<String, dynamic>> monthData = generateMonthData();

          return ListView.builder(
            itemCount: monthData.length,
            itemBuilder: (context, dayIndex) {
              var entry = monthData[dayIndex];
              return Card(
                color: Colors.black,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(entry['date'],style: TextStyle(color: Colors.white),),
                  subtitle: Text("Morning: ${entry['morning']} L | Evening: ${entry['evening']} L",style: TextStyle(color: Colors.white),),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Metre",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        "${entry['morning_lactometer'] ?? '-'} | ${entry['evening_lactometer'] ?? '-'}",
                        style: TextStyle(color: Colors.white,fontSize: 15),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
