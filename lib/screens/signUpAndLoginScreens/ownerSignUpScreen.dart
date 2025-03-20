import 'package:flutter/material.dart';
import 'package:milkman/screens/signUpAndLoginScreens/ownerLoginScreen.dart';
import 'package:milkman/widgets/ownerLoginWidget.dart';
import 'package:milkman/widgets/ownerSignUpWidget.dart';

class ownerSignUpScreen extends StatefulWidget {
  @override
  _ownerSignUpScreenState createState() => _ownerSignUpScreenState();
}

class _ownerSignUpScreenState extends State<ownerSignUpScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();


  void signUp() async {
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String name = nameController.text.trim();

    if (phone.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    bool isSignedUp = await ownerSignUpWidget(context, phoneController.text, passwordController.text, nameController.text);

    if (isSignedUp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-up successful! Please log in.")),
      );

      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ownerLoginWidget(phoneController.text, passwordController.text)),);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Phone number already registered")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      //appBar: AppBar(title: Text("Milkman Signup",style: TextStyle(color: Colors.white),),backgroundColor: Colors.black,),
      body: Column(
        children: [
          Container(height: 200,width: double.infinity,color: Colors.black,child: Center(child: Text("Milkman Signup",style: TextStyle(color: Colors.white,fontSize: 35),),),),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(60),topRight: Radius.circular(60)),
                  color: Colors.white
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                        controller: nameController,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                            hintText: "Full Name",
                            hintStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.black,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            )
                        )
                    ),
                    SizedBox(height: 30,),
                    TextField(
                        controller: phoneController,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                            hintText: "Phone Number",
                            hintStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.black,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            )
                        )
                    ),
                    SizedBox(height: 30,),
                    TextField(
                        controller: passwordController,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.black,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            )
                        ),
                        obscureText: true
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: signUp,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white
                        ),
                        child: Text("signup")
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ownerLoginScreen()),);
                      },
                      child: Text("Already have an account? SignIn",style: TextStyle(color: Colors.black),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // appBar: AppBar(title: Text("Owner Sign Up")),
      // body: Padding(
      //   padding: EdgeInsets.all(16.0),
      //   child: Column(
      //     children: [
      //       TextField(controller: nameController, decoration: InputDecoration(labelText: "Full Name")),
      //       TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone Number")),
      //       TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
      //       SizedBox(height: 20),
      //       ElevatedButton(onPressed: signUp, child: Text("Sign Up")),
      //       TextButton(
      //         onPressed: () {
      //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ownerLoginScreen()),);
      //         },
      //         child: Text("Already have an account? Login"),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
