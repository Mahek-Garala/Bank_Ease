// Relationship Between the Code and Stages:
// Stage 1: Scanning the QR Code:

// The current code handles the process of scanning a QR code. It displays instructions and the camera feed, uses the MobileScanner to detect QR codes, and overlays the QRScannerOverlay to highlight the scan area. This is the input stage of the payment process, where the user is scanning a QR code.
// Stage 2: Processing the QR Code Data:

// Once the QR code is scanned, the app extracts the QR data and navigates to the payment processing stage (QRPayment screen). This second part is the payment handling after the QR code has been scanned. The scanned data (likely containing payment details) is passed to the next page, where the payment logic will be implemented.

// Scanqr Widget: Provides the interface for scanning QR codes and displays an overlay using the MobileScanner.
// QRScannerOverlay: Custom overlay used for enhancing user experience by guiding them to the correct scanning area.
// QR Code Detection: After detecting the QR code, the app navigates to the payment page (/qr_payment), passing the QR code data for further processing.

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'QRScannerOverlay.dart';

const bgColor = Color(0xfffafafa);

class Scanqr extends StatefulWidget {
  const Scanqr({super.key});

  @override
  State<Scanqr> createState() => _ScanqrState();
}

class _ScanqrState extends State<Scanqr> {

  bool isScanCompleted = false;

  void closeScreen()
  {
    isScanCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Scan Qr Code & Pay'),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Place the Qr code in the area.',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text('Scan will be start automaticatlly',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54
                      ),
                    ),
                  ],
                )),
            Expanded(
              flex: 4,

              child: Stack(
                  children: [
                    MobileScanner(
                      //allowDuplicates = true;
                      onDetect: (capture) {
                        if(!isScanCompleted) {
                          final List<Barcode> barcodes = capture.barcodes;
                          final Uint8List? image = capture.image;
                          for (final barcode in barcodes) {
                            debugPrint('Barcode found! ${barcode.rawValue}');
                          }
                          print("barcodes");
                          print(barcodes.toString());
                          print(image);
                          String? qrCodeData =" ";

                          if (barcodes.isNotEmpty) {
                            // Assuming you want to use the first detected barcode
                            qrCodeData = barcodes.first.rawValue;
                            print(qrCodeData);
                            // Navigate to the QRPayment page and pass the scanned QR code data

                            isScanCompleted = false;
                            Navigator.pushNamed(context, '/qr_payment',arguments: {
                              'qrCodeData' : qrCodeData
                            });
                            isScanCompleted = true;
                          }
                        }
                      },
                    ),
                    QRScannerOverlay(overlayColour : Colors.white),
                  ]
              ),
            ),
            Expanded(
                child: Container(
                  alignment: Alignment.center,

                )),
          ],
        ),
      ),
    );
  }
}


