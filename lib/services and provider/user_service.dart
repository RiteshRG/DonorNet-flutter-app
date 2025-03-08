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
  
  bool isCurrentUser(String userIdToCheck) {
  return currentUserId == userIdToCheck;
  }

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



Future<Map<String, dynamic>?> fetchUserDetailsAndLevel(String userId) async {
  try {
    // Fetch user details
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userId).get();

    if (!userSnapshot.exists) {
      print("User not found");
      return null;
    }

    // Fetch user level
    DocumentSnapshot levelSnapshot = await _firestore.collection('levels').doc(userId).get();
    int userLevel = levelSnapshot.exists ? levelSnapshot["level"] ?? 0 : 0; // Default to 0

    // Fetch user rating separately
    String rating = await getUserRating(userId);

    return {
      "profile_image": userSnapshot["profile_image"] ?? "",
      "first_name": userSnapshot["first_name"] ?? "",
      "last_name": userSnapshot["last_name"] ?? "",
      "level": userLevel,
      "rating": rating, // Call getUserRating separately
    };
  } catch (e) {
    print("Error fetching user details and level: $e");
    return null;
  }
}



  Future<String> getUserRating(String userId) async {
    double totalRating = 0.0;
    int ratingCount = 0;

    try {
      QuerySnapshot ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('rated_user_id', isEqualTo: userId)
          .get();

      if (ratingsSnapshot.docs.isEmpty) return "0.0"; // Default rating

      for (var doc in ratingsSnapshot.docs) {
        totalRating += (doc['rating'] as num).toDouble();
        ratingCount++;
      }

      double averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;
      return averageRating.toStringAsFixed(1); // ✅ Standardized format (e.g., "4.5")
    } catch (e) {
      devtools.log('Error fetching user rating: $e');
      return "0.0"; // Default rating in case of an error
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
    String uniqueFileName = 'post_images/$postId-${DateTime.now().millisecondsSinceEpoch}.jpg';

    // ✅ Reference to Firebase Storage
    Reference storageRef = FirebaseStorage.instance.ref().child(uniqueFileName);

    // ✅ Upload file
    UploadTask uploadTask = storageRef.putFile(File(imageFile.path));

    // ✅ Wait for upload to complete
    TaskSnapshot snapshot = await uploadTask;

    // ✅ Get the download URL
    String downloadUrl = await snapshot.ref.getDownloadURL();
      devtools.log("✅ Image uploaded successfully: $downloadUrl");

    return downloadUrl;
  } catch (e) {
     devtools.log("Error uploading image: $e");
    throw e;
  }
}

// Future<bool> updatePost({
//   required String postId,
//   required String oldImageUrl, // ✅ Pass the old image URL from UI
//   required XFile? imageFile,   // ✅ New image (null means no change)
//   required String title,
//   required String description,
//   required String category,
//   required DateTime pickupDate,
//   required TimeOfDay pickupTime,
//   required DateTime expiryDate,
//   required TimeOfDay expiryTime,
//   required LatLng location,
//   required BuildContext context,
// }) async {
//   try {

//     final postRef = FirebaseFirestore.instance.collection("posts").doc(postId);

//     int? categoryId = await getCategoryId(category, context);
    
//     // ✅ Convert LatLng to GeoPoint
//     GeoPoint geoPoint = GeoPoint(location.latitude, location.longitude);

//     // ✅ Convert DateTime and TimeOfDay to Firestore Timestamp
//     DateTime pickupDateTime = DateTime(
//       pickupDate.year, pickupDate.month, pickupDate.day, pickupTime.hour, pickupTime.minute,
//     );
//     DateTime expiryDateTime = DateTime(
//       expiryDate.year, expiryDate.month, expiryDate.day, expiryTime.hour, expiryTime.minute,
//     );

//     Timestamp pickupTimestamp = Timestamp.fromDate(pickupDateTime);
//     Timestamp expiryTimestamp = Timestamp.fromDate(expiryDateTime);

//     // ✅ Step 1: Check if the user uploaded a new image
//     String updatedImageUrl = oldImageUrl; // Default: keep old image
//     // if (imageFile != null) {
//     //   // ✅ Upload new image
//     //   updatedImageUrl = await uploadImageToFirebase(imageFile, postId);

//     //   // ✅ Delete old image from Firebase Storage
//     //   await _deleteFileFromStorage(oldImageUrl);
//     // }

//     if (imageFile != null) {
//       devtools.log("🚀 Uploading new image: ${imageFile.path}");
//        updatedImageUrl = await uploadImageToFirebase(imageFile, postId);
//        await _deleteFileFromStorage(oldImageUrl);
     
//     } else {
//        devtools.log("⚠️ No new image uploaded, keeping old image: $oldImageUrl");
//        updatedImageUrl = oldImageUrl; 
//     }

//     // ✅ Step 2: Update Firestore document
//     await postRef.update({
//       "title": title,
//       "description": description,
//       "category_id": categoryId, // Fetch category ID
//       "pickup_date_time": pickupTimestamp,
//       "expiry_date_time": expiryTimestamp,
//       "image_url": updatedImageUrl, // ✅ Use updated image URL
//       "location": geoPoint,
//     });

//     return true;
//   } catch (e) {
//     print("Error updating post: $e");
//     return false;
//   }
// }

Future<bool> updatePost({
  required String postId,
  required String oldImageUrl, // ✅ Old image URL
  required XFile? imageFile,   // ✅ New image (null if unchanged)
  required String title,
  required String description,
  required String category,
  required DateTime pickupDate,
  required TimeOfDay pickupTime,
  required DateTime expiryDate,
  required TimeOfDay expiryTime,
  required LatLng location,
  required BuildContext context,
}) async {
  try {
    devtools.log("🔄 Updating post: $postId");

    final postRef = FirebaseFirestore.instance.collection("posts").doc(postId);

    // ✅ Fetch Category ID
    int? categoryId = await getCategoryId(category, context);
    if (categoryId == null) return false;

    // ✅ Convert LatLng to GeoPoint
    GeoPoint geoPoint = GeoPoint(location.latitude, location.longitude);

    // ✅ Convert DateTime and TimeOfDay to Firestore Timestamp
    DateTime pickupDateTime = DateTime(
      pickupDate.year, pickupDate.month, pickupDate.day, pickupTime.hour, pickupTime.minute,
    );
    DateTime expiryDateTime = DateTime(
      expiryDate.year, expiryDate.month, expiryDate.day, expiryTime.hour, expiryTime.minute,
    );

    Timestamp pickupTimestamp = Timestamp.fromDate(pickupDateTime);
    Timestamp expiryTimestamp = Timestamp.fromDate(expiryDateTime);

    // ✅ Step 1: Check if the user uploaded a new image
    String updatedImageUrl = oldImageUrl; // Default: keep old image

    if (imageFile != null) {
      devtools.log("🚀 Uploading new image: ${imageFile.path}");

      // ✅ Upload new image
      updatedImageUrl = await uploadImageToFirebase(imageFile, postId);
      devtools.log("✅ New image uploaded successfully: $updatedImageUrl");

      // ✅ Step 2: Delete old image from Firebase Storage
      devtools.log("🗑️ Deleting old image: $oldImageUrl");
      await _deleteFileFromStorage(oldImageUrl);
      devtools.log("✅ Old image deleted successfully.");
    } else {
      devtools.log("⚠️ No new image uploaded, keeping old image: $oldImageUrl");
    }

    // ✅ Step 3: Update Firestore document
    devtools.log("📢 Updating Firestore with new image URL: $updatedImageUrl");
    await postRef.update({
      "title": title,
      "description": description,
      "category_id": categoryId,
      "pickup_date_time": pickupTimestamp,
      "expiry_date_time": expiryTimestamp,
      "image_url": updatedImageUrl, // ✅ Use updated image URL
      "location": geoPoint,
    });

    devtools.log("✅ Post updated successfully.");
    return true;
  } catch (e) {
    devtools.log("❌ Error updating post: $e");
    return false;
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

Future<bool> deletePostById(BuildContext context, String postId) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();

    if (!doc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post not found."), backgroundColor: Colors.red),
      );
      return false;
    }

    // Fetch image URLs from the post
    String? imageUrl = doc['image_url'];
    String? qrCodeUrl = doc['qr_code_url'];

    // Delete images from Firebase Storage
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _deleteFileFromStorage(imageUrl);
    }
    if (qrCodeUrl != null && qrCodeUrl.isNotEmpty) {
      await _deleteFileFromStorage(qrCodeUrl);
    }

    // Delete post from Firestore
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Post deleted successfully!"), backgroundColor: Colors.green),
    );

    return true; // Successfully deleted
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to delete post: $error"), backgroundColor: Colors.red),
    );
    debugPrint("Error deleting post: $error");
    return false; // Deletion failed
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
