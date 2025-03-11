import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/internet_checker.dart';
import 'package:donornet/services%20and%20provider/listen_for_level_up.dart';
import 'package:donornet/services%20and%20provider/map_service.dart';
import 'package:donornet/services%20and%20provider/post_service.dart';
import 'package:donornet/services%20and%20provider/user_service.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/utilities/shimmer_loading.dart';
import 'package:donornet/utilities/show_dialog.dart';
import 'package:donornet/views/filter.dart';
import 'package:donornet/views/home%20page/drawer.dart';
import 'package:donornet/views/home%20page/post.dart';
import 'package:donornet/views/search/search_page.dart';
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

class _HomePageState extends State<HomePage>  {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String search = "";

  final PostService _postService = PostService();
  final MapService _mapService = MapService();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _isConnected = true;

   String selectedDistance = "infinity";
  List<String> selectedCategories = ["All"];

  @override
  void initState() {
    super.initState();
    _checkInternetStatus();
    _deleteExpiredPosts();
    _fetchPosts();
    _searchController.addListener(_onSearchChanged);
    print("Current input: ${_searchController.text}");
     _scrollController.addListener(_onScroll);
    _loadFilters();
     // Listen for real-time network changes
    InternetChecker.init((bool isConnected) {  
      setState(() {
        _isConnected = isConnected;
      });
    });
    //   FirebaseAuth.instance.authStateChanges().listen((User? user) {
    //   if (user != null) {
    //     devtools.log('************########');
    //     listenForLevelUp(context, user.uid); // Start listening for level-up events
    //   }
    // });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    InternetChecker.dispose();
    super.dispose();
  }

   Future<void> _loadFilters() async {
    final filters = await loadFilters();
    setState(() {
      selectedDistance = filters['distance'];
      selectedCategories = List<String>.from(filters['categories']);
    });
  }

   void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _fetchPosts(loadMore: true); 
    }
  }

  Future<void> _fetchPosts({bool loadMore = false}) async {
  if (loadMore && _isFetchingMore) return;

  setState(() {
    _isFetchingMore = loadMore;
  });

  devtools.log('Fetching posts with selected categories: $selectedCategories');

  await _loadFilters();

  List<Map<String, dynamic>> newPosts = await _postService.getAvailablePosts(
      loadMore: loadMore, selectedCategories: selectedCategories);

  if (newPosts.isNotEmpty) {
    devtools.log("Applying distance filter: $selectedDistance");

    newPosts = await _mapService.sortPostsByDistance(newPosts, selectedDistance);

    setState(() {
      if (loadMore) {
        _posts.addAll(newPosts); 
      } else {
        _posts = newPosts; 
      }
      _isLoading = false;
      _isFetchingMore = false;
    });

    // Debugging: Log each post's data type
    for (var i = 0; i < _posts.length; i++) {
      devtools.log("Post $i Data: ${_posts[i]}"); 
    }
  } else {
    setState(() {
      if (!loadMore) _posts = []; 
      _isLoading = false;
      _isFetchingMore = false;
    });
  }
}

  Future<void> _checkInternetStatus() async {
    _isConnected = await InternetChecker.hasInternet();
    setState(() {});
  }

  Future<void> _deleteExpiredPosts() async {
    UserService userService = UserService();
    await userService.deleteExpiredPostsForUser(context);
  }

   Future<void> _refreshPage() async {
    if (!mounted) return; 
    await _deleteExpiredPosts(); 
     setState(() {
    _isLoading = true;  
  });
    _fetchPosts();  
    if (!mounted) return;
  }

  void _onSearchChanged() {
  setState(() {
    search = _searchController.text;
  });
}


void _openFilterBottomSheet() {
  showFilterBottomSheet(context, _refreshPage); 
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
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SearchPage()),
                                  );
                                },
                                child: AbsorbPointer( 
                                  child: TextField(
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
                                        borderSide: BorderSide(color: Colors.transparent), 
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(color: Colors.transparent, width: 1.0), 
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(color: Colors.transparent, width: 2.0), 
                                      ),
                                      filled: true,
                                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
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
                            : !_isConnected
                                ? _buildNoInternetWidget()
                                : _posts.isEmpty
                                    ?  _buildNoPostsWidget()
                                : ListView.builder(
                                controller: _scrollController,
                                itemCount: _posts.length + (_isFetchingMore ? 1 : 0), // Extra item for loading
                                itemBuilder: (context, index) {
                                  if (index == _posts.length) {
                                    // Show loading indicator at bottom while fetching more posts
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: PostLoadingAnimation(), // Loading indicator
                                      ),
                                    );
                                  }
                                  try {
                                    return PostCard(post: _posts[index]);
                                  } catch (e) {
                                    devtools.log("Error rendering PostCard: $e");
                                    return Center(
                                      child: Text(
                                        "Error loading post",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
    // Widget for "No Internet Connection"
  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 60, color:  const Color.fromARGB(128, 38, 182, 122)),
          SizedBox(height: 8),
          Text(
            "No Internet Connection",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:const Color.fromARGB(128, 38, 182, 122)),
          ),
          SizedBox(height: 4),
          Text("Please check your connection and try again.", style: TextStyle(fontSize: 14, color: const Color.fromARGB(146, 158, 158, 158))),
            SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
            bool isConnected = await InternetChecker.hasInternet();
            if (isConnected) {
              // Restart the page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()), // Replace with your actual page
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Still no internet connection. Please try again later."),backgroundColor:const Color.fromARGB(255, 222, 78, 78)),
              );
            }
          },
          icon: Icon(Icons.refresh, color: Colors.white,),
          label: Text("Retry"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 38, 182, 122), // Button color
            foregroundColor: Colors.white, // Text & icon color
          ),
        ),
        ],
      ),
    );
  }

  // Widget for "No Posts Available"
  Widget _buildNoPostsWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.post_add, size: 60, color: const Color.fromARGB(128, 38, 182, 122)),
          SizedBox(height: 8),
          Text(
            "No posts available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color.fromARGB(128, 38, 182, 122)),),SizedBox(height: 16),
            ElevatedButton.icon(
          onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()), // Replace with your actual page
              );
          },
          icon: Icon(Icons.refresh, color: Colors.white,),
          label: Text("Refresh"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 38, 182, 122), // Button color
            foregroundColor: Colors.white, // Text & icon color
          ),
        ),
        ],
      ),
    );
  }
}

                    
                                // : ListView.builder(
                                //    controller: _scrollController,
                                //     itemCount: _posts.length+1,
                                //     itemBuilder: (context, index) {
                                //       devtools.log("********${_posts.length}");
                                //       try {
                                //         devtools.log('*******************PostCard(post: _posts[index])');
                                //         return PostCard(post: _posts[index]);
                                //       } catch (e) {
                                //         devtools.log("Error rendering PostCard: $e");
                                //         return Center(
                                //           child: Text(
                                //             "Error loading post",
                                //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 252, 252, 252)),
                                //           ),
                                //         );
                                //       }
                                //     },
                                //   ),