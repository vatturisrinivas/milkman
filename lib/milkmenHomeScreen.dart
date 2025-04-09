// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:milkman/models/producersModel.dart';
//
// class milkmenHomeScreen extends StatefulWidget {
//   @override
//   _milkmenHomeScreenState createState() => _milkmenHomeScreenState();
// }
//
// class _milkmenHomeScreenState extends State<milkmenHomeScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Milkman? currentMilkman;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchMilkmanDetails();
//   }
//
//   Future<void> _fetchMilkmanDetails() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       final doc = await _firestore.collection('milkmen').doc(user.uid).get();
//       if (doc.exists) {
//         setState(() {
//           currentMilkman = Milkman.fromMap(doc.id, doc.data()!);
//         });
//       }
//     }
//   }
//
//   void _logout() async {
//     await _auth.signOut();
//     Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(currentMilkman != null ? 'Welcome, ${currentMilkman!.name}' : 'Milkman Dashboard'),
//         actions: [
//           IconButton(icon: Icon(Icons.logout), onPressed: _logout),
//         ],
//       ),
//       body: Center(
//         child: currentMilkman == null
//             ? CircularProgressIndicator()
//             : Text('Phone: ${currentMilkman!.phone}'),
//       ),
//     );
//   }
// }
