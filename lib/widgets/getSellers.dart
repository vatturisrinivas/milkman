import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milkman/widgets/userManager.dart';

Future<List<Map<String, dynamic>>> getSellers() async {
  try {
    String? ownerPhone = await userManager().getUserPhone();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("sellers")
        .where("ownerUID", isEqualTo: ownerPhone)
        .get();

    List<Map<String, dynamic>> sellers = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    return sellers;
  } catch (e) {
    print("Error fetching sellers: $e");
    return [];
  }
}
