// import 'package:cloud_firestore/cloud_firestore.dart';

// class PostService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   static const int pageSize = 10; // Number of posts per page
//   DocumentSnapshot? _lastDocument;

//   Future<List<Map<String, dynamic>>> getAvailablePosts({bool loadMore = false}) async {
//     try {
//       DateTime currentTime = DateTime.now();
//       Query query = _firestore
//           .collection('posts')
//           .where('status', isEqualTo: 'available')
//           .where('expiry_date_time', isGreaterThan: Timestamp.fromDate(currentTime))
//           .orderBy('expiry_date_time', descending: false)
//           .limit(pageSize);

//       if (loadMore && _lastDocument != null) {
//         query = query.startAfterDocument(_lastDocument!);
//       }

//       QuerySnapshot querySnapshot = await query.get();
//       if (querySnapshot.docs.isNotEmpty) {
//         _lastDocument = querySnapshot.docs.last;
//       }

//       List<Map<String, dynamic>> posts = querySnapshot.docs.map((doc) {
//         var data = doc.data() as Map<String, dynamic>;
//         data['id'] = doc.id; // Include document ID if needed
//         return data;
//       }).toList();

//       return posts;
//     } catch (e) {
//       print('Error fetching posts: $e');
//       return [];
//     }
//   }
// }


// 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as devtools show log;


Future<String> getUserRating(String userId) async {
  double totalRating = 0.0;
  int ratingCount = 0;

  try {
    // Fetch all ratings where the user is the rated one
    QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('rated_user_id', isEqualTo: userId)
        .get();

    if (ratingsSnapshot.docs.isEmpty) {
      return "0.0"; // Return "0.0" if no ratings found
    }

    for (var doc in ratingsSnapshot.docs) {
      totalRating += (doc['rating'] as num).toDouble();
      ratingCount++;
    }

    // Calculate the average rating
    double averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;

    return averageRating.toString(); // Convert to string before returning
  } catch (e) {
    print('Error fetching user rating: $e');
    return "0.0"; // Return "0.0" in case of an error
  }
}

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int pageSize = 10; // Number of posts per page
  DocumentSnapshot? _lastDocument;

  Future<List<Map<String, dynamic>>> getAvailablePosts({bool loadMore = false}) async {
    try {
      DateTime currentTime = DateTime.now();
      Query query = _firestore
          .collection('posts')
          .where('status', isEqualTo: 'available')
          .where('expiry_date_time', isGreaterThan: Timestamp.fromDate(currentTime))
          .orderBy('expiry_date_time', descending: false)
          .limit(pageSize);

      if (loadMore && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot querySnapshot = await query.get();
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }

      List<Map<String, dynamic>> posts = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include document ID if needed

        // Fetch user details for each post
        if (data.containsKey('user_id')) {
          DocumentSnapshot userSnapshot =
              await _firestore.collection('users').doc(data['user_id']).get();

          if (userSnapshot.exists) {
            data['user'] = userSnapshot.data(); // Store user data inside the post
            // Fetch and store user rating
            data['user_rating'] = await getUserRating(data['user_id']);
          }
        }

        posts.add(data);
      }

      return posts;
    } catch (e) {
      devtools.log('Error fetching posts: $e');
      return [];
    }
  }
}
