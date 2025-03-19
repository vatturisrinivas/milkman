import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:milkman/firebase_options.dart';
import 'package:milkman/screens/dashboardScreens/ownerHomeScreen.dart';
import 'package:milkman/screens/dashboardScreens/sellerHomeScreen.dart';
import 'package:milkman/screens/signUpAndLoginScreens/ownerandsellerloginpage.dart';
import 'package:milkman/widgets/userManager.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Ensure this is correct
  );

  bool loggedIn = await userManager().isLoggedIn();
  String? role = await userManager().getUserRole();

  runApp(
      MyApp(loggedIn: loggedIn, role: role)
  );
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  final String? role;
  const MyApp({required this.loggedIn, required this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins'
      ),
      home: loggedIn
          ? (role == 'owner' ? ownerHomeScreen() : sellerHomeScreen())
          : ownerandsellerloginpage(),
    );
  }
}
