import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScannerPage extends StatefulWidget {
  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  String scannedValue = "";
  MobileScannerController scannerController = MobileScannerController();

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkCameraPermission(); // Request camera permission
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:  AppBar(
        title: Text(
          'Scan QR Code',
          style: TextStyle(
            shadows: [
              Shadow(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        elevation: 8.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.tertiaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            controller: scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  scannerController.stop(); // Stop scanning after detection
                  setState(() {
                    scannedValue = code;
                  });

                  // Return the scanned value and close the scanner page
                  Navigator.pop(context, scannedValue);
                }
              }
            },
          ),

          // Dark Overlay (Darker Outside the Scanning Box)
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            painter: ScannerOverlayPainter(),
          ),

          // Instruction Text
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Align the QR Code within the box",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color.fromARGB(80, 7, 58, 60);
    final cutoutSize = 250.0;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final borderRadius = 25.0; // Adjust this for roundness

    // Full-screen dark overlay
    final fullScreenRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create a transparent cutout with rounded corners
    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: cutoutSize,
        height: cutoutSize,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRect(fullScreenRect);
    path.addRRect(cutoutRect);
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Scanner Border Design with rounded corners
    final borderPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(cutoutRect, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}