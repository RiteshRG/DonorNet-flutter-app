import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchPostPage extends StatefulWidget {
  @override
  _SearchPostPageState createState() => _SearchPostPageState();
}

class _SearchPostPageState extends State<SearchPostPage> {
  int? currentIndex;
  List<PostModel> posts = [
    PostModel(
      name: "John Doe",
      rating: "0",
      distance: "2 km",
      postTitle: "Free Books Available",
      date: "12 Feb 2025",
      postImage: "https://thumbs.dreamstime.com/b/notebooks-books-pencils-5278644.jpg",
      profileImage: "https://www.profilebakery.com/wp-content/uploads/2023/04/Profile-Image-AI.jpg",
    ),
    PostModel(
      name: "Aarav Mehta",
      rating: "1.5",
      distance: "3 km",
      postTitle: "Giving Away Extra Books & Notebooks!",
      date: "9 Feb 2025",
      postImage: "https://tse3.mm.bing.net/th?id=OIP.XkCqtFAoXgkMl8CoGCLxzwHaFj&pid=Api&P=0&h=180",
      profileImage: "https://pbs.twimg.com/profile_images/378800000337800385/6ebe577bf6e026807956ebc99f2dd054_400x400.jpeg",
    ),
    PostModel(
      name: "John Doe",
      rating: "0",
      distance: "2 km",
      postTitle: "Offering My Unused Notebooks",
      date: "12 Feb 2025",
      postImage: "https://i.etsystatic.com/22836928/r/il/fc27a4/2891006588/il_fullxfull.2891006588_9lex.jpg",
      profileImage: "https://www.profilebakery.com/wp-content/uploads/2023/04/Profile-Image-AI.jpg",
    ),
    PostModel(
      name: "John Doe",
      rating: "0",
      distance: "2 km",
      postTitle: "Sharing Books & Notebooks for Anyone Who Needs Them",
      date: "9 Feb 2025",
      postImage: "https://thumbs.dreamstime.com/b/notebooks-books-pencils-5278644.jpg",
      profileImage: "https://www.profilebakery.com/wp-content/uploads/2023/04/Profile-Image-AI.jpg",
    ),
  ];

  String selectedFilter = "Infinity"; // Default selected filter

  final List<Map<String, dynamic>> filters = [
    {"label": "Infinity", "icon": Icons.all_inclusive}, // Infinity icon
    {"label": "10km"},
    {"label": "20km"},
    {"label": "30km"},
    {"label": "40km"},
    {"label": "50km"},
    {"label": "60km"},
    {"label": "100km"},
    {"label": "200km"},
  ];


  void _openFilterBottomSheet() {
    // Add your filter logic
    print("Filter Clicked");
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
                                          filter["label"],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(221, 255, 255, 255),
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
                                    spreadRadius: 4,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  prefixIcon: Icon(Icons.search, color: Colors.grey),
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
                      child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return PostCard(post: posts[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        currentIndex: currentIndex ?? 0,
          onTap: (index) {
            if(index == 2){
               //Navigator.of(context).pushNamed('addItemPageRoute');
               Navigator.of(context).pushNamedAndRemoveUntil(
                'addItemPageRoute', 
                (Route<dynamic> route) => false,  
              );
            }
            if(index == 3){
               //Navigator.of(context).pushNamed('addItemPageRoute');
               Navigator.of(context).pushNamedAndRemoveUntil(
                'chatPageRoute', 
                (Route<dynamic> route) => false,  
              );
            }
            if(index == 4){
               //Navigator.of(context).pushNamed('myProfilePageRoute');
              Navigator.of(context).pushNamedAndRemoveUntil(
                'myProfilePageRoute', 
                (Route<dynamic> route) => false,  
              );
            }
            if(index == 0){
             Navigator.of(context).pushNamedAndRemoveUntil(
                'homePageRoute', 
                (Route<dynamic> route) => false,  
              );
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

// Post Model
class PostModel {
  final String name;
  final String rating;
  final String distance;
  final String postTitle;
  final String date;
  final String postImage;
  final String profileImage;

  PostModel({
    required this.name,
    required this.rating,
    required this.distance,
    required this.postTitle,
    required this.date,
    required this.postImage,
    required this.profileImage,
  });
}

// Post Card Widget
class PostCard extends StatelessWidget {
  final PostModel post;
  PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Post clicked');
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    post.postImage,
                    width: double.infinity,
                    height: 178,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, right: 10, left: 75),
                  child: Row(
                    children: [
                      Text(
                        post.name,
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.star, color: const Color.fromARGB(255, 255, 200, 0), size: 14),
                      SizedBox(width: 5),
                      Text(
                        post.rating,
                        style: TextStyle(fontSize: 12),
                      ),
                      Expanded(child: Container()),
                      Icon(Icons.location_on, color: AppColors.secondaryColor, size: 14),
                      SizedBox(width: 2),
                      Text(
                        post.distance,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 40.5, top: 3, right: 10),
                  alignment: Alignment.centerLeft,
                  child: Text("${post.postTitle}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            // Date
            Positioned(
              top: 5,
              right: 10,
              child: Text(
                post.date,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4.0,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ),
            // Profile Image
            Positioned(
              bottom: 42.5,
              left: 18,
              child: GestureDetector(
                onTap: () {
                  print('Profile clicked');
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: Offset(2, 1),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      post.profileImage,
                      height: 35,
                      width: 35,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
