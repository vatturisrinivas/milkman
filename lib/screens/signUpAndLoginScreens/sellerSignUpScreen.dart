import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:milkman/widgets/sellerSignUpWidget.dart';
import 'package:milkman/widgets/userManager.dart';

class createSellerDialog extends StatefulWidget {
  @override
  _createSellerDialogState createState() => _createSellerDialogState();
}

class _createSellerDialogState extends State<createSellerDialog> {
  final TextEditingController _sellerPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  TextEditingController _ownerPhone = TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchOwnerPhone();
  }

  // Fetch the current logged-in owner's phone number
  // Future<void> _fetchOwnerPhone() async {
  //   String? _ownerPhone = await userManager().getOwnerPhone() ?? "Unknown";
  //   print(_ownerPhone);
  //
  //   if (ownerPhone != "Unknown") {
  //     setState(() {
  //       ownerPhone = _ownerPhone;
  //     });
  //     return;
  //   }
  //   else{
  //     setState(() {
  //       ownerPhone = "Phone number not found";
  //     });
  //     return;
  //   }
  // }

  Future<void> _fetchOwnerPhone() async {
    String? _ownerPhoneValue = await userManager().getUserPhone();

    setState(() {
      _ownerPhone.text = _ownerPhoneValue ?? "Phone number not found";
      print(_ownerPhone.text);
    });
  }




  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: const Text("Add New Seller")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Seller Name",labelStyle: TextStyle(color: Colors.black), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: "Password",labelStyle: TextStyle(color: Colors.black), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _sellerPhoneController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Seller PhoneNo.",labelStyle: TextStyle(color: Colors.black), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _ownerPhone,
            decoration: InputDecoration(labelText: "Milkman Phone No.",labelStyle: TextStyle(color: Colors.black), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
            readOnly: true, // Read-only field
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white
              ),
              onPressed: () async{
                bool success= await createSeller(
                  _ownerPhone.text,
                  _sellerPhoneController.text,
                  _passwordController.text,
                  _nameController.text
                );
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Seller added successfully!")),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to add seller. Phone number may exist.")),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ],
    );
  }
}
