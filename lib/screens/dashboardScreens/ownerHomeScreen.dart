import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:milkman/screens/eachSellerDetails/eachSellerDetails.dart';
import 'package:milkman/screens/signUpAndLoginScreens/ownerandsellerloginpage.dart';
import 'package:milkman/screens/signUpAndLoginScreens/sellerSignUpScreen.dart';
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
      appBar: AppBar(
          title: const Text("Your Sellers",style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: Size(80, 40)
              ),
                onPressed: (){
                  showDialog(
                      context: context,
                      builder: (context)=>createSellerDialog()
                  ).then((_){
                    setState(() {});
                  });
                },
                icon: Icon(Icons.add)
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(ownerName),  // Replace with actual data
              accountEmail: Text(ownerPhone), // Replace with actual email
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
    );
  }
}
