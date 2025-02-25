// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// class ImageRecognitionPage extends StatefulWidget {
//   @override
//   _ImageRecognitionPageState createState() => _ImageRecognitionPageState();
// }

// class _ImageRecognitionPageState extends State<ImageRecognitionPage> {
//   File? _image;
//   String _result = "";
//   bool _isLoading = false; // Loading state
//   final ImagePicker _picker = ImagePicker();

//   final List<String> predefinedCategories = [
//     'Food', 'Toy', 'Pet Supplies', 'Clothing and Textiles',
//     'Footwear', 'Furniture', 'Sports Equipment', 'Stationary',
//   ];

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _result = ""; // Reset result
//       });
//     }
//   }

//   Future<void> _analyzeImage() async {
//     if (_image == null) return;

//     setState(() {
//       _isLoading = true;
//       _result = "Analyzing image...";
//     });

//     final apiKey = "AIzaSyCn9yW5clawe5BP5nwmyDPJdmGOp5a3jt4";
//     final url = "https://vision.googleapis.com/v1/images:annotate?key=$apiKey";

//     List<int> imageBytes = await _image!.readAsBytes();
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

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List labels = data["responses"][0]["labelAnnotations"] ?? [];

//         List<String> detectedCategories = [];
//         for (var label in labels) {
//           String labelText = label["description"].toString().toLowerCase(); // Convert to lowercase
//           for (var category in predefinedCategories) {
//             if (labelText.contains(category.toLowerCase())) {
//               detectedCategories.add(category);
//             }
//           }
//         }

//         setState(() {
//           _isLoading = false;
//           _result = detectedCategories.isNotEmpty
//               ? "Detected Category: ${detectedCategories.join(", ")}"
//               : "No matching category found";
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//           _result = "Error analyzing image";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _result = "An error occurred: $e";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Image Recognition")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _image != null
//                 ? Image.file(_image!, height: 200)
//                 : Text("No image selected"),
//             SizedBox(height: 20),
//             ElevatedButton(onPressed: _pickImage, child: Text("Pick Image")),
//             SizedBox(height: 10),
//             ElevatedButton(
//                 onPressed: _analyzeImage, child: Text("Analyze Image")),
//             SizedBox(height: 20),
//             _isLoading
//                 ? CircularProgressIndicator() // Show loading indicator
//                 : Text(_result, textAlign: TextAlign.center),
//           ],
//         ),
//       ),
//     );
//   }
// }
