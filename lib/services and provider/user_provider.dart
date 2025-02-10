import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/utilities/show_error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch User Data
  Future<void> fetchUserDetails() async {
    _isLoading = true;
    notifyListeners();

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _errorMessage = "No authenticated user found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        _userData = userDoc.data() as Map<String, dynamic>?;
      } else {
        _errorMessage = "User data not found.";
      }
    } catch (e) {
      _errorMessage = "Error fetching user data: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Upload Profile Picture and Update Firestore (You Provide the Updated Data)
  Future<void> updateProfilePicture(File imageFile, Map<String, dynamic> updatedData) async {
    _isLoading = true;
    notifyListeners();

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _errorMessage = "No authenticated user found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      String filePath = 'profile_pictures/${user.uid}.jpg';

      // Upload to Firebase Storage
      TaskSnapshot snapshot = await _storage.ref(filePath).putFile(imageFile);
      String downloadURL = await snapshot.ref.getDownloadURL();

      // Merge provided updated data with the new profile picture URL
      updatedData['profile_image'] = downloadURL;

      // Update Firestore with new data
      await _firestore.collection('users').doc(user.uid).update(updatedData);

      // Update local user data
      _userData = {...?_userData, ...updatedData};
    } catch (e) {
      _errorMessage = "Error updating profile: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }

  void logoutUser(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        'welcomePageRoute', 
        (route) => false,
      );
      print("User successfully logged out");
    } catch (e) {
      showerrorDialog(context, "Error logging out: $e");
    }
  }
}
