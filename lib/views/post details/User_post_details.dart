import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/map_service.dart';
import 'package:donornet/services%20and%20provider/post_service.dart';
import 'package:donornet/services%20and%20provider/user_provider.dart';
import 'package:donornet/services%20and%20provider/user_service.dart';
import 'package:donornet/utilities/shimmer_loading.dart';
import 'package:donornet/views/home%20page/home.dart';
import 'package:donornet/views/qr_code_page.dart';
import 'package:donornet/views/update_post_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools;

class UserPostDetailPage extends StatefulWidget {
  final String postId;
  const UserPostDetailPage(this.postId, {Key? key}) : super(key: key);

  @override
  State<UserPostDetailPage> createState() => _UserPostDetailPageState();
}

class _UserPostDetailPageState extends State<UserPostDetailPage> {
  bool _isDeleting = false;
  String title = "";
  String profile = "";
  String description = "";
  String imageUrl = "";
  String userName = "";
  String postId = "";
  String userRating = "0.0";
  double? distance;
  DateTime? createdAt;
  GeoPoint? postLocation;
  bool isLoading = true;
  String qrCode = "";

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
          postId = postData['post']['postId'];
          title = postData['post']['title'] ?? "No Title";
          description = postData['post']['description'] ?? "No Description";
          imageUrl = postData['post']['image_url'] ?? ""; // Ensure it doesn't break
          userName = "${postData['user']['first_name']} ${postData['user']['last_name']}";
          userRating = postData['rating'] ?? "0.0";
          distance = double.parse(postData['distance'].toStringAsFixed(1));
          createdAt = (postData['post']['created_at'] as Timestamp).toDate(); 
          profile = postData['user']['profile_image'];
          postLocation = postData['post']['location'];
          qrCode = postData['post']['qr_code_url'];
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

    Future<void> _deletePost() async {
    setState(() {
      _isDeleting = true; // Show loading
    });

    bool isDeleted = await UserService().deletePostById(context, postId);

    setState(() {
      _isDeleting = false; // Hide loading
    });

    if (isDeleted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        'homePageRoute', // Replace with your home page route name
        (route) => false, // Remove all previous routes
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    // final userData = userProvider.userData;
    // final isLoading = userProvider.isLoading;
    return Scaffold(
      body: isLoading ? BuildShimmerEffect() : Stack(
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
                        onTap: () {if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          // Show a message, prevent app from closing, or navigate elsewhere
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                            (route) => false, // Removes all previous routes
                          );
                        }},
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
                    Positioned(
                      top: 40,
                      right: 16,
                      child: InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QRCodeScreen(qrCode: qrCode, imageUrl: imageUrl)),
                          ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(118, 0, 0, 0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.qr_code_2_sharp, color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ),
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
                const SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10,left: 20, right: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color.fromARGB(223, 38, 182, 122), const Color.fromARGB(205, 15, 119, 125)], // Customize your gradient colors
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpadtePostPage(postId: postId, postLocation: postLocation),
                      ),
                    );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Make button background transparent
                      shadowColor: Colors.transparent, // Remove shadow effect
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Edit Post',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                Container(
      margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 201, 84, 84),
            const Color(0xFFff5e5e),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        onPressed: _isDeleting
            ? null
            : () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color.fromARGB(255, 209, 62, 62), // Red background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      title: Column(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 50,
                            color: Colors.white, // Icon color
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        'Are you sure you want to delete this post? This action cannot be undone.',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      actions: [
                        // Cancel Button
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        // Delete Button
                        TextButton(
                          onPressed: _isDeleting ? null : () async {
                            Navigator.of(context).pop(); // Close dialog
                            await _deletePost(); // Start delete process
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              _isDeleting ? Colors.grey : Colors.red, // Grey when disabled
                            ),
                          ),
                          child: _isDeleting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.white),
                                ),
                        )
                      ],
                    );
                  },
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Transparent button background
          shadowColor: Colors.transparent, // Remove shadow effect
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isDeleting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    ),
                SizedBox(height: 20,)
              ],
            ),
          ),
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     padding: const EdgeInsets.all(16),
          //     decoration: BoxDecoration(
          //       color: const Color.fromARGB(88, 255, 255, 255),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.1),
          //           blurRadius: 10,
          //           offset: const Offset(0, -5),
          //         ),
          //       ],
          //     ),
          //     child: Container(
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(
          //           colors: [AppColors.primaryColor, AppColors.tertiaryColor], // Customize your gradient colors
          //           begin: Alignment.topLeft,
          //           end: Alignment.bottomRight,
          //         ),
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: ElevatedButton(
          //         onPressed: () {},
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.transparent, // Make button background transparent
          //           shadowColor: Colors.transparent, // Remove shadow effect
          //           padding: const EdgeInsets.symmetric(vertical: 16),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //         ),
          //         child: const Text(
          //           'Send message via chat',
          //           style: TextStyle(
          //             fontSize: 16,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.white,
          //           ),
          //         ),
          //       ),
          //     ),

          //   ),
          // ),
        ],
      ),
    );
  }
}

