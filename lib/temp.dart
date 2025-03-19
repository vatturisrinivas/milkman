import 'package:cloud_firestore/cloud_firestore.dart';
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
  //TextEditingController morningRateController = TextEditingController();
  // TextEditingController eveningRateController = TextEditingController();
  String selectedTime = 'morning'; // Default selection
  late PageController _pageController;
  DateTime currentDate =DateTime.now();
  int baseMonthIndex=0;
  Map<String,Map<String,dynamic>> milkEntries={};
  // double morningRatePerLiter = 0;
  // double eveningRatePerLiter = 0;
  // Map<String, double> totalMilkForMonth = {'morning': 0.0, 'evening': 0.0};
  // double? totalAmount;


  @override
  void initState() {
    super.initState();
    baseMonthIndex = (currentDate.year * 12 + currentDate.month) - (2024 * 12 + 1);
    _pageController = PageController(initialPage: baseMonthIndex);
    fetchMilkEntries();
    // fetchMonthlySummary();
  }

  // Function to add milk entry for morning or evening
  Future<void> addMilkEntry() async {
    double amount = double.tryParse(milkController.text) ?? 0;
    if (amount <= 0) return;

    String dateId = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.sellerPhone)
        .collection('milkData')
        .doc(dateId)
        .set({
      selectedTime: amount, // 'morning' or 'evening'
      'timestamp': FieldValue.serverTimestamp(),
    },
        SetOptions(merge: true));

    milkController.clear();
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

    // double totalMorning = 0.0;
    // double totalEvening = 0.0;

    setState(() {
      milkEntries = {};
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>? ?? {};
        // double morningMilk = (data['morning'] ?? 0).toDouble();
        // double eveningMilk = (data['evening'] ?? 0).toDouble();
        milkEntries[doc.id] = {
          'morning': data['morning'] ?? 0,
          'evening': data['evening'] ?? 0,
        };
        // totalMorning += morningMilk;
        // totalEvening += eveningMilk;
      }
      // totalMilkForMonth = {
      //   'morning': totalMorning,
      //   'evening': totalEvening,
      // };
    });
  }

  // Future<void> saveMonthlySummary() async {
  //   String monthId = DateFormat('yyyy-MM').format(currentDate);
  //
  //   double? totalMorningMilk = totalMilkForMonth['morning']??0;
  //   double? totalEveningMilk = totalMilkForMonth['evening']??0;
  //   double morningRate = morningRatePerLiter??0;
  //   double eveningRate = eveningRatePerLiter??0;
  //   double morningTotal = totalMorningMilk * morningRate;
  //   double eveningTotal = totalEveningMilk * eveningRate;
  //   double grandTotal = morningTotal + eveningTotal;
  //
  //   print(totalEveningMilk);
  //
  //   await FirebaseFirestore.instance
  //       .collection('sellers')
  //       .doc(widget.sellerPhone)
  //       .collection('monthlySummary')
  //       .doc(monthId)
  //       .set({
  //     'morningMilk': totalMorningMilk,
  //     'eveningMilk': totalEveningMilk,
  //     'morningRate': morningRate,
  //     'eveningRate': eveningRate,
  //     'morningTotal': morningTotal,
  //     'eveningTotal': eveningTotal,
  //     'grandTotal': grandTotal,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Monthly Summary Saved!"))
  //   );
  // }
  // Future<void> fetchMonthlySummary() async {
  //   String monthId = DateFormat('yyyy-MM').format(currentDate);
  //
  //   DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('sellers')
  //       .doc(widget.sellerPhone)
  //       .collection('monthlySummary')
  //       .doc(monthId)
  //       .get();
  //
  //   if (snapshot.exists) {
  //     var data = snapshot.data() as Map<String, dynamic>;
  //     setState(() {
  //       totalMilkForMonth = {
  //         'morning': data['morningMilk'],
  //         'evening': data['eveningMilk'],
  //       };
  //       morningRatePerLiter = data['morningRate'];
  //       eveningRatePerLiter = data['eveningRate'];
  //       totalAmount= data['grandTotal']??0;
  //       print(morningRatePerLiter);
  //       morningRateController.text=morningRatePerLiter.toString();
  //       print(morningRateController.text);
  //       eveningRateController.text=eveningRatePerLiter.toString();
  //     });
  //   }
  // }



  void onPageChanged(int index) {
    setState(() {
      int newYear = 2024 + (index ~/ 12);  // Calculate year based on index
      int newMonth = (index % 12) + 1;     // Get the correct month (1-12)

      currentDate = DateTime(newYear, newMonth, 1); // Always set the 1st day of the month
      // fetchMonthlySummary();
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
        'evening': milkEntries[dateStr]?['evening'] ?? 0,
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

  // double calculateTotalMilk(String time) {
  //   return milkEntries.values.fold(0, (sum, entry) => sum + entry[time]);
  // }

  // double calculatePayableAmount() {
  //   return calculateTotalMilk() * ratePerLiter;
  // }
  // void showTotalDialog() {
  //   morningRateController.clear();
  //   eveningRateController.clear();
  //   // morningRatePerLiter = 0;
  //   // eveningRatePerLiter = 0;
  //   fetchMonthlySummary();
  //   showDialog(
  //     context: context,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setState) => AlertDialog(
  //         title: Center(child: Text("Total")),
  //         content: ConstrainedBox(
  //           constraints: BoxConstraints(maxHeight: 250,maxWidth: double.infinity),
  //           child: Center(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Container(height:45,width:80,child: Center(child: Text('morning',style: TextStyle(fontSize: 20),))),
  //                     SizedBox(width: 30,),
  //                     Container(height:45,width:80,child: Center(child: Text('evening',style: TextStyle(fontSize: 20)))),
  //                   ],
  //                 ),
  //
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Container(height:45,width:80,child: Text('${calculateTotalMilk('morning')} L',style: TextStyle(fontSize: 25))),
  //                     SizedBox(width: 30,),
  //                     Container(height:45,width:80,child: Text('${calculateTotalMilk('evening')} L',style: TextStyle(fontSize: 25))),
  //                   ],
  //                 ),
  //
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Container(height:45,width:80,child: Text('X')),
  //                     SizedBox(width: 30,),
  //                     Container(height:45,width:80,child: Text('X')),
  //                   ],
  //                 ),
  //
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Container(
  //                       height: 40,
  //                       width: 80,
  //                       child: TextFormField(
  //                         controller: morningRateController,
  //                         decoration: InputDecoration(
  //                           label: Text('rate'),
  //                           border: OutlineInputBorder(),
  //                         ),
  //                         onChanged: (value){
  //                           setState((){
  //                             morningRatePerLiter=double.tryParse(value)??0;
  //                           });
  //                         },
  //                       ),
  //                     ),
  //                     SizedBox(width: 30,),
  //                     Container(
  //                       height: 40,
  //                       width: 80,
  //                       child: TextFormField(
  //                         controller: eveningRateController,
  //                         decoration: InputDecoration(
  //                           label: Text('rate'),
  //                           border: OutlineInputBorder(
  //                           )
  //                         ),
  //                         onChanged: (value){
  //                           setState((){
  //                             eveningRatePerLiter=double.tryParse(value)??0;
  //                           });
  //                         },
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Container(height:45,width:80,child: Text("${calculateTotalMilk('morning')*morningRatePerLiter}",style: TextStyle(fontSize: 25))),
  //                     SizedBox(width: 30,),
  //                     Container(height:45,width:80,child: Text("${calculateTotalMilk('evening')*eveningRatePerLiter}",style: TextStyle(fontSize: 25)))
  //                   ],
  //                 ),
  //
  //                 Center(
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       //print(calculateTotalMilk('morning')*morningRatePerLiter),
  //                       Text("${(calculateTotalMilk('morning')*morningRatePerLiter)+(calculateTotalMilk('evening')*eveningRatePerLiter)}")
  //                     ],
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //         ),
  //         actions: [
  //
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: Text("Close"),
  //               ),
  //               TextButton(
  //                   onPressed: saveMonthlySummary,
  //                   child: Text('save')
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sellerName),
        actions: [
          TextButton(
            onPressed: () {
              // showTotalDialog(
              //   // context,
              //   // morningRateController,
              //   // eveningRateController,
              //   // calculateTotalMilk,
              //   // morningRatePerLiter,
              //   // eveningRatePerLiter,
              //   // saveMonthlySummary,
              //   //     (double value) => setState(() => morningRatePerLiter = value),
              //   //     (double value) => setState(() => eveningRatePerLiter = value),
              // );
            },
            child: Row(
              children: [
                Icon(Icons.currency_rupee),
                // Text('$totalAmount'),
              ],
            ),
          )

        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: milkController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Enter Milk Amount"),
                  ),
                ),
                SizedBox(width: 10),
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
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addMilkEntry,
                  child: Text("Add"),
                ),
              ],
            ),
          ),
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
                        title: Text(entry['date']),
                        subtitle: Text("Morning: ${entry['morning']} L | Evening: ${entry['evening']} L"),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Expanded(
          //   child: StreamBuilder<List<Map<String, dynamic>>>(
          //     stream: getMilkEntries(),
          //     builder: (context, snapshot) {
          //       if (!snapshot.hasData) return CircularProgressIndicator();
          //
          //       var milkEntries = snapshot.data!;
          //       return ListView.builder(
          //         itemCount: milkEntries.length,
          //         itemBuilder: (context, index) {
          //           var entry = milkEntries[index];
          //           return ListTile(
          //             title: Text("Date: ${entry['date']}"),
          //             subtitle: Text(
          //               "Morning: ${entry['morning']} L\nEvening: ${entry['evening']} L",
          //             ),
          //           );
          //         },
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
