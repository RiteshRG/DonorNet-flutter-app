import 'package:donornet/materials/access_throught_link.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/post_service.dart';
import 'package:donornet/services%20and%20provider/user_service.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/views/home%20page/drawer.dart';
import 'package:donornet/views/post%20details/post_details_page.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  final String userId;

   const UserProfile({Key? key, required this.userId}) : super(key: key);


  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? userDetails; // ✅ Use nullable variable
  bool isLoading = false;
  late Future<List<Map<String, dynamic>>> _futurePosts;
  late Future<List<String>> claimedPost;

  @override
  void initState() {
    super.initState();
     _futurePosts = PostService().fetchAvailablePosts(widget.userId);
    claimedPost = PostService().getClaimedPostImages(widget.userId);
    _fetchUserData();
  }

  void _fetchUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedUserDetails = await UserService().fetchUserDetailsAndLevel(widget.userId);

      if (mounted) {
        setState(() {
          userDetails = fetchedUserDetails; // ✅ Ensure safe assignment
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    key: _scaffoldKey,
    drawer: CustomDrawer(),
    body: Stack(
      children: [
        if (isLoading)
          Center(child: LoadingIndicator(isLoading: true))
        else
          Column(
            children: [
              // Profile Header Section
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.tertiaryColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Container(
                        height: 280,
                        width: double.infinity,
                        child: userDetails?['profile_image'] != null &&
                                userDetails!['profile_image'].isNotEmpty
                            ? Image.network(
                                userDetails!['profile_image'],
                                opacity: AlwaysStoppedAnimation(0.1),
                                fit: BoxFit.cover,
                              )
                            : SizedBox(),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(Icons.arrow_back, color: Colors.white),
                                ),
                                InkWell(
                                  onTap: () {
                                    _scaffoldKey.currentState?.openDrawer();
                                  },
                                  child: Icon(Icons.menu, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 197, 223, 212),
                                    width: 2.0,
                                  ),
                                ),
                                child: userDetails != null && userDetails!['profile_image'] != null
                                    ? CircleAvatar(
                                        radius: 50,
                                        backgroundImage: NetworkImage(userDetails!['profile_image']),
                                      )
                                    : CircleAvatar(
                                        radius: 50,
                                        child: Icon(Icons.person, size: 50),
                                      ),
                              ),
                              Positioned(
                              right: -4,
                              top: -4,
                              child: (userDetails != null && userDetails!["level"] != null && userDetails!["level"] > 0)
                                  ? Container(
                                      height: 40,
                                      width: 40,
                                      padding: EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.all(Radius.circular(100)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            spreadRadius: 0,
                                            blurRadius: 0.5,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Image.network(
                                        AccessLink.getLevelImage(userDetails!['level']), // Dynamically load correct level image
                                        height: 40,
                                        width: 40,
                                      ),
                                    )
                                  : SizedBox(), // Empty widget if level is 0 or null
                            ),

                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            '${userDetails?['first_name'] ?? 'User'} ${userDetails?['last_name'] ?? 'Name'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Level ${userDetails?['level'] ?? ' '}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              Text(
                                '  ${userDetails?['rating'] ?? ''}',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Tabs Section
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Pending Donations'),
                          Tab(text: 'Claimed Donations'),
                        ],
                        labelColor: AppColors.primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppColors.secondaryColor,
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildDonationsGrid('Pending Donations'),
                            _buildDonationsClaimedGrid('Claimed Donations'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

  
  Widget _buildDonationsGrid(String section) {
     return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return LoadingIndicator(isLoading: true);
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No available posts'));
        }

        List<Map<String, dynamic>> posts = snapshot.data!;
        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostDetailsPage( posts[index]['postId'])),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    posts[index]['image_url'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  
  Widget _buildDonationsClaimedGrid(String section) {
   return FutureBuilder<List<String>>(
    future: claimedPost,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Show loading indicator while fetching data
        return LoadingIndicator(isLoading: true);
      }

      if (snapshot.hasError) {
        // Show an error message if fetching fails
        return Center(child: Text("Failed to load images"));
      }

      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        // Show a message if there are no claimed post images
        return Center(child: Text("No claimed posts found"));
      }

      // Get the list of images
      List<String> imageUrls = snapshot.data!;

      return GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: imageUrls.length, // Use the actual number of images
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                imageUrls[index], // Display fetched images
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return LoadingIndicator(isLoading: true); // Show loading indicator for images
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 50, color: Colors.grey); // Show error icon if image fails to load
                },
              ),
            ),
          );
        },
      );
    },
  );
}
}
