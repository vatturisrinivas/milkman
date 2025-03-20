import 'package:flutter/material.dart';
import 'package:milkman/screens/signUpAndLoginScreens/ownerSignUpScreen.dart';
import 'package:milkman/widgets/ownerLoginWidget.dart';
import 'package:milkman/widgets/ownerSignUpWidget.dart';

double screenheight=0;
double screenwidth=0;
class ownerLoginScreen extends StatefulWidget {
  @override
  _ownerLoginScreenState createState() => _ownerLoginScreenState();
}

class _ownerLoginScreenState extends State<ownerLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  void login() async {
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    bool isLoggedIn = await ownerLoginWidget(context, phoneController.text, passwordController.text);

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
    screenheight=MediaQuery.of(context).size.height;
    screenwidth=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      //appBar: AppBar(title: Center(child: Text("Milkman Login",style: TextStyle(color: Colors.white),)),backgroundColor: Colors.black,),
      body: Column(
        children: [
          Container(height: 200,width: double.infinity,color: Colors.black,child: Center(child: Text("Milkman Login",style: TextStyle(color: Colors.white,fontSize: 35),),),),
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
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white
                        ),
                        child: Text("login")
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ownerSignUpScreen()),);
                      },
                      child: Text("Don't have an account? Signup",style: TextStyle(color: Colors.black),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // body: Padding(
      //   padding: EdgeInsets.all(16.0),
      //   child: Column(
      //     children: [
      //       TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone Number")),
      //       TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
      //       SizedBox(height: 20),
      //       ElevatedButton(onPressed: login, child: Text("login")),
      //       TextButton(
      //         onPressed: () {
      //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ownerSignUpScreen()),);
      //         },
      //         child: Text("Don't have an account? SignUp"),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
