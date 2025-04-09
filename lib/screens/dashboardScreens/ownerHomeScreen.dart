import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:milkman/screens/eachSellerDetails/eachSellerDetails.dart';
import 'package:milkman/screens/signUpAndLoginScreens/ownerandsellerloginpage.dart';
import 'package:milkman/screens/signUpAndLoginScreens/sellerSignUpScreen.dart';
import 'package:milkman/widgets/QRManager.dart';
import 'package:milkman/widgets/dailyReport.dart';
import 'package:milkman/widgets/getSellers.dart';
import 'package:milkman/widgets/sellerSignUpWidget.dart';
import 'package:milkman/widgets/userManager.dart';

class ownerHomeScreen extends StatefulWidget {
  const ownerHomeScreen({super.key});

  @override
  State<ownerHomeScreen> createState() => _ownerHomeScreenState();
}

class _ownerHomeScreenState extends State<ownerHomeScreen> {

  String ownerName = "Loading...";
  String ownerPhone = "Loading...";

  final iconList = <IconData>[
    Icons.cloud_download_rounded,        // Download Report
    Icons.person_add,      // Add Seller
  ];

  void _onIconTap(int index) async {
    switch (index) {

      case 0:
      // Download Report
        MilkReportService reportService = MilkReportService();
        await reportService.showDatePickerAndGenerateReport(context);
        break;

      case 1:
      // Add Seller Dialog
        showDialog(
          context: context,
          builder: (context) => createSellerDialog(),
        ).then((_) {
          setState(() {}); // Refresh after seller added
        });
        break;
    }
  }



  @override
  void initState() {
    super.initState();
    fetchOwnerDetails();
  }

  /// Fetch owner details from SharedPreferences
  Future<void> fetchOwnerDetails() async {
    String? name = await userManager().getUserName();
    String? phone = await userManager().getUserPhone();
    setState(() {
      ownerName = name ?? "Unknown Owner";
      ownerPhone = phone ?? "No Contact Info";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
          title: const Text("Your Sellers",style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(ownerName),
              accountEmail: Text(ownerPhone),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.black),
              ),
              decoration: BoxDecoration(
                color: Colors.black87,
              ),
            ),
            ListTile(
              leading: Icon(Icons.cloud_download),
              title: Text("Download Report"),
              onTap: () async {
                MilkReportService reportService = MilkReportService();
                await reportService.showDatePickerAndGenerateReport(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                userManager().clearUserData();
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ownerandsellerloginpage()));
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getSellers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No sellers found."));
          }

          List<Map<String, dynamic>> sellers = snapshot.data!;

          return ListView.builder(
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              var seller = sellers[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                child: ListTile(
                  title: Text(seller['name'] ?? 'Unknown Seller',style: TextStyle(color: Colors.white,fontSize: 20),),
                  subtitle: Text(seller['phone'] ?? 'No Contact Info',style: TextStyle(color: Colors.white)),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>eachSellerDetailsScreen(sellerPhone: seller['phone'], sellerName: seller['name'],)));
                  },

                ),
                color: Colors.black,
              );
            },
          );
        },
      ),
      floatingActionButton: SizedBox(
        height: 80,
        width: 80,
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 20,
          shape: CircleBorder(),
          child: Icon(Icons.qr_code_scanner, color: Colors.black,size: 50,),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QrManager.getQrScannerScreen(context),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,


      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,// [Icons.download, Icons.person_add]
        elevation: 80,
        iconSize: 30,
        leftCornerRadius: 30,
        shadow: BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 12,
          spreadRadius: 0.5,
          color: Colors.grey,
        ),
        rightCornerRadius: 30,
        activeIndex: -1,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: _onIconTap,
        backgroundColor: Colors.white,
        activeColor: Colors.black,
        inactiveColor: Colors.black,
      ),



    );
  }
}
