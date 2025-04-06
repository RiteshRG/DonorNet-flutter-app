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
  

  Future<String?> getChatIdForPost(String postId) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('post_id', isEqualTo: postId)
        .where('participants', arrayContains: currentUserId)
        .limit(1) // Optimize query performance by limiting results
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // Return the existing chatId
    }
    return null; // No existing chat found
  } catch (e) {
    devtools.log("Error checking chat existence: $e");
    return null; // Handle errors gracefully
  }
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
      // ✅ Correct collection name ('rating' instead of 'ratings')
      QuerySnapshot ratingsSnapshot = await _firestore
          .collection('rating') 
          .where('rated_user_id', isEqualTo: userId)
          .get();

      if (ratingsSnapshot.docs.isEmpty) return "0.0"; // Default rating if no ratings exist

      for (var doc in ratingsSnapshot.docs) {
        totalRating += (doc['rating'] as num).toDouble();
        ratingCount++;
      }

      // ✅ Corrected calculation (no need for `ratingCount > 0` check)
      double averageRating = totalRating / ratingCount;

      return averageRating.toStringAsFixed(1); // ✅ Standardized format (e.g., "4.5")
    } catch (e) {
      devtools.log('Error fetching user rating: $e');
      return "N/A"; // ✅ Better than returning "0.0" on failure
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


// Future<void> deleteExpiredPostsForUser(BuildContext context) async {
//   final DateTime now = DateTime.now();
//   final User? user = FirebaseAuth.instance.currentUser;
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   if (user == null) {
//     devtools.log("No user logged in");
//     return;
//   }

//   try {
//     // Fetch all posts by the user (ignoring expiry_date_time condition to avoid Firestore index errors)
//     final QuerySnapshot snapshot = await firestore
//         .collection('posts')
//         .where('user_id', isEqualTo: user.uid)
//         .get();

//     // Filter expired posts locally
//     final expiredPosts = snapshot.docs.where((doc) {
//       final expiryDate = (doc['expiry_date_time'] as Timestamp).toDate();
//       return expiryDate.isBefore(now);
//     }).toList();

//     if (expiredPosts.isEmpty) {
//       devtools.log("No expired posts found.");
//       return;
//     }

//     bool anyDeleted = false; // Track if at least one post was deleted

//     for (var doc in expiredPosts) {
//       final String status = doc['status'];
//       if (status == "available") {
//         final String? imageUrl = doc['image_url'];
//         final String? qrCodeUrl = doc['qr_code_url'];
//         final String postId = doc.id;

//         // Delete images from Firebase Storage
//         if (imageUrl != null && imageUrl.isNotEmpty) {
//           await _deleteFileFromStorage(imageUrl);
//         }
//         if (qrCodeUrl != null && qrCodeUrl.isNotEmpty) {
//           await _deleteFileFromStorage(qrCodeUrl);
//         }

//         // Delete associated chats
//         QuerySnapshot chatSnapshot =
//             await firestore.collection('chats').where('post_id', isEqualTo: postId).get();

//         for (var chatDoc in chatSnapshot.docs) {
//           await firestore.collection('chats').doc(chatDoc.id).delete();
//         }

//         // Delete post from Firestore
//         await firestore.collection('posts').doc(postId).delete();
//         devtools.log("Deleted expired post and associated chats: $postId");
//         anyDeleted = true;
//       }
//     }

//     if (!anyDeleted) {
//       devtools.log("No 'available' expired posts to delete.");
//     }
//   } catch (error) {
//     devtools.log("Error deleting expired posts: $error");
//     showErrorDialog(context, "Failed to delete expired posts.");
//   }
// }

Future<void> deleteExpiredPostsForUser(BuildContext context) async {
  final DateTime now = DateTime.now();
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  if (user == null) {
    devtools.log("No user logged in");
    return;
  }

  try {
    // Fetch all posts by the user (ignoring expiry_date_time condition to avoid Firestore index errors)
    final QuerySnapshot snapshot = await firestore
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
    } else {
      bool anyDeleted = false; // Track if at least one post was deleted

      for (var doc in expiredPosts) {
        final String status = doc['status'];
        if (status == "available") {
          final String? imageUrl = doc['image_url'];
          final String? qrCodeUrl = doc['qr_code_url'];
          final String postId = doc.id;

          // Delete images from Firebase Storage
          if (imageUrl != null && imageUrl.isNotEmpty) {
            await _deleteFileFromStorage(imageUrl);
          }
          if (qrCodeUrl != null && qrCodeUrl.isNotEmpty) {
            await _deleteFileFromStorage(qrCodeUrl);
          }

          // Delete associated chats for this post
          QuerySnapshot chatSnapshot =
              await firestore.collection('chats').where('post_id', isEqualTo: postId).get();

          for (var chatDoc in chatSnapshot.docs) {
            await firestore.collection('chats').doc(chatDoc.id).delete();
          }

          // Delete the expired post
          await firestore.collection('posts').doc(postId).delete();
          devtools.log("Deleted expired post and associated chats: $postId");
          anyDeleted = true;
        }
      }

      if (!anyDeleted) {
        devtools.log("No 'available' expired posts to delete.");
      }
    }

    // // 🔥 Delete **all** chats where the user is a participant
    // QuerySnapshot userChatsSnapshot = await firestore
    //     .collection('chats')
    //     .where('participants', arrayContains: user.uid)
    //     .get();

    // for (var chatDoc in userChatsSnapshot.docs) {
    //   await firestore.collection('chats').doc(chatDoc.id).delete();
    // }

    // devtools.log("Deleted all chats for user: ${user.uid}");

  } catch (error) {
    devtools.log("Error deleting expired posts and chats: $error");
    showErrorDialog(context, "Failed to delete expired posts and chats.");
  }
}


Future<bool> deletePostById(BuildContext context, String postId) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch post document
    DocumentSnapshot doc = await firestore.collection('posts').doc(postId).get();

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

    // Delete associated chats and their messages
    QuerySnapshot chatSnapshot =
        await firestore.collection('chats').where('post_id', isEqualTo: postId).get();

    for (var chatDoc in chatSnapshot.docs) {
      String chatId = chatDoc.id;

      // Fetch and delete all messages inside the chat
      QuerySnapshot messageSnapshot = await firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      for (var messageDoc in messageSnapshot.docs) {
        await firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageDoc.id)
            .delete();
      }

      // Now delete the chat document
      await firestore.collection('chats').doc(chatId).delete();
    }

    // Delete post from Firestore
    await firestore.collection('posts').doc(postId).delete();

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


// Future<bool> deletePostById(BuildContext context, String postId) async {
//   try {
//     FirebaseFirestore firestore = FirebaseFirestore.instance;

//     // Fetch post document
//     DocumentSnapshot doc = await firestore.collection('posts').doc(postId).get();

//     if (!doc.exists) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Post not found."), backgroundColor: Colors.red),
//       );
//       return false;
//     }

//     // Fetch image URLs from the post
//     String? imageUrl = doc['image_url'];
//     String? qrCodeUrl = doc['qr_code_url'];

//     // Delete images from Firebase Storage
//     if (imageUrl != null && imageUrl.isNotEmpty) {
//       await _deleteFileFromStorage(imageUrl);
//     }
//     if (qrCodeUrl != null && qrCodeUrl.isNotEmpty) {
//       await _deleteFileFromStorage(qrCodeUrl);
//     }

//     // Delete associated chats
//     QuerySnapshot chatSnapshot =
//         await firestore.collection('chats').where('post_id', isEqualTo: postId).get();

//     for (var chatDoc in chatSnapshot.docs) {
//       await firestore.collection('chats').doc(chatDoc.id).delete();
//     }

//     // Delete post from Firestore
//     await firestore.collection('posts').doc(postId).delete();

//     // Show success snackbar
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Post and related chats deleted successfully!"), backgroundColor: Colors.green),
//     );

//     return true; // Successfully deleted
//   } catch (error) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Failed to delete post: $error"), backgroundColor: Colors.red),
//     );
//     debugPrint("Error deleting post: $error");
//     return false; // Deletion failed
//   }
// }


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


Future<Map<String, dynamic>?> checkAndClaimPost(String postId) async {
  try {
    // Fetch post details
    DocumentSnapshot postSnapshot = await _firestore.collection('posts').doc(postId).get();

    if (!postSnapshot.exists) {
      return {'error': 'Post not found.'};
    }

    Map<String, dynamic> postData = postSnapshot.data() as Map<String, dynamic>;

    // Check if the post belongs to the current user
    if (postData['user_id'] == currentUserId) {
      return {'error': 'You cannot claim your own donation post.'};
    }

    // Check if the post is expired
    Timestamp expiryTimestamp = postData['expiry_date_time'];
    DateTime expiryDate = expiryTimestamp.toDate();
    if (expiryDate.isBefore(DateTime.now())) {
      return {'error': 'This donation post has expired and cannot be claimed.'};
    }

    // Check if the post is available
    if (postData['status'] != 'available') {
      return {'error': 'This post is no longer available for claiming.'};
    }

    // Fetch user details (Donor's profile image)
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(postData['user_id']).get();

    if (!userSnapshot.exists) {
      return {'error': 'Donor details not found.'};
    }

    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    // Return post details with donor's profile image
    return {
      'postId': postData['postId'],
      'user_id': postData['user_id'],
      'image_url': postData['image_url'],
      'profile_image': userData['profile_image'], // Donor's profile image
    };
  } catch (e) {
    return {'error': 'An error occurred: $e'};
  }
}


  Future<bool> rateUser(String ratedUserId, int ratingValue) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final CollectionReference ratingsCollection = _firestore.collection('rating');

    try {
      // Check if the current user has already rated the post owner
      QuerySnapshot existingRatings = await ratingsCollection
          .where('rater_id', isEqualTo: currentUserId)
          .where('rated_user_id', isEqualTo: ratedUserId)
          .limit(1) // We need only one record if it exists
          .get();

      if (existingRatings.docs.isNotEmpty) {
        // Rating exists, update it
        String ratingId = existingRatings.docs.first.id; // Get the document ID
        await ratingsCollection.doc(ratingId).update({
          'rating': ratingValue.toDouble(), // Store rating as float
          'timestamp': FieldValue.serverTimestamp(), // Update timestamp
        });
        print("Rating updated successfully!");
      } else {
        // No rating exists, create a new one
        DocumentReference newRatingRef = ratingsCollection.doc(); // Auto-generate ID
        await newRatingRef.set({
          'ratingId': newRatingRef.id, // Store generated ID
          'rater_id': currentUserId,
          'rated_user_id': ratedUserId,
          'rating': ratingValue.toDouble(), // Convert int to float
          'timestamp': FieldValue.serverTimestamp(), // Store server timestamp
        });
        print("Rating added successfully!");
      }
      
      return true; 
    } catch (error) {
      print("Error adding/updating rating: $error");
      return false; 
    }
  }


Future<List<Map<String, dynamic>>> getUserChats() async {
  List<Map<String, dynamic>> chatList = [];

  try {
    DateTime now = DateTime.now();

    // Fetch chats where currentUserId is in participants
    QuerySnapshot chatSnapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('last_message_time', descending: true) // Sort by recent messages
        .get();

    for (var chatDoc in chatSnapshot.docs) {
      Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;

      // Fetch post details
      DocumentSnapshot postDoc =
          await _firestore.collection('posts').doc(chatData['post_id']).get();

      if (!postDoc.exists) continue;

      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;

      // Skip expired posts
      if ((postData['expiry_date_time'] as Timestamp).toDate().isBefore(now)) {
        continue;
      }

      // Find the other user (not the current user)
      List<dynamic> participants = chatData['participants'];
      String otherUserId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => "",
      );

      if (otherUserId.isEmpty) continue;

      // Fetch details of the other user
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(otherUserId).get();

      String firstName = "Unknown";
      String lastName = "";
      String profileImage = "";

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        firstName = userData['first_name'] ?? "Unknown";
        lastName = userData['last_name'] ?? "";
        profileImage = userData['profile_image'] ?? "";
      }

      // Construct result object
      chatList.add({
        'chatId': chatData['chatId'],
        'post_id': chatData['post_id'],
        'post_owner_id': chatData['post_owner_id'],
        'last_message': chatData['last_message'],
        'last_message_time': chatData['last_message_time'],
        'title': postData['title'],
        'status': postData['status'],
        'image_url': postData['image_url'],
        'profile_image': profileImage,
        'first_name': firstName,
        'last_name': lastName,
      });
    }
  } catch (e) {
    devtools.log("Error fetching chats: $e");
  }

  devtools.log("############### $chatList");
  return chatList;
}


}

