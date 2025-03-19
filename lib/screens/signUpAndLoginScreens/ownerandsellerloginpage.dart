import 'package:flutter/material.dart';
import 'package:milkman/screens/signUpAndLoginScreens/ownerLoginScreen.dart';
import 'package:milkman/screens/signUpAndLoginScreens/ownerSignUpScreen.dart';
import 'package:milkman/screens/signUpAndLoginScreens/sellerloginpage.dart';

double screenheight=0;
double screenwidth=0;

class ownerandsellerloginpage extends StatelessWidget {
  const ownerandsellerloginpage({super.key});

  @override
  Widget build(BuildContext context) {

    screenheight=MediaQuery.of(context).size.height;
    screenwidth=MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Container(
                color: Colors.white,
                child: Align(
                  alignment: Alignment(0.0,0.5),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ownerLoginScreen()));
                    },
                    child: Container(
                      height: screenheight*0.15,
                      width: screenwidth*0.6,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Center(child: Text("Be A Milkman",style: TextStyle(color: Colors.white,fontSize: 30),)),
                    ),
                  ),
                ),
              )
          ),
          Expanded(
              child: Container(
                color: Colors.black,
                child: Align(
                  alignment: Alignment(0.0,-0.5),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>sellerLoginScreen()));
                    },
                    child: Container(
                      height: screenheight*0.15,
                      width: screenwidth*0.6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Center(child: Text("Be A Seller",style: TextStyle(fontSize: 30,color: Colors.black),)),
                    ),
                  ),
                ),
              )
          )
         ],
      ),
    );
  }
}
