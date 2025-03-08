import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as devtools;

import 'package:donornet/services%20and%20provider/map_service.dart';
import 'package:donornet/services%20and%20provider/user_service.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int pageSize = 10; // Number of posts per page
  DocumentSnapshot? _lastDocument;
  final Map<String, Map<String, dynamic>> _userCache = {}; // ✅ Cache to avoid redundant queries



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
            var ratingFuture = UserService().getUserRating(userId);

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



  Future<List<Map<String, dynamic>>> getPostWithUserDetails(String postId) async {
  List<Map<String, dynamic>> postDetailsList = [];

  try {
    // Fetch post details
    DocumentSnapshot postSnapshot =
        await _firestore.collection('posts').doc(postId).get();

    if (!postSnapshot.exists) {
      print("Post not found");
      return [];
    }

    Map<String, dynamic> postData = postSnapshot.data() as Map<String, dynamic>;

    // Fetch user details
    String userId = postData['user_id'];
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(userId).get();

    if (!userSnapshot.exists) {
      print("User not found");
      return [];
    }

    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    // Fetch user rating
    String userRating = await UserService().getUserRating(userId);

    // Calculate distance (only if 'location' exists and is a GeoPoint)
    double? distance;
    if (postData['location'] != null && postData['location'] is GeoPoint) {
      GeoPoint postLocation = postData['location'];
      MapService mapService = MapService();
      distance = await mapService.calculateDistance(postLocation);
    } else {
      print("Invalid location data for post: $postId");
      distance = null; // Default to null if location is missing or invalid
    }

    // Merge post, user details, rating, and distance
    postDetailsList.add({
      "post": postData,
      "user": userData,
      "rating": userRating, // ✅ Store user rating
      "distance": distance, // ✅ Store distance in km (null if invalid)
    });

  } catch (e) {
    print("Error fetching post and user details: $e");
  }

  return postDetailsList;
}


Future<List<Map<String, dynamic>>> getAvailablePostsLocation() async {
  List<Map<String, dynamic>> availablePosts = [];
  DateTime now = DateTime.now();

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('expiry_date_time', isGreaterThan: Timestamp.fromDate(now))
        .where('status', isEqualTo: 'available')
        .get();

    for (var doc in querySnapshot.docs) {
      availablePosts.add({
        'postId': doc['postId'],
        'user_id': doc['user_id'],
        'location': doc['location'],
      });
    }
  } catch (e) {
    print('Error fetching posts: $e');
  }

  return availablePosts;
}


Future<Map<String, dynamic>?> getPostDetailsForMapPopUp(String postId) async {
  try {
    DocumentSnapshot postSnapshot = 
        await FirebaseFirestore.instance.collection('posts').doc(postId).get();

    if (postSnapshot.exists) {
      Map<String, dynamic> postData = postSnapshot.data() as Map<String, dynamic>;

      return {
        "expiry_date_time": postData["expiry_date_time"], // Timestamp
        "image_url": postData["image_url"], // String
        "title": postData["title"], // String
      };
    } else {
      print("Post not found!");
      return null;
    }
  } catch (e) {
    print("Error fetching post details: $e");
    return null;
  }
}

Future<List<Map<String, dynamic>>> fetchAvailablePosts(String userId) async {
  try {
    
    QuerySnapshot querySnapshot = await _firestore
        .collection('posts')
        .where('status', isEqualTo: 'available')
        .where('expiry_date_time', isGreaterThan: Timestamp.now())
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true) // Sort by most recent
        .get(const GetOptions(source: Source.serverAndCache)); // Use cache first, then update

    List<Map<String, dynamic>> posts = querySnapshot.docs.map((doc) {
      return {
        'image_url': doc['image_url'] ?? '',
        'postId': doc['postId'] ?? '',
      };
    }).toList();
    return posts;
  } catch (e) {
    devtools.log('Error fetching available posts: $e');
    return [];
  }
}

Future<List<String>> getClaimedPostImages(String userId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('user_id', isEqualTo: userId) // Filter by userId
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



}
