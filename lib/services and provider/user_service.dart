import 'dart:io';

import 'package:donornet/services%20and%20provider/generate_qr_code.dart';
import 'package:donornet/utilities/show_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as devtools show log;

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

  // Logout User
  Future<void> signOut() async {
    await _auth.signOut();
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
      devtools.log("IN createPost()");
     // ✅ Fetch category ID
    int? categoryId = await getCategoryId(category!, context);
    
    if (categoryId == null) return false;

    String? userId = currentUserId;
    if (userId == null) {
    devtools.log("No user logged in");
    return false;
    }
    devtools.log("userId: ${userId}, categoryId: ${categoryId}");


    // ✅ Generate Unique Post ID
    String postId = Uuid().v4();
    devtools.log("postId: ${postId},");

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
      devtools.log("control: uploadQRCodeToFirebase()");
      // ✅ Firebase Storage reference
      Reference storageRef = FirebaseStorage.instance.ref().child("post_qr_codes/$postId.png");

      devtools.log("Firebase Storage reference  **Succes**");

      // ✅ Upload QR file
      UploadTask uploadTask = storageRef.putFile(qrFile);
      devtools.log("uploadTask  **Succes**");

      TaskSnapshot snapshot = await uploadTask;

      devtools.log("Upload QR file  **Succes**");

      // ✅ Get Download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
      devtools.log("Get Download URL  **Succes**");
    } catch (e) {
      print("Error uploading QR Code: $e");
      return "";
    }
  }

  // Future<void> updatePostWithQRCode(String postId, String qrImageUrl) async {
  //   try {
  //     await FirebaseFirestore.instance.collection("posts").doc(postId).update({
  //       "qr_code_url": qrImageUrl, // ✅ Save QR Code URL
  //     });

  //     print("QR Code URL saved successfully!");
  //   } catch (e) {
  //     print("Error updating post with QR Code: $e");
  //   }
  // }


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


Future<void> deleteExpiredPostsForUser(BuildContext context) async {
  final DateTime now = DateTime.now();
  final User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    devtools.log("No user logged in");
    return;
  }

  try {
    // Fetch all posts by the user (without an expiry_date_time condition to avoid index errors)
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('user_id', isEqualTo: user.uid)
        .get();

    // Filter expired posts locally
    final expiredPosts = snapshot.docs.where((doc) {
      final expiryDate = (doc['expiry_date_time'] as Timestamp).toDate();
      return expiryDate.isBefore(now);
    }).toList();

    if (expiredPosts.isEmpty) {
      devtools.log("No expired posts found.");
      return;
    }

    bool anyDeleted = false; // Track if at least one post was deleted

    for (var doc in expiredPosts) {
      final String status = doc['status'];
      if (status == "available") {
        final String? imageUrl = doc['image_url'];
        final String? qrCodeUrl = doc['qr_code_url'];

        // Delete the image from Firebase Storage
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await _deleteFileFromStorage(imageUrl);
        }

        // Delete the QR code from Firebase Storage
        if (qrCodeUrl != null && qrCodeUrl.isNotEmpty) {
          await _deleteFileFromStorage(qrCodeUrl);
        }

        // Delete the Firestore document
        await FirebaseFirestore.instance.collection('posts').doc(doc.id).delete();
        devtools.log("Deleted expired post: ${doc.id}");
        anyDeleted = true;
      }
    }

    if (!anyDeleted) {
      devtools.log("No 'available' expired posts to delete.");
    }
  } catch (error) {
    devtools.log("Error deleting expired posts: $error");
    showErrorDialog(context, "Failed to delete expired posts.");
  }
}

// Helper function to delete a file from Firebase Storage
Future<void> _deleteFileFromStorage(String fileUrl) async {
  try {
    final Reference storageRef = FirebaseStorage.instance.refFromURL(fileUrl);
    await storageRef.delete();
    devtools.log("Deleted file: $fileUrl");
  } catch (error) {
    devtools.log("Error deleting file: $error");
  }
}


}
