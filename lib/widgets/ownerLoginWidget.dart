import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:milkman/screens/dashboardScreens/ownerHomeScreen.dart';
import 'package:milkman/widgets/userManager.dart';

Future<bool> ownerLoginWidget(BuildContext context, String phone, String password) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("owners")
        .doc(phone)
        .get();

    if (!doc.exists) {
      print("Owner not found!");
      return false;
    }

    String storedPassword = doc["password"];
    String storedName= doc['name'];
    String hashedInputPassword = sha256.convert(utf8.encode(password)).toString();

    if (storedPassword == hashedInputPassword) {
      print("Owner Logged In!");


      //save owner info in the local storage
      await userManager().saveUserData(phone: phone,role: "owner",name: storedName);


      Navigator.push(context, MaterialPageRoute(builder: (context)=>ownerHomeScreen()));
      return true;
    } else {
      print("Incorrect Password!");
      return false;
    }
  } catch (e) {
    print("Owner Login Error: $e");
    return false;
  }
}
