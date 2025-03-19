import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Hash the password for security
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // 🔹 Sign Up (Save Phone + Hashed Password)
  Future<bool> signUp(String phone, String password, String userType) async {
    String hashedPassword = _hashPassword(password);

    try {
      DocumentReference userRef =
      _firestore.collection(userType).doc(phone); // Separate collections

      DocumentSnapshot userDoc = await userRef.get();
      if (userDoc.exists) {
        print("User already exists.");
        return false;
      }

      await userRef.set({
        "phone": phone,
        "password": hashedPassword,
        "userType": userType,
        "createdAt": FieldValue.serverTimestamp(),
      });

      print("$userType signed up successfully!");
      return true;
    } catch (e) {
      print("Signup error: $e");
      return false;
    }
  }

  // 🔹 Sign In (Check Phone & Password)
  Future<bool> signIn(String phone, String password, String userType) async {
    String hashedPassword = _hashPassword(password);

    try {
      DocumentSnapshot userDoc =
      await _firestore.collection(userType).doc(phone).get();

      if (userDoc.exists) {
        String storedPassword = userDoc["password"];
        if (hashedPassword == storedPassword) {
          print("$userType logged in successfully!");
          return true;
        } else {
          print("Incorrect password.");
          return false;
        }
      } else {
        print("User not found.");
        return false;
      }
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }
}
