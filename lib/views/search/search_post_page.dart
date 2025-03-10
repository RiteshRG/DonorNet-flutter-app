import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/internet_checker.dart';
import 'package:donornet/services%20and%20provider/map_service.dart';
import 'package:donornet/services%20and%20provider/post_service.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/utilities/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:donornet/views/home%20page/post.dart';
import 'dart:developer' as devtools show log;

class SearchPostPage extends StatefulWidget {
  final String searchQuery; 

  SearchPostPage({required this.searchQuery});

  @override
  _SearchPostPageState createState() => _SearchPostPageState();
}

class _SearchPostPageState extends State<SearchPostPage> {
  int? currentIndex;
  String selectedFilter = "Infinity";
  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _isConnected = true;
  late String searchQuery;

  // This list will store the fetched posts.
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    searchQuery = widget.searchQuery;
    _checkInternetStatus();
    _searchController = TextEditingController(text: widget.searchQuery);
    _fetchPosts();
    _scrollController.addListener(_onScroll);
    // Initialize any internet checker if needed.
    InternetChecker.init((bool isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    InternetChecker.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _fetchPosts(loadMore: true);
    }
  }

 Future<void> _fetchPosts({bool loadMore = false}) async {
  if (loadMore && _isFetchingMore) return;
  setState(() {
    _isFetchingMore = loadMore;
  });

  String text = triggerSearch(_searchController.text);
  devtools.log('$text');
  List<Map<String, dynamic>> newPosts =
      await PostService().searchPosts(text);

  // Optionally, if you want to apply a distance sort:
  if (newPosts.isNotEmpty) {
    newPosts = await MapService().sortPostsByDistance(newPosts, selectedFilter);
  }

  // When loading more, filter out posts that already exist in _posts.
  if (loadMore) {
    final existingIds = _posts.map((post) => post['id']).toSet();
    newPosts = newPosts.where((post) => !existingIds.contains(post['id'])).toList();
  }

  setState(() {
    if (loadMore) {
      _posts.addAll(newPosts);
    } else {
      _posts = newPosts;
    }
    _isLoading = false;
    _isFetchingMore = false;
  });
}

  Future<void> _checkInternetStatus() async {
    _isConnected = await InternetChecker.hasInternet();
    setState(() {});
  }

  Future<void> _refreshPage() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    await _fetchPosts();
  }

  void _onSearchChanged() {
    setState(() {
      // Update the search text if needed.
      // You can also call a new search here if you want to perform live search.
    });
  }


  final List<Map<String, dynamic>> filters = [
    {"label": "Infinity", "icon": Icons.all_inclusive}, // Infinity icon
    {"label": "5"},
    {"label": "10"},
    {"label": "20"},
    {"label": "30"},
    {"label": "40"},
    {"label": "50"},
    {"label": "60"},
    {"label": "100"},
    {"label": "200"},
  ];


  void _openFilterBottomSheet() {
    // Add your filter logic
    print("Filter Clicked");
  }

  String triggerSearch(String value) {
  String trimmedValue = value.trim();
  if (trimmedValue.isEmpty) {
    return ""; 
  }
  print("Search Query: $trimmedValue");
  return trimmedValue;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Search"),
      //   flexibleSpace: Container(
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [Color(0xFF38A1DB), Color(0xFF1A73E8)],
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //       ),
      //     ),
      //   ),
      // ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
           Positioned(
            // top: 0, 
            child: Container(
              width: double.infinity,
                height:70,
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
          SafeArea(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                    height:105,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.only(   
                      bottomLeft: Radius.circular(20), 
                      bottomRight: Radius.circular(20), 
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: filters.map((filter) {
                              bool isSelected = selectedFilter == filter["label"];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedFilter = filter["label"];
                                    });
                                    _refreshPage();

                                    print("$selectedFilter");
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color.fromARGB(255, 255, 255, 255): const Color.fromARGB(255, 29, 194, 125),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? const Color.fromARGB(0, 0, 0, 0) : const Color.fromARGB(0, 15, 119, 125),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 5,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        if (filter["icon"] != null) ...[
                                          Icon(filter["icon"], color: isSelected ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(221, 255, 255, 255)),
                                          SizedBox(width: 5),
                                        ],
                                        Text(
                                          filter["label"] == "Infinity" 
                                              ? "${filter["label"]}" 
                                              : "${filter["label"]}km",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected
                                                ? const Color.fromARGB(255, 0, 0, 0)
                                                : const Color.fromARGB(221, 255, 255, 255),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    // Search Bar and Filter Button
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                onSubmitted: (value) {
                                  _fetchPosts();
                                  _refreshPage();
                                },
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  // Wrap the prefix icon with an IconButton to make it clickable.
                                  prefixIcon: IconButton(
                                    icon: Icon(Icons.search, color: Colors.grey),
                                    onPressed: () {
                                      _fetchPosts();
                                      _refreshPage();
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),

                            ),
                          ),
                          // SizedBox(width: 10),
                          // // Filter Button
                          // GestureDetector(
                          //   onTap: () {
                          //     _openFilterBottomSheet();
                          //   },
                          //   child: Container(
                          //     padding: EdgeInsets.all(15),
                          //     height: 55,
                          //     width: 55,
                          //     decoration: BoxDecoration(
                          //       gradient: LinearGradient(
                          //         colors: [Colors.green, Colors.teal],
                          //         begin: Alignment.topLeft,
                          //         end: Alignment.bottomRight,
                          //       ),
                          //       borderRadius: BorderRadius.all(Radius.circular(20)),
                          //       boxShadow: [
                          //         BoxShadow(
                          //           color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.4),
                          //           spreadRadius: 1,
                          //           blurRadius: 7,
                          //           offset: Offset(0, 5),
                          //         ),
                          //       ],
                          //     ),
                          //     child: SvgPicture.asset(
                          //       'assets/icons/filter.svg',
                          //       height: 20,
                          //       width: 20,
                          //       fit: BoxFit.cover,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                
                    // Post List
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
        ],
      ),
    //   bottomNavigationBar: Container(
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       boxShadow: [
    //         BoxShadow(
    //           color: Colors.black.withOpacity(0.1),
    //           spreadRadius: 1,
    //           blurRadius: 5,
    //           offset: Offset(0, -2),
    //         ),
    //       ],
    //     ),
    //     child:BottomNavigationBar(
    //     type: BottomNavigationBarType.fixed,
    //     selectedItemColor: AppColors.primaryColor,
    //     unselectedItemColor:const Color.fromARGB(179, 55, 170, 122),
    //     currentIndex: currentIndex ?? 0,
    //       onTap: (index) {
    //         if(index == 2){
    //            //Navigator.of(context).pushNamed('addItemPageRoute');
    //            Navigator.of(context).pushNamedAndRemoveUntil(
    //             'addItemPageRoute', 
    //             (Route<dynamic> route) => false,  
    //           );
    //         }
    //         if(index == 3){
    //            //Navigator.of(context).pushNamed('addItemPageRoute');
    //            Navigator.of(context).pushNamedAndRemoveUntil(
    //             'chatPageRoute', 
    //             (Route<dynamic> route) => false,  
    //           );
    //         }
    //         if(index == 4){
    //            //Navigator.of(context).pushNamed('myProfilePageRoute');
    //           Navigator.of(context).pushNamedAndRemoveUntil(
    //             'myProfilePageRoute', 
    //             (Route<dynamic> route) => false,  
    //           );
    //         }
    //         if(index == 0){
    //          Navigator.of(context).pushNamedAndRemoveUntil(
    //             'homePageRoute', 
    //             (Route<dynamic> route) => false,  
    //           );
    //         }

    //       },
    //     items: [
    //       BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
    //       BottomNavigationBarItem(icon: Icon(Icons.location_on), label: ''),
    //       BottomNavigationBarItem(
    //         icon: Container(
    //           padding: EdgeInsets.all(8),
    //           decoration: BoxDecoration(
    //             gradient: LinearGradient(
    //                 colors: [AppColors.primaryColor, AppColors.tertiaryColor], 
    //                 begin: Alignment.topLeft, 
    //                 end: Alignment.bottomRight,
    //             ), 
    //             shape: BoxShape.circle,
    //           ),
    //           child: Icon(Icons.add, color: Colors.white),
    //         ),
    //         label: '',
    //       ),
    //       BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
    //       BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
    //     ],
    //   )),
    // 
    );
  }

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
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => HomePage()), // Replace with your actual page
              // );
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
              _refreshPage();
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

