import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/map_service.dart';
import 'package:donornet/services%20and%20provider/post_service.dart';
import 'package:donornet/utilities/shimmer_loading.dart';
import 'package:donornet/views/home%20page/post.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as devtools;

class PostDetailsPage extends StatefulWidget {
  final String postId; // Store post as a property

  const PostDetailsPage(this.postId, {Key? key}) : super(key: key);

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  String title = "";
  String profile = "";
  String description = "";
  String imageUrl = "";
  String userName = "";
  String userRating = "0.0";
  double? distance;
  DateTime? createdAt;
  GeoPoint? postLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPostDetails();
  }

  Future<void> fetchPostDetails() async {
    try {
      List<Map<String, dynamic>> data = await PostService().getPostWithUserDetails(widget.postId);
      if (data.isNotEmpty) {
        var postData = data.first;

        setState(() {
          title = postData['post']['title'] ?? "No Title";
          description = postData['post']['description'] ?? "No Description";
          imageUrl = postData['post']['image_url'] ?? ""; // Ensure it doesn't break
          userName = "${postData['user']['first_name']} ${postData['user']['last_name']}";
          userRating = postData['rating'] ?? "0.0";
          distance = double.parse(postData['distance'].toStringAsFixed(1));
          createdAt = (postData['post']['created_at'] as Timestamp).toDate(); 
          profile = postData['user']['profile_image'];
          postLocation = postData['post']['location'];
          devtools.log("${postLocation!.latitude}");
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching post details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: isLoading ? BuildShimmerEffect() : _buildPostDetails(), 
    );
  }

  Widget _buildPostDetails(){
    return Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported, // Image error icon
                            size: 100,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.image, // Default image icon when no URL is available
                        size: 100,
                        color: Colors.grey,
                      ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: InkWell(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(118, 0, 0, 0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ),
                    // Positioned(
                    //   top: 40,
                    //   right: 16,
                    //   child: Container(
                    //     padding: const EdgeInsets.all(8),
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(20),
                    //     ),
                    //     child: const Icon(Icons.info_outline, color: Colors.black),
                    //   ),
                    // ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                       "${title}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${distance}km · ${createdAt != null ? DateFormat("d MMM").format(createdAt!) : 'Unknown'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${description}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pick up Date & Time',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${createdAt != null ? DateFormat("d - MMM - yyyy").format(createdAt!) : 'Unknown'}\n${createdAt != null ? DateFormat("h:mm a").format(createdAt!) : "Unknown"}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: (profile != null && profile!.isNotEmpty)
                                ? NetworkImage(profile!)
                                : null, // No image if profile is null or empty
                            child: (profile == null || profile!.isEmpty)
                                ? Icon(Icons.person, size: 20, color: Colors.white) // Default icon
                                : null,
                            backgroundColor: Colors.grey[400], // Optional background color
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                '${userName}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children:  [
                                  Icon(Icons.star, size: 16, color: Colors.amber),
                                  SizedBox(width: 4),
                                  Text('${userRating}'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: postLocation != null
                      ? MapBoxMapView(
                          latitude: postLocation!.latitude,
                          longitude: postLocation!.longitude,
                        )
                      : Center(child: Text("Location not available")),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80), // Space for bottom button
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(88, 255, 255, 255),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.tertiaryColor], // Customize your gradient colors
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Make button background transparent
                    shadowColor: Colors.transparent, // Remove shadow effect
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Send message via chat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            ),
          ),
        ],
      );
  }
}