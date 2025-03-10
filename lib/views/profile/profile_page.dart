import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/user_provider.dart';
import 'package:donornet/materials/access_throught_link.dart';
import 'package:donornet/services%20and%20provider/user_service.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/utilities/shimmer_loading.dart';
import 'package:donornet/views/home%20page/drawer.dart';
import 'package:donornet/views/my_account_page.dart';
import 'package:donornet/views/post%20details/User_post_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile_page extends StatefulWidget {
  @override
  _Profile_pageState createState() => _Profile_pageState();
}

class _Profile_pageState extends State<Profile_page> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Map<String, dynamic>>> _futurePosts;
  late Future<List<String>> claimedPost;
  String rating = "";
  String userId = "";


    @override
  void initState() {
    super.initState();
    // Fetch user data when the screen is initialized
    userId = UserService().currentUserId!;
    _fetchUserRating();
     Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserDetails();
      userProvider.fetchUserLevels(context); 
      if (userProvider.userData != null && userProvider.userData!['uid'] != null) {
        userProvider.fetchUserRating(userProvider.userData!['uid']); 
      }
       _futurePosts = UserProvider().fetchAvailablePosts();
       claimedPost = UserProvider().getClaimedPostImages();
    });
  }

  Future<void> _fetchUserRating() async {
    String fetchedRating = await UserService().getUserRating(userId);
    setState(() {
      rating = fetchedRating; // Update state with fetched rating
    });
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;
    final isLoading = userProvider.isLoading;
    final userLevel = userProvider.userLevel;
    final pointsRequired = userProvider.pointsRequired;
    final userRating = userProvider.userRating; 
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      body: Stack(
        children: [
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
                        child: userData != null && userData['profile_image'] != null
                        ? Image.network(
                            userData['profile_image'], // Load from Firebase or any URL
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
                                  onTap: (){
                                    Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => MyAccountPage()),
                                    (Route<dynamic> route) => false, // Removes all previous routes
                                  );
                                  },
                                  child:Icon(Icons.mode_edit_outline_outlined, color: Colors.white, size: 25,),

                                ),
                                
                                InkWell(
                                  onTap: (){
                                      _scaffoldKey.currentState?.openDrawer();
                                  },
                                  child: Icon(Icons.menu,
                                color: Colors.white,
                                ),
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
                                    color: const Color.fromARGB(255, 197, 223, 212), // White border color
                                    width: 2.0, // Border thickness
                                  ),
                                ),
                                child:  userData != null && userData['profile_image'] != null
                                ? CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(userData['profile_image'],),
                                  )
                                : CircleAvatar(
                                    radius: 50,
                                    child: Icon(Icons.person, size: 50),
                                  ),
                              ),
                              Positioned(
                                right: -4,
                                top: -4,
                                child: userProvider.userLevel > 0 
                                    ? Container(
                                        height: 40,
                                        width: 40,
                                        padding: EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent, 
                                          borderRadius: BorderRadius.all(Radius.circular(100)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1), // Shadow color
                                              spreadRadius: 0, // How much the shadow spreads
                                              blurRadius: 0.5, // How blurry the shadow is
                                              offset: Offset(0, 2), // Shadow position (x, y)
                                            ),
                                          ],
                                        ),
                                        child: Image.network(
                                          AccessLink.getLevelImage(userProvider.userLevel), // Dynamically load correct level image
                                          height: 40,
                                          width: 40,
                                        ),
                                      )
                                    : SizedBox(), // Empty widget if level is 0
                              ),
                             ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            '${userData?['first_name']} ${userData?['last_name']}',
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
                                'Level ${userProvider.userLevel}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              Text(
                                '  ${rating}',
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
                        indicatorColor:  AppColors.secondaryColor,
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
          LoadingIndicator(isLoading: isLoading),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child:BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
         unselectedItemColor:const Color.fromARGB(179, 55, 170, 122),
        currentIndex: 4, // Set initial index
          onTap: (index) {
            if(index == 0){
               Navigator.of(context).pushNamedAndRemoveUntil('homePageRoute', (route) => false,);
            }
            if(index == 2){
               Navigator.of(context).pushNamed('addItemPageRoute');
            }
            if(index == 3){
               Navigator.of(context).pushNamedAndRemoveUntil('chatPageRoute', (route) => false,);
            }
          },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: ''),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.tertiaryColor], 
                    begin: Alignment.topLeft, 
                    end: Alignment.bottomRight,
                ), 
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      )),
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
                  MaterialPageRoute(builder: (context) => UserPostDetailPage( posts[index]['postId'])),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                  posts[index]['image_url'], // Display fetched images
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Icon(Icons.image, size: 18, color: const Color.fromARGB(255, 110, 110, 110),);
                      //LoadingIndicator(isLoading: true); // Show loading indicator for images
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image, size: 18,color:const Color.fromARGB(255, 110, 110, 110));
                      //LoadingIndicator(isLoading: true); // Show error icon if image fails to load
                    },
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
    future: Provider.of<UserProvider>(context, listen: false).getClaimedPostImages(),
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
