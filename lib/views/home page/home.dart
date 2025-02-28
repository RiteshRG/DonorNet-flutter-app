import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/map_service.dart';
import 'package:donornet/services%20and%20provider/post_service.dart';
import 'package:donornet/services%20and%20provider/user_service.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/utilities/show_dialog.dart';
import 'package:donornet/views/filter.dart';
import 'package:donornet/views/home%20page/drawer.dart';
import 'package:donornet/views/home%20page/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:developer' as devtools show log;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _searchController = TextEditingController();
  String search = "";

  final PostService _postService = PostService();
  final MapService _mapService = MapService();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _deleteExpiredPosts();
    _fetchPosts();
    _searchController.addListener(_onSearchChanged);
    print("Current input: ${_searchController.text}");
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

   Future<void> _fetchPosts({bool loadMore = false}) async {
    if (loadMore && _isFetchingMore) return;

    setState(() {
      _isFetchingMore = loadMore;
    });

    Position position = await Geolocator.getCurrentPosition();
    
    // Fetch posts (which now include user details)
    List<Map<String, dynamic>> newPosts = await _postService.getAvailablePosts();

    if (newPosts.isNotEmpty) {
      // Ensure location exists before sorting
      newPosts = _mapService.sortPostsByDistance(position, newPosts);

      setState(() {
        _posts = newPosts;  // ✅ Replace instead of adding
        // _posts.addAll(newPosts);
        _isLoading = false;
        _isFetchingMore = false;
      });

      for (var i = 0; i < _posts.length; i++) {
  devtools.log("Post $i Data Types: ${_posts[i].map((key, value) => MapEntry(key, value.runtimeType))}");
}

    } else {
      setState(() {
        _posts = [];  // ✅ Clear posts if no data
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  // Function to delete expired posts
  Future<void> _deleteExpiredPosts() async {
    UserService userService = UserService();
    await userService.deleteExpiredPostsForUser(context);
  }

   Future<void> _refreshPage() async {
    if (!mounted) return; 
    await _deleteExpiredPosts(); 
     setState(() {
    _isLoading = true;  // ✅ Show loading indicator
  });
    await _fetchPosts();  // ✅ Wait for posts to refres
    if (!mounted) return;
  }

  void _onSearchChanged() {
  setState(() {
    search = _searchController.text;
  });
}


void _openFilterBottomSheet() {
  showFilterBottomSheet(context); // Call the filter bottom sheet function
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       key: _scaffoldKey,
      drawer: CustomDrawer(),
       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          Positioned(
            // top: 0, 
            child: Container(
              width: double.infinity,
                height:100,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor, 
                // borderRadius: BorderRadius.only(   
                //   bottomLeft: Radius.circular(20), 
                //   bottomRight: Radius.circular(70), 
                // ),
                // gradient: LinearGradient(
                //   colors: [const Color.fromARGB(240, 15, 119, 125), AppColors.primaryColor], 
                //   begin: Alignment.topLeft,  
                //   end: Alignment.bottomRight, 
                // ),
              ),
            ),
          ),
          // Content Layer

          SafeArea(
            child: Stack(
              
              children: [
                 Container(
                  width: double.infinity,
                    height:125,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.only(   
                      bottomLeft: Radius.circular(20), 
                      bottomRight: Radius.circular(70), 
                    ),
                    // gradient: LinearGradient(
                    //   colors: [const Color.fromARGB(240, 15, 119, 125), AppColors.primaryColor], 
                    //   begin: Alignment.topLeft,  
                    //   end: Alignment.bottomRight, 
                    // ),
                  ),
                ),
                Column(
                  children: [
                    // Custom AppBar
                    Container(
                      alignment: Alignment.topLeft,    
                      padding: const EdgeInsets.only(top: 0, bottom: 15,left: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                child: Text(
                                  "DonorNet",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              FittedBox(
                                child: Text(
                                  "Connect and Donate",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    // fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                
                          //******Drawor */
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(
                                top: 5,
                                right: 20
                              ),
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                child: InkWell(
                                  onTap: (){
                                     _scaffoldKey.currentState?.openDrawer();
                                  },
                                  child: Icon(Icons.menu,
                                color: Colors.white,
                                size: 25,
                                ),
                                ),
                              ),
                            ),
                          ) 
                        ],
                        
                      ),
                    ),
                    // Search and Filter Section
                    Container(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 12,
                        bottom: 20,
                        // horizontal: 12.0, vertical: 12
                        ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                // color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 4,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                onSubmitted: (query) {
                                  print("Searching for: $query"); // Replace with your search function
                                },
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 133, 133, 133),
                                  ),
                                  prefixIcon: Icon(Icons.search, color: Color.fromARGB(255, 147, 147, 147)),
                                   border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: Colors.transparent), // Transparent border
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: Colors.transparent, width: 1.0), // Transparent enabled border
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: Colors.transparent, width: 2.0), // Transparent focused border
                                  ),
                                  filled: true,
                                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                
                          SizedBox(width: 10),
                
                          /*****Filter******* */
                          GestureDetector(
                            onTap: () {
                              _openFilterBottomSheet();
                            },
                            child: Container(
                              padding: EdgeInsets.all(15),
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryColor,
                                 gradient: LinearGradient(
                                  colors: [AppColors.tertiaryColor, const Color.fromARGB(255, 29, 146, 97)], 
                                  begin: Alignment.topLeft,  
                                  end: Alignment.bottomRight, 
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 252, 252, 252).withOpacity(0.4),
                                    spreadRadius: 1,
                                    blurRadius: 7,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: SvgPicture.asset('assets/icons/filter.svg',
                              height: 20,
                              width: 20,
                              fit: BoxFit.cover,
                              )
                            ), // Replace with your widget
                          ),
                        ],
                      ),
                    ),
                
                    // Scrollable Post List
                   Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshPage,
                      color: AppColors.primaryColor, 
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255), 
                      child: Container(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: _isLoading
                            ? LoadingIndicator(isLoading: _isLoading)
                            : _posts.isEmpty
                                ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Centers content vertically
                                children: [
                                  Opacity(
                                    opacity: 0.8, // Adjust this value (0.0 to 1.0) for desired transparency
                                    child: Image.network(
                                      'https://i.postimg.cc/zBpTgcmX/mdi-donation.png', // Your image URL
                                      width: 48, // Adjust width as needed
                                      height: 48, // Adjust height as needed
                                      color: Color.fromARGB(44, 35, 151, 103), // Apply color overlay
                                    ),
                                  ),
                                  SizedBox(height: 8), // Spacing between image and text
                                  Text(
                                    "No posts available",
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold, 
                                      color: Color.fromARGB(44, 35, 151, 103),
                                    ),
                                  ),
                                ],
                              ),
                            )

                                : ListView.builder(
                                    itemCount: _posts.length,
                                    itemBuilder: (context, index) {
                                      devtools.log("********${_posts.length}");
                                      try {
                                        devtools.log('*******************PostCard(post: _posts[index])');
                                        return PostCard(post: _posts[index]);
                                      } catch (e) {
                                        devtools.log("Error rendering PostCard: $e");
                                        return Center(
                                          child: Text(
                                            "Error loading post",
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 252, 252, 252)),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                      ),
                    ),
                  ),

                  ],
                ),
              ],
            ),
          ),
          //LoadingIndicator(isLoading: isLoading),
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
        currentIndex: 0, // Set initial index
          onTap: (index) {
            if(index == 1){
               Navigator.of(context).pushNamed('mapPageRoute');
            }
            if(index == 2){
               Navigator.of(context).pushNamed('addItemPageRoute');
            }
            if(index == 3){
               Navigator.of(context).pushNamed('chatPageRoute');
            }
            if(index == 4){
               Navigator.of(context).pushNamed('myProfilePageRoute');
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
}


