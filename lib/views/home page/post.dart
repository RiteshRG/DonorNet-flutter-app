import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/user_service.dart';
import 'package:donornet/views/post%20details/User_post_details.dart';
import 'package:donornet/views/post%20details/post_details_page.dart';
import 'package:donornet/views/user_profile.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = post['title'] ?? 'Untitled';
    final String imageUrl = post['image_url'] ?? '';
    final DateTime createdAt = post['created_at'] is Timestamp
        ? (post['created_at'] as Timestamp).toDate()
        : DateTime.now();
    final String formattedDate = DateFormat("d MMM").format(createdAt);

    // ✅ Handle distance safely
    final String distanceKm = post['distance_km']?.toString() ?? "N/A";

    // ✅ Extract user details safely
    final user = post['user'] ?? {};
    final String firstName = user['first_name'] ?? 'Unknown';
    final String lastName = user['last_name'] ?? '';
    final String profileImage = user['profile_image'] ?? '';
    final String user_rating = post['user_rating']?? '';

    // // 🔍 Debugging log
    //  devtools.log("Post Data Types: ${post}");
    // devtools.log("Post Data Types: ${user['user_rating']}");

    return GestureDetector(
      onTap: () {
        UserService userService = UserService();
        if (userService.isCurrentUser(user['userId']?? 'Unknown')) {
          devtools.log("User can edit/delete this post.");
           Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserPostDetailPage(post['postId'])),
          );
        } else {
          devtools.log("User can only view this post.");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostDetailsPage(post['postId'])),
          );
        }
        print('post clicked');
      },
      child: Container(
        margin: EdgeInsets.only(right: 10, left: 10, bottom: 20),
        height: 240,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2), 
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 178,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 178,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 178,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5, right: 10, left: 75),
                  child: Row(
                    children: [
                      FittedBox(
                        child: Text("$firstName $lastName",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(width: 8,),
                      Icon(
                        Icons.arrow_drop_down_circle_rounded,
                        color: Colors.black,
                        size: 4,
                      ),
                      SizedBox(width: 8,),
                      Icon(Icons.star,
                        color: Color.fromARGB(255, 255, 200, 0),
                        size: 12,
                      ),
                      SizedBox(width: 5,),
                      FittedBox(
                        child: Text(user_rating,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black
                            ),
                        ),
                      ),
                      Expanded(child: Container()),
                      Icon(Icons.location_on_sharp,
                        color: AppColors.primaryColor,
                        size: 14,
                      ),
                      SizedBox(width: 2,),
                      FittedBox(
                        child: Text("${distanceKm} km",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 35.5, top: 3, right: 5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "$title",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,  // Adds ellipsis when text overflows
                    maxLines: 1,  // Optional: limits to one line of text
                  )

                )
              ],
            ),
            Positioned(
              top: 5,
              right: 10,
              child: Text(
                formattedDate,
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
            Positioned(
              bottom: 42.5,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(
                        profileImage: profileImage,
                        name: "$firstName $lastName",
                        rating: user_rating
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(left: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
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
                      profileImage,
                      height: 35,
                      width: 35,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => ClipOval( // ✅ Corrected from "lipOval" to "ClipOval"
                        child: Icon(
                          Icons.person, // Placeholder icon when image fails to load
                          size: 35,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart'; 
// import 'package:donornet/materials/app_colors.dart';
// import 'package:donornet/views/post%20details/user_post_details_page.dart';
// import 'package:donornet/views/user_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'dart:developer' as devtools show log;

// class PostCard extends StatefulWidget {
//   final Map<String, dynamic> post;
//   const PostCard({Key? key, required this.post}) : super(key: key);

//   @override
//   _PostCardState createState() => _PostCardState();
// }

// class _PostCardState extends State<PostCard> {

//   @override
//   Widget build(BuildContext context) {
//        final String title = widget.post['title'] ?? 'Untitled';
//     final String imageUrl = widget.post['image_url'] ?? '';
//     final DateTime createdAt = widget.post['created_at'] is Timestamp
//         ? (widget.post['created_at'] as Timestamp).toDate()
//         : DateTime.now();
//     final String formattedDate = DateFormat("d MMM").format(createdAt);

//     // ✅ Handle distance safely
//     final String distanceKm = widget.post['distance_km']?.toString() ?? "N/A";

//     // ✅ Extract user details safely
//     final user = widget.post['user'] ?? {};
//     final String firstName = user['first_name'] ?? 'Unknown';
//     final String lastName = user['last_name'] ?? '';
//     final String profileImage = user['profile_image'] ?? '';
//     final String user_rating = user['user_rating'];

//     return GestureDetector(
//       onTap: () {
//         print('post clicked');
//       },
//       child: Container(
//         margin: EdgeInsets.only(right: 10, left: 10, bottom: 20),
//         height: 240,
//         decoration: BoxDecoration(
//           color: const Color.fromARGB(255, 255, 255, 255),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2), 
//               spreadRadius: 2, 
//               blurRadius: 4, 
//               offset: Offset(0, 0), 
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                   child: imageUrl.isNotEmpty
//                       ? Image.network(
//                           imageUrl,
//                           width: double.infinity,
//                           height: 178,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               height: 178,
//                               width: double.infinity,
//                               color: Colors.grey[300],
//                               child: const Icon(
//                                 Icons.broken_image,
//                                 size: 50,
//                                 color: Colors.grey,
//                               ),
//                             );
//                           },
//                         )
//                       : Container(
//                           height: 178,
//                           width: double.infinity,
//                           color: Colors.grey[300],
//                           child: const Icon(
//                             Icons.image_not_supported,
//                             size: 50,
//                             color: Colors.grey,
//                           ),
//                         ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(top: 5, right: 10, left: 75),
//                   child: Row(
//                     children: [
//                       FittedBox(
//                         child: Text("$firstName $lastName",
//                           style: TextStyle(
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 12,),
//                       Icon(
//                         Icons.arrow_drop_down_circle_rounded,
//                         color: Colors.black,
//                         size: 4,
//                       ),
//                       SizedBox(width: 12,),
//                       Icon(Icons.star,
//                         color: Color.fromARGB(255, 255, 200, 0),
//                         size: 14,
//                       ),
//                       SizedBox(width: 5,),
//                       FittedBox(
//                         child: Text("$user_rating",
//                           style: TextStyle(
//                               fontSize: 12,
//                             ),
//                         ),
//                       ),
//                       Expanded(child: Container()),
//                       Icon(Icons.location_on_sharp,
//                         color: AppColors.primaryColor,
//                         size: 14,
//                       ),
//                       SizedBox(width: 2,),
//                       FittedBox(
//                         child: Text("${distanceKm} Km",
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 12
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(left: 40.5, top: 3),
//                   alignment: Alignment.centerLeft,
//                   child: FittedBox(
//                     child: Text("$title",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             Positioned(
//               top: 5,
//               right: 10,
//               child: Text(
//                 formattedDate,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   shadows: [
//                     Shadow(
//                       offset: Offset(2, 2), 
//                       blurRadius: 4.0, 
//                       color: Colors.black.withOpacity(0.6),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 42.5,
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => UserProfile(
//                         profileImage: profileImage,
//                         name: "$firstName $lastName",
//                         rating: user_rating
//                       ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   margin: EdgeInsets.only(left: 18),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(1000),
//                     border: Border.all(
//                       color: Colors.white,
//                       width: 2,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.4),
//                         offset: Offset(2, 1),
//                         blurRadius: 6,
//                         spreadRadius: 1,
//                       ),
//                     ],
//                   ),
//                   child: ClipOval(
//                     child: Image.network(
//                       profileImage,
//                       height: 35,
//                       width: 35,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:donornet/materials/app_colors.dart';
// import 'package:donornet/views/post%20details/user_post_details_page.dart';
// import 'package:donornet/views/user_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class PostCard extends StatefulWidget {
//   final Map<String, dynamic> post;
//   const PostCard({Key? key, required this.post}) : super(key: key);

//   @override
//   _PostCardState createState() => _PostCardState();
// }

// class _PostCardState extends State<PostCard> {
   
//   @override
//   Widget build(BuildContext context) {
//     double rating = (widget.post['user_rating'] as num?)?.toDouble() ?? 0.0;
//     final user = widget.post['user'] ?? {};
//     final String firstName = user['first_name'] ?? 'Unknown';
//     final String lastName = user['last_name'] ?? '';
//     final String profileImage = user['profile_image'] ?? '';
//     final String title = widget.post['title'] ?? 'Untitled';
//     final double distanceKm = (widget.post['distance_km'] as num?)?.toDouble() ?? 0.0;
//     final DateTime createdAt = widget.post['created_at'] is Timestamp
//         ? (widget.post['created_at'] as Timestamp).toDate()
//         : DateTime.now();
//     final String formattedDate = DateFormat("d MMM").format(createdAt);
//     final String imageUrl = widget.post['image_url'] ?? '';

//     return GestureDetector(
//       onTap: () {

//     //     Navigator.push(
//     //   context,
//     //   MaterialPageRoute(
//     //     builder: (context) => PostDetailsPage(post: widget.post),
//     //   ),
//     // );
//         print('post clicked');
//       },
//       child: Container(
//         margin: EdgeInsets.only(right: 10,
//           left: 10,
//           bottom: 20),
//         height: 240,
//         decoration: BoxDecoration(
//           color: const Color.fromARGB(255, 255, 255, 255),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2), 
//               spreadRadius: 2, 
//               blurRadius: 4, 
//               offset: Offset(0, 0), 
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             Container(  
//               child: Stack(
//                 children: [
//                   Column(
//                     children: [
//                       //image
//                         ClipRRect(
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                         child: widget.post['image_url'] != null && widget.post['image_url'].toString().isNotEmpty
//                             ? Image.network(
//                                 widget.post['image_url'],
//                                 width: double.infinity,
//                                 height: 178,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return Container(
//                                     height: 178,
//                                     width: double.infinity,
//                                     color: Colors.grey[300], // Background color
//                                     child: const Icon(
//                                       Icons.broken_image,
//                                       size: 50,
//                                       color: Colors.grey,
//                                     ),
//                                   );
//                                 },
//                               )
//                             : Container(
//                                 height: 178,
//                                 width: double.infinity,
//                                 color: Colors.grey[300], // Background color
//                                 child: const Icon(
//                                   Icons.image_not_supported,
//                                   size: 50,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                       ),
            
//                       //text
//                       Container(
//                         padding: EdgeInsets.only(top:5, right: 10, left: 75),
//                         child: Expanded(
//                           child: Row(
//                             children: [
//                               //name
//                               FittedBox(
//                                 child: Text("${user['first_name']} ${user['last_name']}",
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                 ),
//                                 ),
//                               ),
//                               SizedBox(width: 12,),
//                               Icon(
//                                 Icons.arrow_drop_down_circle_rounded,
//                                 color: Colors.black,
//                                 size: 4,
//                               ),
//                               SizedBox(width: 12,),
//                               Icon(Icons.star,
//                                 color: Color.fromARGB(255, 255, 200, 0),
//                                 size: 14,
//                               ),
//                               SizedBox(width: 5,),
//                               FittedBox(
//                                 child: Text("${rating}",
//                                 style: TextStyle(
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
                          
//                               Expanded(child: Container()),
//                               Icon(Icons.location_on_sharp,
//                                 color: AppColors.primaryColor,
//                                 size: 14,
//                               ),
//                               SizedBox(width: 2,),
//                               FittedBox(
//                                 child: Text("${widget.post['distance_km']} Km",
//                                   style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 12
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
            
//                       Container(
//                         padding: EdgeInsets.only(left: 40.5, top: 3),
//                         alignment: Alignment.centerLeft,
//                         child: FittedBox(
//                           child: Text("${widget.post['title']}",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400
//                           ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   // date
//                   Positioned(
//                     top: 5,
//                     right: 10,
//                     child: Text(
//                       "${DateFormat("d MMM").format(
//       (widget.post['created_at'] as Timestamp).toDate())}",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         shadows: [
//                           Shadow(
//                             offset: Offset(2, 2), 
//                             blurRadius: 4.0, 
//                             color: Colors.black.withOpacity(0.6),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             //profile
//             Positioned(
//               bottom: 42.5,
//               child: GestureDetector(
//                 onTap: () {
//                  Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => UserProfile(
//                       profileImage: "user['profile_image']", // Correctly accessing post data
//                       name: "${user['first_name']} ${user['last_name']}",
//                       rating: "${widget.post['user_rating']?.toStringAsFixed(1) ?? 'N/A'}"
//                     ),
//                   ),
//                 );


//                 },
//                 child: Container(
//                   margin: EdgeInsets.only(left: 18),
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(1000),
//                       border: Border.all(
//                         color: Colors.white, // You can change the color of the border here
//                         width: 2, // Adjust the width of the border
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.4), // Shadow color with opacity
//                           offset: Offset(2, 1), // Shadow position (x, y)
//                           blurRadius: 6, // Blur effect
//                           spreadRadius: 1, // Spread effect
//                         ),
//                       ],
//                     ),
//                   child: ClipOval(
//                     child:  Image.network(
//                       '${user['profile_image']}',
//                       height: 35,
//                       width: 35,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

