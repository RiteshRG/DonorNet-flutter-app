import 'dart:convert';
import 'dart:math';
import 'package:donornet/api.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as devtools show log;

class OTPService {
  static final OTPService _instance = OTPService._internal();
  factory OTPService() => _instance;
  OTPService._internal();

  String? _currentOtp; // Stores the current OTP
  DateTime? _otpGeneratedTime; // Stores the OTP generation time
  static const int otpExpiryMinutes = 5; // OTP expiry time in minutes
  int _attemptCount = 0;  // Track the number of attempts to prevent brute force

  // Brevo API Configuration
  final String brevoApiKey = APIKey.brevo; // Replace with your Brevo API Key
  final String senderEmail = "donornet5@gmail.com"; // Replace with your Brevo verified sender email
  final String senderName = "DonorNet"; // Replace with the name you want to display

   String _generateOtp() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString(); // Generates a random 6-digit number
  }
  bool _isOtpExpired() {
    if (_otpGeneratedTime == null) return true;
    final expiryDuration = Duration(minutes: otpExpiryMinutes);
    return DateTime.now().isAfter(_otpGeneratedTime!.add(expiryDuration));
  }

  // Method to send OTP using EmailJS
  Future<bool> sendOtp(String email) async {
    try {
      _currentOtp = _generateOtp();
      _otpGeneratedTime = DateTime.now();
      _attemptCount = 0; // Reset attempt count
      devtools.log("Generated OTP: $_currentOtp ********");

      // Brevo API URL
      final url = Uri.parse('https://api.brevo.com/v3/smtp/email');

      // Prepare email data
       final data = {
        "sender": {
          "email": senderEmail,
          "name": senderName,
        },
        "to": [
          {
            "email": email,
            "name": email // Optional, can be left out
          }
        ],
        "subject": "Your OTP Code",
        "htmlContent": """
          <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DonorNet - Password Reset OTP</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            color: #333;
        }
        .email-container {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }
        .email-header {
            background-color: #008CBA;
            padding: 20px;
            color: white;
            text-align: center;
        }
        .email-body {
            padding: 20px;
        }
        .otp-code {
            font-size: 24px;
            font-weight: bold;
            color: #008CBA;
            text-align: center;
            margin-top: 20px;
        }
        .email-footer {
            background-color: #f4f4f4;
            padding: 20px;
            text-align: center;
            font-size: 12px;
            color: #888;
        }
        .email-footer a {
            color: #008CBA;
            text-decoration: none;
        }
        @media only screen and (max-width: 600px) {
            .email-container {
                width: 100% !important;
                padding: 10px;
            }
            .email-header {
                padding: 15px;
            }
            .email-body {
                padding: 15px;
            }
        }
    </style>
</head>
<body>

    <div class="email-container">
        <div class="email-header">
            <h1>DonorNet</h1>
        </div>
        <div class="email-body">
            <h2>Password Reset Request</h2>
            <p>Hello,</p>
            <p>You have requested to reset your password for your DonorNet account. Please use the following One-Time Password (OTP) to proceed with resetting your password:</p>
            <div class="otp-code">
                <strong>$_currentOtp</strong> <!-- This will be replaced with the OTP code -->
            </div>
            <p>This OTP is valid for the next $otpExpiryMinutes minutes. <!-- This will be replaced with OTP expiry time --></p>
            <p>If you didn't request a password reset, you can ignore this email.</p>
        </div>
        <div class="email-footer">
            <p>&copy; 2025 DonorNet. All Rights Reserved.</p>
        </div>
    </div>
</body>
</html>

        """,
      };

      // Send HTTP POST request to Brevo API
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'api-key': brevoApiKey,
        },
        body: json.encode(data),
      );

      // Check if email was sent successfully
      if (response.statusCode == 201) {
        devtools.log('OTP sent successfully to $email');
        return true;
      } else {
        devtools.log('Failed to send OTP. Status code: ${response.statusCode}');
        devtools.log('Response body: ${response.body}');
        return false;
      }

    } catch (e) {
      devtools.log('Error while sending OTP: ${e.toString()}');
      return false;
    }
  }


 Future<bool> verifyOtp(String otp) async {
  devtools.log("Generated OTP: $_currentOtp ********");
    if (_isOtpExpired()) {
      devtools.log('OTP has expired.');
      return false;
    }

    if (_currentOtp == otp) {
      devtools.log('OTP verified successfully.');
      _currentOtp = null; // Invalidate the OTP after successful verification
      _otpGeneratedTime = null;
      _attemptCount = 0;
      return true;
    } else {
      _attemptCount++;
      devtools.log('Invalid OTP. Attempt $_attemptCount ');
      devtools.log("${_currentOtp}");

      // if (_attemptCount >= maxAttempts) {
      //   devtools.log('Maximum attempts reached. OTP is now invalid.');
      //   _currentOtp = null;
      //   _otpGeneratedTime = null;
      // }
      return false;
    }
  }
  // Method to reset OTP (optional, in case you want a reset mechanism)
    Future<bool> resendOtp(String email) async {
    _currentOtp = null; // Invalidate the previous OTP
    _otpGeneratedTime = null;
    _attemptCount = 0; // Reset attempts
    devtools.log('Previous OTP invalidated. Sending a new OTP.');
    return await sendOtp(email);
  }

  void resetOtp() {
    _currentOtp = null;
    _otpGeneratedTime = null;
    _attemptCount = 0;
     devtools.log('reset completed');
  }
}



// import 'dart:async';
// import 'dart:math';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';
// import 'dart:developer' as devtools show log;

// //import 'package:cloud_functions/cloud_functions.dart';

// class OTPService {
//   String? _generatedOtp;
//   DateTime? _otpSentTime;

//   // Method to generate OTP
//   String _generateOtp() {
//     final random = Random();
//     return (random.nextInt(900000) + 100000).toString(); // Generates a 6-digit OTP
//   }

//   Future<bool> sendOtp(String email) async {
//     try {
//       // Generate OTP
//       _generatedOtp = _generateOtp();
//       devtools.log("${_generatedOtp}");
//        devtools.log("${email}");


//       // Set OTP sent time
//       _otpSentTime = DateTime.now();

//       // Prepare and send the email with the OTP
//       final Email emailToSend = Email(
//         body: 'Your OTP is $_generatedOtp. It is valid for 5 minutes.',
//         subject: 'Your OTP Code',
//         recipients: [email],
//         isHTML: false,
//       );

//       await FlutterEmailSender.send(emailToSend);
//       devtools.log('OTP sent successfully to $email');
//       return true;
//     } catch (e) {
//       devtools.log('Error while sending OTP: $e');
//       return false;
//     }
//   }

//   Method to check if OTP is expired
//   bool _isOtpExpired() {
//     if (_otpSentTime == null) return true;

//     final expiryDuration = Duration(minutes: 5);
//     final currentTime = DateTime.now();

//     return currentTime.isAfter(_otpSentTime!.add(expiryDuration));
//   }

//   // Method to verify OTP
//   Future<bool> verifyOtp(String otp) async {
//     if (_isOtpExpired()) {
//       print('OTP has expired');
//       return false;
//     }

//     if (_generatedOtp == otp) {
//       print('OTP verified successfully');
//       return true;
//     } else {
//       print('Invalid OTP');
//       return false;
//     }
//   }
// }





// import 'package:email_otp/email_otp.dart';
// import 'dart:developer' as devtools show log;

// class OTPService  {
//   // Method to send OTP
//   Future<bool> sendOtp(String email) async {
//      try {
//       // Configure email OTP settings
//       EmailOTP.config(
//         appName: 'YourAppName',
//         otpType: OTPType.numeric, // Numeric OTP
//         emailTheme: EmailTheme.v1, // Default theme
//       );

//       bool isSent = await EmailOTP.sendOTP(email: email);

//       if (isSent) {
//         devtools.log('OTP sent successfully to $email');
//       } else {
//         devtools.log('Failed to send OTP');
//       }

//       return isSent;
//     } catch (e) {
//       devtools.log('Error while sending OTP: $e');
//       return false;
//     }
//   }

//   // Method to verify OTP
//    Future<bool> verifyOtp(String otp) async{
//     bool isVerified = await EmailOTP.verifyOTP(otp: otp);
//     return isVerified;
//   }
// }

