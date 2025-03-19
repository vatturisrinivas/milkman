import 'package:shared_preferences/shared_preferences.dart';

class userManager {
  static final userManager _instance = userManager._internal();

  factory userManager() => _instance;

  userManager._internal();

  static const String _userPhoneKey = "userPhone";
  static const String _userNameKey = "userName";
  static const String _userRole = "userRole";
  //static const String _ownerIdKey = "ownerId";

  /// Save Owner Data Locally
  Future<void> saveUserData({
    required String phone,
    required String role,
    String? name,
  //required String ownerId
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPhoneKey, phone);
    await prefs.setString(_userRole, role);
    //await prefs.setString(_ownerNameKey, name!);
    if (name != null && name.isNotEmpty) {
      await prefs.setString(_userNameKey, name);
    }
    //await prefs.setString(_ownerIdKey, ownerId);
    return;
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userPhoneKey); // Check if user data exists
  }


  /// Fetch User Role
  Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRole);
  }

  /// Fetch User Phone
  Future<String?> getUserPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoneKey);
  }

  /// Fetch User Name
  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Fetch User ID
  // Future<String?> getOwnerId() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_ownerIdKey);
  // }

  /// Clear User Data (Logout)
  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userRole);
    //await prefs.remove(_ownerIdKey);
  }
}
