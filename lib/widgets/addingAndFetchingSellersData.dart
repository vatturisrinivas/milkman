import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddingAndFetchingSellersData {
  static final AddingAndFetchingSellersData _instance =
  AddingAndFetchingSellersData._internal();
  factory AddingAndFetchingSellersData() {
    return _instance;
  }


  AddingAndFetchingSellersData._internal();

  // Private variables
  double _morningRatePerLitre = 0;
  double _eveningRatePerLitre = 0;
  double _morningMilkAmount = 0;
  double _eveningMilkAmount = 0;
  double _totalMorningAmount = 0;
  double _totalEveningAmount = 0;
  double _grandTotal = 0;

  // Getters to access values
  double get morningRatePerLitre => _morningRatePerLitre;
  double get eveningRatePerLitre => _eveningRatePerLitre;
  double get morningMilkAmount => _morningMilkAmount;
  double get eveningMilkAmount => _eveningMilkAmount;
  double get totalMorningAmount => _totalMorningAmount;
  double get totalEveningAmount => _totalEveningAmount;
  double get grandTotal => _grandTotal;

  Future<void> fetch(DateTime currentDate, String? sellerPhone) async {
    String monthId = DateFormat('yyyy-MM').format(currentDate);

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerPhone)
          .collection('monthlySummary')
          .doc(monthId)
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;

        // Assign values correctly
        _morningRatePerLitre = (data['morningRate'] ?? 0).toDouble();
        _eveningRatePerLitre = (data['eveningRate'] ?? 0).toDouble();
        _morningMilkAmount = (data['totalMorningMilk'] ?? 0).toDouble();
        _eveningMilkAmount = (data['totalEveningMilk'] ?? 0).toDouble();
        _totalMorningAmount = (data['totalMorningCost'] ?? 0).toDouble();
        _totalEveningAmount = (data['totalEveningCost'] ?? 0).toDouble();
        _grandTotal = (data['grandTotal'] ?? 0).toDouble();
      } else {
        // 👇 RESET all values to zero if data doesn't exist
        _morningRatePerLitre = 0;
        _eveningRatePerLitre = 0;
        _morningMilkAmount = 0;
        _eveningMilkAmount = 0;
        _totalMorningAmount = 0;
        _totalEveningAmount = 0;
        _grandTotal = 0;
      }
    } catch (e) {
        print("Error fetching seller data: $e");
    }
  }
}
