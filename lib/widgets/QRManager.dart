import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:milkman/screens/eachSellerDetails/eachSellerDetails.dart';

class QrManager {
  /// Returns a QR widget for seller's data (like phone or UID)
  static Widget generateQr(String sellerPhone) {
    return QrImageView(
      data: sellerPhone,
      version: QrVersions.auto,
      size: 200.0,
      backgroundColor: Colors.white,
    );
  }

  /// Returns a screen with QR scanner and navigation logic
  static Widget getQrScannerScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Scan Seller QR",
          ),
      ),
      body: QrViewWidget(),
    );
  }
}

/// A separate widget to handle the QR scanning process
class QrViewWidget extends StatefulWidget {
  const QrViewWidget({Key? key}) : super(key: key);

  @override
  State<QrViewWidget> createState() => _QrViewWidgetState();
}

class _QrViewWidgetState extends State<QrViewWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 250,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      if (!scanned) {
        scanned = true;
        final sellerPhone = scanData.code;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => eachSellerDetailsScreen(
              sellerPhone: sellerPhone!,
              sellerName: "Seller", // Optional: fetch actual name using phone
            ),
          ),
        );
      }
    });
  }
}
