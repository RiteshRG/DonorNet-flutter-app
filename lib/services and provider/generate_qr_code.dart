import 'package:donornet/services%20and%20provider/user_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> generateAndUploadQRCode(String postId) async {
  try {
    // ✅ Generate QR Code
    final qrValidationResult = QrValidator.validate(
      data: postId, // ✅ Store only postId
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );

    if (qrValidationResult.status != QrValidationStatus.valid) {
      throw Exception("QR Code generation failed!");
    }

    final qrCode = qrValidationResult.qrCode!;
    final painter = QrPainter.withQr(
      qr: qrCode,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
      gapless: true,
    );

    final ByteData byteData = await painter.toImageData(300) as ByteData;
    final Uint8List uint8List = byteData.buffer.asUint8List();

    // ✅ Save QR Code to Temporary Directory
    final tempDir = await getTemporaryDirectory();
    final qrFile = File("${tempDir.path}/$postId-qr.png");
    await qrFile.writeAsBytes(uint8List);

    // ✅ Upload QR Code to Firebase Storage
    UserService userService = UserService();
    String qrImageUrl = await userService.uploadQRCodeToFirebase(qrFile, postId);

    return qrImageUrl; // Return the URL
  } catch (e) {
    print("Error generating QR Code: $e");
    return "";
  }
}
