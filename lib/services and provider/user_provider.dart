import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/utilities/show_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

   FirebaseAuth get auth => _auth;

  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;
  int _userLevel = 0;
  int _pointsRequired = 0;
  String? _levelDocId;
  double _userRating = 0.0; 
  int _userPoints = 0;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get userLevel => _userLevel;
  int get pointsRequired => _pointsRequired;
  String? get levelDocId => _levelDocId;
  double get userRating => _userRating; 
  int get userPoints => _userPoints;


  // Fetch User Data
  Future<void> fetchUserDetails() async {
    _isLoading = true;
    notifyListeners();

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _errorMessage = "No authenticated user found.";
      } else {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          _userData = userDoc.data() as Map<String, dynamic>?;
        } else {
          _errorMessage = "User data not found.";
        }
      }
    } catch (e) {
      _errorMessage = "Error fetching user data: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }

Future<List<Map<String, dynamic>>> fetchAvailablePosts() async {
  try {
    User? user = _auth.currentUser;
    
    QuerySnapshot querySnapshot = await _firestore
        .collection('posts')
        .where('status', isEqualTo: 'available')
        .where('expiry_date_time', isGreaterThan: Timestamp.now())
        .where('user_id', isEqualTo: user?.uid)
        .orderBy('created_at', descending: true) // Sort by most recent
        .get(const GetOptions(source: Source.serverAndCache)); // Use cache first, then update

    List<Map<String, dynamic>> posts = querySnapshot.docs.map((doc) {
      return {
        'image_url': doc['image_url'] ?? '',
        'postId': doc['postId'] ?? '',
      };
    }).toList();
    _isLoading = false;
    return posts;
  } catch (e) {
    debugPrint('Error fetching available posts: $e');
    return [];
  }
}

Future<List<String>> getClaimedPostImages() async {
  try {
    User? user = _auth.currentUser;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('user_id', isEqualTo: user?.uid) // Filter by userId
        .where('status', isEqualTo: "claimed") // Only claimed posts
        .orderBy('created_at', descending: true) // Order by newest first
        .get();

    // Extract only image_url from each document
    List<String> imageUrls = querySnapshot.docs
        .map((doc) => doc['image_url'] as String)
        .where((url) => url.isNotEmpty) // Ensure URLs are valid
        .toList();

    return imageUrls;
  } catch (e) {
    print("Error fetching images: $e");
    return [];
  }
}



  // Upload Profile Picture and Update Firestore
  // Future<void> updateProfilePicture(File imageFile, Map<String, dynamic> updatedData) async {
  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     User? user = _auth.currentUser;
  //     if (user == null) {
  //       _errorMessage = "No authenticated user found.";
  //     } else {
  //       String filePath = 'profile_pictures/${user.uid}.jpg';
  //       TaskSnapshot snapshot = await _storage.ref(filePath).putFile(imageFile);
  //       String downloadURL = await snapshot.ref.getDownloadURL();
  //       updatedData['profile_image'] = downloadURL;
  //       await _firestore.collection('users').doc(user.uid).update(updatedData);
  //       _userData = {...?_userData, ...updatedData};
  //     }
  //   } catch (e) {
  //     _errorMessage = "Error updating profile: ${e.toString()}";
  //   }

  //   _isLoading = false;
  //   notifyListeners();
  // }

  // Fetch User Levels
  Future<void> fetchUserLevels(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _errorMessage = "No authenticated user found.";
        showErrorDialog(context, _errorMessage!);
      } else {
        QuerySnapshot levelsSnapshot = await _firestore
        .collection('levels') // Querying the "levels" collection
        .where('user_id', isEqualTo: user.uid) // Filtering by user_id
        .limit(1)
        .get();


        if (levelsSnapshot.docs.isNotEmpty) {
          Map<String, dynamic> levelData = levelsSnapshot.docs.first.data() as Map<String, dynamic>;
          _userLevel = levelData['level'] ?? 0;
          _pointsRequired = levelData['points_required'] ?? 0;
          _levelDocId = levelsSnapshot.docs.first.id;
        } else {
          _userLevel = 0;
          _pointsRequired = 10;
          _levelDocId = null;
        }
      }
    } catch (e) {
      _errorMessage = "Error fetching user levels: ${e.toString()}";
      showErrorDialog(context, _errorMessage!);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update User Level
  Future<void> updateUserLevel(BuildContext context, int newLevel) async {
    User? user = _auth.currentUser;
    if (user == null || _levelDocId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('levels')
          .doc(_levelDocId)
          .update({'level': newLevel});

      _userLevel = newLevel;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Error updating user level: ${e.toString()}";
      showErrorDialog(context, _errorMessage!);
    }
  }

   /// ****Rating****
    Future<void> fetchUserRating(String userId) async {
    try {
      QuerySnapshot ratingSnapshot = await _firestore
          .collection('ratings')
          .where('rated_user_id', isEqualTo: userId)
          .get();

      if (ratingSnapshot.docs.isEmpty) {
        _userRating = 0.0; // No ratings found, set to 0
      } else {
        double totalRating = 0;
        int ratingCount = ratingSnapshot.docs.length;

        for (var doc in ratingSnapshot.docs) {
          totalRating += (doc['rating'] as num).toDouble();
        }

        _userRating = totalRating / ratingCount; // Calculate average rating
      }

      notifyListeners(); // Notify UI to update
    } catch (e) {
      debugPrint("Error fetching ratings: $e");
      _userRating = 0.0; // Default to 0 on error
      notifyListeners();
    }
  }


  /// **Update a Rating**
  Future<void> updateUserRating(String raterId, String ratedUserId, double rating) async {
    try {
      // Check if rater has already rated this user
      QuerySnapshot existingRating = await _firestore
          .collection('ratings')
          .where('rater_id', isEqualTo: raterId)
          .where('rated_user_id', isEqualTo: ratedUserId)
          .get();

      if (existingRating.docs.isNotEmpty) {
        // Update existing rating
        String ratingId = existingRating.docs.first.id;
        await _firestore.collection('ratings').doc(ratingId).update({
          'rating': rating,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new rating
        await _firestore.collection('ratings').add({
          'rater_id': raterId,
          'rated_user_id': ratedUserId,
          'rating': rating,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Refresh rating after update
      await fetchUserRating(ratedUserId);
    } catch (e) {
      print("Error updating rating: $e");
    }
  }


  // Logout User
  void logoutUser(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        'welcomePageRoute', 
        (route) => false,
      );
    } catch (e) {
      showErrorDialog(context, "Error logging out: $e");
    }
  }
}
