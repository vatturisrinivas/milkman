import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:milkman/screens/dashboardScreens/sellerHomeScreen.dart';
import 'package:milkman/widgets/userManager.dart';

Future<bool> sellerLoginWidget(BuildContext context, String phone, String password,) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("sellers").doc(phone).get();

    if (!doc.exists) return false;

    String storedPassword = doc["password"];
    String storedName= doc['name'];
    String hashedInputPassword = sha256.convert(utf8.encode(password)).toString();;

    if(storedPassword == hashedInputPassword){
      userManager().saveUserData(phone: phone, role: "seller",name: storedName);
      String? phoneNumber = await userManager().getUserPhone();
      print(phoneNumber.toString()); // This will print the actual phone number.

      Navigator.push(context, MaterialPageRoute(builder: (context)=>sellerHomeScreen()));
      return true;
    }
    else{
      return false;
    }
  } catch (e) {
    print("Seller Login Error: $e");
    return false;
  }
}