import 'package:flutter/material.dart';
import 'package:milkman/widgets/sellerLoginWidget.dart';

class sellerLoginScreen extends StatefulWidget {
  @override
  _sellerLoginScreenState createState() => _sellerLoginScreenState();
}

class _sellerLoginScreenState extends State<sellerLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  void _sellerloginmethod() async {
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    bool isLoggedIn = await sellerLoginWidget(context, phoneController.text, passwordController.text);

    if (isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login successful!")),
      );

      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ownerLoginWidget(phoneController.text, passwordController.text)),);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Don't have an account Signup!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seller Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone Number")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _sellerloginmethod, child: Text("login")),
            TextButton(
              onPressed: () {
                //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => sellerSignUpScreen()),);
              },
              child: Text("Don't have an account? SignUp"),
            ),
          ],
        ),
      ),
    );
  }
}
