import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/utilities/show_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:donornet/api.dart';
import 'dart:developer' as devtools show log;

// Function to analyze the image and return detected labels
Future<List<String>> detectImageLabels(BuildContext context, File imageFile) async {
  try {
    final apiKey = APIKey.googleVision;
    final url = "https://vision.googleapis.com/v1/images:annotate?key=$apiKey";

    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    final requestBody = {
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {"type": "LABEL_DETECTION", "maxResults": 10}
          ]
        }
      ]
    };

    print("🔍 Sending image to Google Vision API for analysis...");
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List labels = data["responses"][0]["labelAnnotations"] ?? [];

      List<String> detectedLabels = labels
          .map<String>((label) => label["description"].toString().toLowerCase().trim())
          .toList();
      
      devtools.log("Detected labels: $detectedLabels");
      return detectedLabels;
    } else {
      print("Error: Failed to analyze the image. Status Code: ${response.statusCode}");
      showErrorDialog(context, "Failed to analyze the image.");
      return [];
    }
  } catch (e) {
    print("Unexpected error: $e");
    showErrorDialog(context, "Please check your internet connection or try again later.");
    return [];
  }
}


Future<List<String>> detectImageUrlLabels(BuildContext context, String imageUrl) async {
  try {
    final apiKey = APIKey.googleVision;
    final url = "https://vision.googleapis.com/v1/images:annotate?key=$apiKey";

    if (imageUrl.trim().isEmpty) {
      devtools.log("❌ Error: Image URL is empty.");
      showErrorDialog(context, "Invalid image URL.");
      return [];
    }

    // Prepare the API request body using the image URL
    final requestBody = {
      "requests": [
        {
          "image": {
            "source": {"imageUri": imageUrl}
          },
          "features": [
            {"type": "LABEL_DETECTION", "maxResults": 10}
          ]
        }
      ]
    };

    print("🔍 Sending image URL to Google Vision API for analysis...");
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List labels = data["responses"][0]["labelAnnotations"] ?? [];

      List<String> detectedLabels = labels
          .map<String>((label) => label["description"].toString().toLowerCase().trim())
          .toList();

      devtools.log("✅ Detected labels: $detectedLabels");
      return detectedLabels;
    } else {
      print("❌ Error: Failed to analyze the image. Status Code: ${response.statusCode}");
      showErrorDialog(context, "Failed to analyze the image.");
      return [];
    }
  } catch (e) {
     devtools.log("❌ Unexpected error: $e");
    showErrorDialog(context, "Please check your internet connection or try again later.");
    return [];
  }
}



// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:donornet/utilities/show_error_dialog.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:donornet/api.dart';

// // Function to analyze the image and check if it matches the category
// Future<bool> detectImageMatchesCategory(
//     BuildContext context, File imageFile, String categoryName) async {
//   try {
//     final apiKey = APIKey.googleVision;
//     final url = "https://vision.googleapis.com/v1/images:annotate?key=$apiKey";

//     List<int> imageBytes = await imageFile.readAsBytes();
//     String base64Image = base64Encode(imageBytes);

//     final requestBody = {
//       "requests": [
//         {
//           "image": {"content": base64Image},
//           "features": [
//             {"type": "LABEL_DETECTION", "maxResults": 10}
//           ]
//         }
//       ]
//     };

//     print("🔍 Sending image to Google Vision API for analysis...");
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(requestBody),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       List labels = data["responses"][0]["labelAnnotations"] ?? [];

//       List<String> detectedLabels = labels
//           .map<String>((label) => label["description"].toString().toLowerCase().trim())
//           .toList();
      
//       print("✅ Detected labels: $detectedLabels");

//       return await isCategoryMatch(context, detectedLabels, categoryName);
//     } else {
//       print("❌ Error: Failed to analyze the image. Status Code: ${response.statusCode}");
//       showErrorDialog(context, "Failed to analyze the image.");
//       return false;
//     }
//   } catch (e) {
//     print("⚠️ Unexpected error: $e");
//     showErrorDialog(context, "An unexpected error occurred: $e");
//     return false;
//   }
// }

// // Function to check if detected labels match the category's keywords
// Future<bool> isCategoryMatch(
//     BuildContext context, List<String> detectedLabels, String categoryName) async {
//   final firestore = FirebaseFirestore.instance;

//   try {
//     print("📌 Fetching category ID for: $categoryName");

//     QuerySnapshot categorySnapshot = await firestore
//         .collection('category')
//         .where('category_name', isEqualTo: categoryName)
//         .get();

//     if (categorySnapshot.docs.isEmpty) {
//       print("❌ Error: Category not found in database.");
//       showErrorDialog(context, "Category not found in database.");
//       return false;
//     }

//     // Extract category_id as an integer
//     int categoryId = categorySnapshot.docs.first['categoryId'];  
//     print("✅ Category ID: $categoryId");

//     print("📌 Fetching keywords for category ID: $categoryId");
//     QuerySnapshot keywordSnapshot = await firestore
//         .collection('category_keywords')
//         .where('category_id', isEqualTo: categoryId)
//         .get();

//     if (keywordSnapshot.docs.isEmpty) {
//       print("⚠️ No keywords found for category: $categoryName");
//       showErrorDialog(context, "No keywords found for category: $categoryName");
//       return false;
//     }

//     List<String> categoryKeywords = [];
//     for (var doc in keywordSnapshot.docs) {
//       categoryKeywords.addAll(
//         List<String>.from(doc['keywords'])
//             .map((e) => e.toLowerCase().trim()) // Ensure lowercase & trim spaces
//       );
//     }

//     print("✅ Category Keywords: $categoryKeywords");

//     // Check if any detected label matches the category's keywords (allows partial matching)
//     for (String detectedLabel in detectedLabels) {
//       if (categoryKeywords.any((keyword) => detectedLabel.contains(keyword))) {
//         print("🎯 Match found! Image belongs to category: $categoryName");
//         return true;
//       } else {
//         print("❌ No match for: $detectedLabel");
//       }
//     }

//     print("⚠️ No match found. Image does not belong to category: $categoryName");
//     return false;
//   } catch (e) {
//     print("❌ Error while fetching category data: $e");
//     showErrorDialog(context, "Error while fetching category data: $e");
//     return false;
//   }
// }

