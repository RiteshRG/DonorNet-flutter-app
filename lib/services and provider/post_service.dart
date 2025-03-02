

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:developer' as devtools show log;


// Future<String> getUserRating(String userId) async {
//   double totalRating = 0.0;
//   int ratingCount = 0;

//   try {
//     // Fetch all ratings where the user is the rated one
//     QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
//         .collection('ratings')
//         .where('rated_user_id', isEqualTo: userId)
//         .get();

//     if (ratingsSnapshot.docs.isEmpty) {
//       return "0.0"; // Return "0.0" if no ratings found
//     }

//     for (var doc in ratingsSnapshot.docs) {
//       totalRating += (doc['rating'] as num).toDouble();
//       ratingCount++;
//     }

//     // Calculate the average rating
//     double averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;

//     return averageRating.toString(); // Convert to string before returning
//   } catch (e) {
//     print('Error fetching user rating: $e');
//     return "0.0"; // Return "0.0" in case of an error
//   }
// }

// class PostService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   static const int pageSize = 6; // Number of posts per page
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

//       List<Map<String, dynamic>> posts = [];

//       for (var doc in querySnapshot.docs) {
//         var data = doc.data() as Map<String, dynamic>;
//         data['id'] = doc.id; // Include document ID if needed

//         // Fetch user details for each post
//         if (data.containsKey('user_id')) {
//           DocumentSnapshot userSnapshot =
//               await _firestore.collection('users').doc(data['user_id']).get();

//           if (userSnapshot.exists) {
//             data['user'] = userSnapshot.data(); // Store user data inside the post
//             // Fetch and store user rating
//             data['user_rating'] = await getUserRating(data['user_id']);
//           }
//         }

//         posts.add(data);
//       }

//       return posts;
//     } catch (e) {
//       devtools.log('Error fetching posts: $e');
//       return [];
//     }
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:developer' as devtools;

// class PostService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   static const int pageSize = 6; // Number of posts per page
//   DocumentSnapshot? _lastDocument;
//   final Map<String, Map<String, dynamic>> _userCache = {}; // ✅ Cache to avoid redundant queries

//   Future<String> getUserRating(String userId) async {
//     double totalRating = 0.0;
//     int ratingCount = 0;

//     try {
//       QuerySnapshot ratingsSnapshot = await _firestore
//           .collection('ratings')
//           .where('rated_user_id', isEqualTo: userId)
//           .get();

//       if (ratingsSnapshot.docs.isEmpty) {
//         return "0.0"; // Return default rating
//       }

//       for (var doc in ratingsSnapshot.docs) {
//         totalRating += (doc['rating'] as num).toDouble();
//         ratingCount++;
//       }

//       double averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;
//       return averageRating.toString();
//     } catch (e) {
//       devtools.log('Error fetching user rating: $e');
//       return "0.0"; // Return default rating in case of an error
//     }
//   }

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

//       List<Map<String, dynamic>> posts = [];

//       // ✅ Process each post efficiently
//       for (var doc in querySnapshot.docs) {
//         var data = doc.data() as Map<String, dynamic>;
//         data['id'] = doc.id;

//         if (data.containsKey('user_id')) {
//           String userId = data['user_id'];

//           // ✅ Check Cache before making a Firestore call
//           if (!_userCache.containsKey(userId)) {
//             var userFuture = _firestore.collection('users').doc(userId).get();
//             var ratingFuture = getUserRating(userId);

//             var results = await Future.wait([userFuture, ratingFuture]);

//             // ✅ Proper casting to avoid 'exists' error
//             DocumentSnapshot userSnapshot = results[0] as DocumentSnapshot;
//             if (userSnapshot.exists) {
//               _userCache[userId] = userSnapshot.data() as Map<String, dynamic>;
//             }
//             _userCache[userId]?['user_rating'] = results[1];
//           }

//           data['user'] = _userCache[userId] ?? {};
//           data['user_rating'] = _userCache[userId]?['user_rating'] ?? "0.0";
//         }

//         posts.add(data);
//       }

//       return posts;
//     } catch (e) {
//       devtools.log('Error fetching posts: $e');
//       return [];
//     }
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:developer' as devtools;

// class PostService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   static const int pageSize = 10; // Number of posts per page
//   DocumentSnapshot? _lastDocument;
//   final Map<String, Map<String, dynamic>> _userCache = {}; // ✅ Cache to avoid redundant queries

//   // ✅ Get user rating
//   Future<String> getUserRating(String userId) async {
//     double totalRating = 0.0;
//     int ratingCount = 0;

//     try {
//       QuerySnapshot ratingsSnapshot = await _firestore
//           .collection('ratings')
//           .where('rated_user_id', isEqualTo: userId)
//           .get();

//       if (ratingsSnapshot.docs.isEmpty) return "0.0"; // Default rating

//       for (var doc in ratingsSnapshot.docs) {
//         totalRating += (doc['rating'] as num).toDouble();
//         ratingCount++;
//       }

//       double averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;
//       return averageRating.toStringAsFixed(1); // ✅ Standardized format (e.g., "4.5")
//     } catch (e) {
//       devtools.log('Error fetching user rating: $e');
//       return "0.0"; // Default rating in case of an error
//     }
//   }

//   // ✅ Fetch posts with optional category filtering
//   Future<List<Map<String, dynamic>>> getAvailablePosts({
//     bool loadMore = false,
//     List<String>? selectedCategories,
//   }) async {
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
//       devtools.log('${selectedCategories}');
//       // ✅ Handle category filtering
//       if (selectedCategories != null && selectedCategories.isNotEmpty && !selectedCategories.contains("All")) {
//         QuerySnapshot categorySnapshot = await _firestore
//             .collection('category')
//             .where('category_name', whereIn: selectedCategories)
//             .get();
//             devtools.log("QuerySnapshot categorySnapshot: ${categorySnapshot}");

//         List<int> categoryIds = categorySnapshot.docs
//             .map((doc) => (doc['categoryId'] as num).toInt())
//             .toList();

//           devtools.log(" List<int> categoryIds ${categoryIds}");

//         if (categoryIds.isNotEmpty) {
//            devtools.log("in *****IF");
//           query = query.where('category_id', whereIn: categoryIds);
//           devtools.log("Done: ${query}");
//         }
//       }

//       QuerySnapshot querySnapshot = await query.get();
//        devtools.log("query.get();");

//       if (querySnapshot.docs.isNotEmpty) {
//         _lastDocument = querySnapshot.docs.last;
//       }
//       List<Map<String, dynamic>> posts = [];

//       // ✅ Process each post efficiently
//       for (var doc in querySnapshot.docs) {
//         var data = doc.data() as Map<String, dynamic>;
//         data['id'] = doc.id;

//         if (data.containsKey('user_id')) {
//           String userId = data['user_id'];

//           // ✅ Check Cache before making Firestore calls
//           if (!_userCache.containsKey(userId)) {
//             var userFuture = _firestore.collection('users').doc(userId).get();
//             var ratingFuture = getUserRating(userId);

//             var results = await Future.wait([userFuture, ratingFuture]);

//             // ✅ Proper casting to avoid 'exists' error
//             DocumentSnapshot userSnapshot = results[0] as DocumentSnapshot;
//             if (userSnapshot.exists) {
//               _userCache[userId] = userSnapshot.data() as Map<String, dynamic>;
//             }
//             _userCache[userId]?['user_rating'] = results[1];
//           }

//           data['user'] = _userCache[userId] ?? {};
//           data['user_rating'] = _userCache[userId]?['user_rating'] ?? "0.0";
//         }

//         posts.add(data);
//       }

//       return posts;
//     } catch (e) {
//       devtools.log('Error fetching posts: $e');
//       return [];
//     }
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as devtools;

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int pageSize = 10; // Number of posts per page
  DocumentSnapshot? _lastDocument;
  final Map<String, Map<String, dynamic>> _userCache = {}; // ✅ Cache to avoid redundant queries

  // ✅ Get user rating
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

  // ✅ Fetch posts with optional category filtering
  Future<List<Map<String, dynamic>>> getAvailablePosts({
    bool loadMore = false,
    List<String>? selectedCategories,
  }) async {
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
      devtools.log('Selected categories: $selectedCategories');

      // ✅ Handle category filtering
      if (selectedCategories != null && selectedCategories.isNotEmpty && !selectedCategories.contains("All")) {
        QuerySnapshot categorySnapshot = await _firestore
            .collection('category')
            .where('category_name', whereIn: selectedCategories)
            .get();

        devtools.log("Fetched categories: ${categorySnapshot.docs}");

        List<int> categoryIds = categorySnapshot.docs
            .map((doc) => (doc['categoryId'] as num).toInt())
            .toList();

        devtools.log("Category IDs for filtering: $categoryIds");

        if (categoryIds.isNotEmpty) {
          query = query.where('category_id', whereIn: categoryIds);
          devtools.log("Query after category filtering: $query");
        }
      }

      QuerySnapshot querySnapshot = await query.get();
      devtools.log("Query snapshot fetched");

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }

      List<Map<String, dynamic>> posts = [];

      // ✅ Process each post efficiently
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        if (data.containsKey('user_id')) {
          String userId = data['user_id'];

          // ✅ Check Cache before making Firestore calls
          if (!_userCache.containsKey(userId)) {
            var userFuture = _firestore.collection('users').doc(userId).get();
            var ratingFuture = getUserRating(userId);

            var results = await Future.wait([userFuture, ratingFuture]);

            // ✅ Proper casting to avoid 'exists' error
            DocumentSnapshot userSnapshot = results[0] as DocumentSnapshot;
            if (userSnapshot.exists) {
              _userCache[userId] = userSnapshot.data() as Map<String, dynamic>;
            }
            _userCache[userId]?['user_rating'] = results[1];
          }

          data['user'] = _userCache[userId] ?? {};
          data['user_rating'] = _userCache[userId]?['user_rating'] ?? "0.0";
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
