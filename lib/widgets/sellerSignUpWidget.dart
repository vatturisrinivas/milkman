import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:milkman/widgets/userManager.dart';

Future<bool> createSeller(String ownerPhone, String sellerPhone, String sellerPassword, String name) async {
  try {
    String hashedPassword = sha256.convert(utf8.encode(sellerPassword)).toString();
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("sellers").doc(sellerPhone).get();

    if (doc.exists) {
      print("Seller phone already exists!");
      return false;
    }

    await FirebaseFirestore.instance.collection("sellers").doc(sellerPhone).set({
      "ownerUID": ownerPhone,
      "phone": sellerPhone,
      "name": name,
      "password": hashedPassword,
      "role": "seller"
    });

    //await userManager().saveUserData(phone: sellerPhone, role: "seller");

    return true;
  } catch (e) {
    print("Create Seller Error: $e");
    return false;
  }
}