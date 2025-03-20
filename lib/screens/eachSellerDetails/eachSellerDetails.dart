import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milkman/widgets/billingByTheOwner.dart';

class eachSellerDetailsScreen extends StatefulWidget {
  final String sellerPhone;
  final String sellerName;

  eachSellerDetailsScreen({required this.sellerPhone, required this.sellerName});

  @override
  _eachSellerDetailsScreenState createState() => _eachSellerDetailsScreenState();
}

class _eachSellerDetailsScreenState extends State<eachSellerDetailsScreen> {
  TextEditingController milkController = TextEditingController();
  TextEditingController lactoMetreController = TextEditingController();
  String selectedTime = 'morning'; // Default selection
  late PageController _pageController;
  DateTime currentDate =DateTime.now();
  int baseMonthIndex=0;
  Map<String,Map<String,dynamic>> milkEntries={};
  double totalMorningMilk = 0;
  double totalEveningMilk = 0;



  @override
  void initState() {
    super.initState();
    baseMonthIndex = (currentDate.year * 12 + currentDate.month) - (2024 * 12 + 1);
    _pageController = PageController(initialPage: baseMonthIndex);
    fetchMilkEntries();
  }

  // Function to add milk entry for morning or evening
  Future<void> addMilkEntry() async {
    double amount = double.tryParse(milkController.text) ?? 0;
    double lactometerValue = double.tryParse(lactoMetreController.text) ?? 0;

    if (amount <= 0) return;

    String dateId = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Map<String, dynamic> dataToUpdate = {
      selectedTime: amount, // 'morning' or 'evening'
      'timestamp': FieldValue.serverTimestamp(),
    };

    //Only add lactometer value if it's entered
    if (lactoMetreController.text.isNotEmpty && lactometerValue != null && lactometerValue > 0) {
      dataToUpdate['${selectedTime}_lactometer'] = lactometerValue;
    }

    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.sellerPhone)
        .collection('milkData')
        .doc(dateId)
        .set(dataToUpdate, SetOptions(merge: true));
        // .set({
        //   selectedTime: amount, // 'morning' or 'evening'
        //   'timestamp': FieldValue.serverTimestamp(),
        // }, SetOptions(merge: true));

    milkController.clear();
    lactoMetreController.clear();
    fetchMilkEntries();
    // fetchMonthlySummary();
  }


  Future<void> fetchMilkEntries() async {
    String monthPrefix = DateFormat('yyyy-MM').format(currentDate);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.sellerPhone)
        .collection('milkData')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: "$monthPrefix-01")
        .where(FieldPath.documentId, isLessThanOrEqualTo: "$monthPrefix-31")
        .orderBy(FieldPath.documentId)
        .get();

    // setState(() {
    //   milkEntries = {};
    //   for (var doc in snapshot.docs) {
    //     var data = doc.data() as Map<String, dynamic>? ?? {};
    //     milkEntries[doc.id] = {
    //       'morning': data['morning'] ?? 0,
    //       'evening': data['evening'] ?? 0,
    //     };
    //
    //   }
    //
    // });
    setState(() {
      milkEntries = {};
      totalMorningMilk = 0;
      totalEveningMilk = 0;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>? ?? {};
        double morning = (data['morning'] ?? 0).toDouble();
        double evening = (data['evening'] ?? 0).toDouble();
        double? morningLacto = data.containsKey('morning_lactometer') ? data['morning_lactometer'].toDouble() : null;
        double? eveningLacto = data.containsKey('evening_lactometer') ? data['evening_lactometer'].toDouble() : null;

        milkEntries[doc.id] = {
          'morning': morning,
          'morning_lactometer': morningLacto,
          'evening': evening,
          'evening_lactometer': eveningLacto,
        };

        totalMorningMilk += morning;
        totalEveningMilk += evening;
      }
    });

    // Fetch monthly summary data
    // DocumentSnapshot monthlySummary = await FirebaseFirestore.instance
    //     .collection('sellers')
    //     .doc(widget.sellerPhone)
    //     .collection('monthlySummary')
    //     .doc(monthPrefix)
    //     .get();
    //
    // if (monthlySummary.exists) {
    //   var data = monthlySummary.data() as Map<String, dynamic>? ?? {};
    //   setState(() {
    //     totalMorningMilk = data['totalMorningMilk'] ?? totalMorningMilk;
    //     totalEveningMilk = data['totalEveningMilk'] ?? totalEveningMilk;
    //   });
    // }
  }


  void onPageChanged(int index) {
    setState(() {
      int newYear = 2024 + (index ~/ 12);  // Calculate year based on index
      int newMonth = (index % 12) + 1;     // Get the correct month (1-12)

      currentDate = DateTime(newYear, newMonth, 1); // Always set the 1st day of the month
      fetchMilkEntries();
    });
  }

  List<Map<String, dynamic>> generateMonthData() {
    int daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    List<Map<String, dynamic>> monthData = [];
    DateTime today = DateTime.now();

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDateDay = DateTime(currentDate.year, currentDate.month, day);
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


  // Fetch milk data for the seller
  Stream<List<Map<String, dynamic>>> getMilkEntries() {
    return FirebaseFirestore.instance
      .collection('sellers')
      .doc(widget.sellerPhone)
      .collection('milkData')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .handleError((error){
        print("Firestore error: $error");
      })
      .map((snapshot) => snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>?; // Ensure it's a Map
        return {
          'date': doc.id,
          'morning': data?['morning'] ?? 0,  // If 'morning' exists, use it; otherwise, default to 0
          'evening': data?['evening'] ?? 0,  // If 'evening' exists, use it; otherwise, default to 0
        };
      }).toList());
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.sellerName,style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size(70, 40),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Align(
                    alignment: Alignment.topCenter, // Positions the dialog at the top
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9, // Adjust width
                        margin: EdgeInsets.only(top: 40), // Adjust distance from the top
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                        ),
                        child: MonthlyTotalModal(
                          sellerPhone: widget.sellerPhone,
                          totalMorningMilk: totalMorningMilk,
                          totalEveningMilk: totalEveningMilk,
                          month: currentDate,
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.currency_rupee),
                  // Text('$totalAmount'),
                ],
              ),
            ),
          )
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Enter Milk Amount'),
                Spacer(),
                SizedBox(
                  height: 40,
                  width: 100,
                  child: TextField(
                    controller: milkController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Litre",
                      border: OutlineInputBorder( // Default border
                        borderRadius: BorderRadius.circular(8), // Rounded corners
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Enter Lactometre value(Optional)'),
                Spacer(),
                SizedBox(
                  height: 40,
                  width: 100,
                  child: TextField(
                    controller: lactoMetreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Null",
                      border: OutlineInputBorder( // Default border
                        borderRadius: BorderRadius.circular(8), // Rounded corners
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Select Time'),
                Spacer(),
                DropdownButton<String>(
                  value: selectedTime,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTime = newValue!;
                    });
                  },
                  items: ['morning', 'evening'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: addMilkEntry,
            child: Text("Add",style: TextStyle(fontSize: 20),),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(100, 50),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              )
            ),
          ),
          SizedBox(height: 15,),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                List<Map<String, dynamic>> monthData = generateMonthData();

                return ListView.builder(
                  itemCount: monthData.length,
                  itemBuilder: (context, dayIndex) {
                    var entry = monthData[dayIndex];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(entry['date'],style: TextStyle(color: Colors.white),),
                        subtitle: Text("Morning: ${entry['morning']} L | Evening: ${entry['evening']} L",style: TextStyle(color: Colors.white),),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Metre",  // Label
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              "${entry['morning_lactometer'] ?? '-'} | ${entry['evening_lactometer'] ?? '-'}",
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      color: Colors.black87,
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
