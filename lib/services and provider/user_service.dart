import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Logout User
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
