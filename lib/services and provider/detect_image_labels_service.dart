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



