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

Future<bool> markPostAsClaimed(String postId, String postOwnerId) async {
  try {
    WriteBatch batch = _firestore.batch(); // Firestore batch for atomic operations

    // Reference to the post document
    DocumentReference postRef = _firestore.collection('posts').doc(postId);

    // Update post status to "claimed"
    batch.update(postRef, {'status': 'claimed'});

    // Fetch the points document where user_id == postOwnerId
    QuerySnapshot pointsQuery = await _firestore
        .collection('points')
        .where('user_id', isEqualTo: postOwnerId)
        .limit(1)
        .get();

    int updatedPoints = 10; // Default points to be added

    if (pointsQuery.docs.isNotEmpty) {
      // If document exists, increment points
      DocumentReference pointsRef = pointsQuery.docs.first.reference;
      int currentPoints = (pointsQuery.docs.first['points_earned'] as num).toInt();
      updatedPoints = currentPoints + 10; // Add 10 points

      batch.update(pointsRef, {
        'points_earned': FieldValue.increment(10),
      });
    } else {
      // If no document exists, create a new one
      DocumentReference newPointsRef = _firestore.collection('points').doc();
      batch.set(newPointsRef, {
        'user_id': postOwnerId,
        'points_earned': 10, // Start with 10 points
      });
    }

    // Commit the batch operation
    await batch.commit();

    // After updating points, update the level
    await updateUserLevel(postOwnerId, updatedPoints);

    devtools.log("✅ Post marked as claimed, points updated, and level updated successfully!");
    return true;
  } catch (e) {
    devtools.log("❌ Error updating post status, points, or level: $e");
    return false;
  }
}

Future<void> updateUserLevel(String userId, int currentPoints) async {
  try {
    // Define level thresholds
    List<Map<String, int>> levelThresholds = [
      {'level': 1, 'points': 10},
      {'level': 2, 'points': 40},
      {'level': 3, 'points': 90},
      {'level': 4, 'points': 150},
      {'level': 5, 'points': 225},
      {'level': 6, 'points': 300},
      {'level': 7, 'points': 500},
      {'level': 8, 'points': 800},
      {'level': 9, 'points': 1000},
      {'level': 10, 'points': 1500},
    ];

    int newLevel = 0;
    for (var level in levelThresholds) {
      if (currentPoints >= level['points']!) {
        newLevel = level['level']!;
      } else {
        break; // Stop checking if the next level is not reached
      }
    }

    CollectionReference levelsCollection = _firestore.collection('levels');

    // Fetch user's level document
    QuerySnapshot levelSnapshot =
        await levelsCollection.where('user_id', isEqualTo: userId).limit(1).get();

    if (levelSnapshot.docs.isNotEmpty) {
      // Update existing level document
      DocumentReference userLevelDoc = levelSnapshot.docs.first.reference;
      await userLevelDoc.update({'level': newLevel});
    } else {
      // Create a new level document if not exists
      DocumentReference newLevelDoc = levelsCollection.doc();
      await newLevelDoc.set({
        'user_id': userId,
        'level': newLevel,
        'points_required': levelThresholds[newLevel - 1]['points'],
      });
    }

    devtools.log("✅ User level updated to $newLevel successfully!");
  } catch (e) {
    devtools.log("❌ Error updating user level: $e");
  }
}



}


