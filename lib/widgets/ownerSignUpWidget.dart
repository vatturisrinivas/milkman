import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:milkman/screens/dashboardScreens/ownerHomeScreen.dart';
import 'dart:convert';

import 'package:milkman/widgets/userManager.dart';

Future<bool> ownerSignUpWidget(BuildContext context, String phone, String password, String name) async {
  try {
    String hashedPassword = sha256.convert(utf8.encode(password)).toString();

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("owners")
        .doc(phone)
        .get();

    if (doc.exists) {
      print("Phone number already registered!");
      return false;
    }

    await FirebaseFirestore.instance.collection("owners").doc(phone).set({
      "phone": phone,
      "name": name,
      "password": hashedPassword,
      "role": "owner"
    });

    //save owner info in the local storage
    await userManager().saveUserData(phone: phone, name: name, role: "owner",);

    Navigator.push(context, MaterialPageRoute(builder: (context)=>ownerHomeScreen()));

    return true;
  } catch (e) {
    print("Owner Signup Error: $e");
    return false;
  }
}
