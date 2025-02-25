import 'dart:io';

import 'package:donornet/services%20and%20provider/generate_qr_code.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Fetch user details from Firestore
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      String? userId = currentUserId;
      if (userId == null) return null;

      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("🔥 Error fetching user data: $e");
    }
    return null;
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    try {
      String? userId = currentUserId;
      if (userId == null) return;

      await _firestore.collection("users").doc(userId).update(updatedData);
    } catch (e) {
      print("🔥 Error updating user profile: $e");
    }
  }


Future<bool> createPost({
  required XFile? imageFile, // ✅ Image file to upload
  required String? title,
  required String? description,
  required String? category,
  required DateTime? pickupDate,
  required TimeOfDay? pickupTime,
  required DateTime? expiryDate,
  required TimeOfDay? expiryTime,
  required LatLng? location,
  required BuildContext context,
}) async {
  try {

     // ✅ Fetch category ID
    int? categoryId = await getCategoryId(category!, context);
    
    if (categoryId == null) return false;

    String? userId = currentUserId;

    // ✅ Generate Unique Post ID
    String postId = Uuid().v4();

    // ✅ Generate qr code
    String? qrCodeUrl = await generateAndUploadQRCode(postId);
    if(qrCodeUrl == ""){
      return false;
    }


    // ✅ Convert LatLng to GeoPoint
    GeoPoint geoPoint = GeoPoint(location!.latitude, location.longitude);

    // ✅ Create DateTime objects separately
    DateTime pickupDateTime = DateTime(
      pickupDate!.year, pickupDate!.month, pickupDate!.day, pickupTime!.hour, pickupTime.minute,
    );

    DateTime expiryDateTime = DateTime(
      expiryDate!.year, expiryDate!.month, expiryDate!.day, expiryTime!.hour, expiryTime!.minute,
    );

    // ✅ Convert to Timestamp
    Timestamp pickupTimestamp = Timestamp.fromDate(pickupDateTime);
    Timestamp expiryTimestamp = Timestamp.fromDate(expiryDateTime);

    // ✅ Upload Image to Firebase Storage
    String imageUrl = await uploadImageToFirebase(imageFile!, postId);

    // ✅ Insert into Firestore
    await FirebaseFirestore.instance.collection("posts").doc(postId).set({
      "postId": postId,
      "user_id": userId,
      "title": title,
      "description": description,
      "category_id": categoryId,
      "pickup_date_time": pickupTimestamp,
      "expiry_date_time": expiryTimestamp,
      "image_url": imageUrl, // ✅ Store uploaded image URL
      "qr_code_url": qrCodeUrl,
      "location": geoPoint,
      "status": "available",
      "claimed_by": null,
      "created_at": Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Post submitted successfully!"), backgroundColor: Colors.green),
    );
    return true;
  } catch (e) {
    print("Error creating post: $e");
    return false;
  }
}

// ✅ Function to Upload Image to Firebase Storage
Future<String> uploadImageToFirebase(XFile imageFile, String postId) async {
  try {
    // ✅ Reference to Firebase Storage
    Reference storageRef = FirebaseStorage.instance.ref().child('post_images/$postId.jpg');

    // ✅ Upload file
    UploadTask uploadTask = storageRef.putFile(File(imageFile.path));

    // ✅ Wait for upload to complete
    TaskSnapshot snapshot = await uploadTask;

    // ✅ Get the download URL
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  } catch (e) {
    print("Error uploading image: $e");
    throw e;
  }
}

Future<String> uploadQRCodeToFirebase(File qrFile, String postId) async {
  try {
    // ✅ Firebase Storage reference
    Reference storageRef = FirebaseStorage.instance.ref().child("post_qr_codes/$postId.png");

    // ✅ Upload QR file
    UploadTask uploadTask = storageRef.putFile(qrFile);
    TaskSnapshot snapshot = await uploadTask;

    // ✅ Get Download URL
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print("Error uploading QR Code: $e");
    return "";
  }
}

Future<void> updatePostWithQRCode(String postId, String qrImageUrl) async {
  try {
    await FirebaseFirestore.instance.collection("posts").doc(postId).update({
      "qr_code_url": qrImageUrl, // ✅ Save QR Code URL
    });

    print("QR Code URL saved successfully!");
  } catch (e) {
    print("Error updating post with QR Code: $e");
  }
}


Future<int?> getCategoryId(String categoryName, BuildContext context) async {
  try {
    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
        .collection("category")
        .where("category_name", isEqualTo: categoryName)
        .limit(1)
        .get();

    if (categorySnapshot.docs.isNotEmpty) {
      return categorySnapshot.docs.first["categoryId"];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Category not found!"), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    print("Error fetching categoryId: $e");
  }
  return null; // Return null if category not found
}





  // Logout User
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
