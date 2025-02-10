import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';

class PostDataList{
  final String postImage;
  final String profileImage;
  final String date;
  final String name;
  final String rating;
  final String distance;
  final String postTitle;

  PostDataList({
    required this.postImage,
    required this.profileImage,
    required this.date,
    required this.name,
    required this.rating,
    required this.distance,
    required this.postTitle,
  });
}

class Post extends StatefulWidget {
   final PostDataList post;
  const Post({super.key, required this.post});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  

   
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Add your click action here
        print('post clicked');
      },
      child: Container(
        margin: EdgeInsets.only(right: 10,
          left: 10,
          bottom: 20),
        height: 240,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2), // Shadow color with opacity
              spreadRadius: 2, // How far the shadow spreads
              blurRadius: 4, // How blurry the shadow appears
              offset: Offset(0, 0), // Offset of the shadow (x, y)
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(  
              child: Stack(
                children: [
                  Column(
                    children: [
                      //image
                      ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Image.network(
                            widget.post.postImage,
                            width: double.infinity,
                            height: 178, // Adjust image height
                            fit: BoxFit.cover,
                          ),
                        ),
            
                      //text
                      Container(
                        padding: EdgeInsets.only(top:5, right: 10, left: 75),
                        child: Expanded(
                          child: Row(
                            children: [
                              //name
                              FittedBox(
                                child: Text("${widget.post.name}",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                ),
                              ),
                              SizedBox(width: 12,),
                              Icon(
                                Icons.arrow_drop_down_circle_rounded,
                                color: Colors.black,
                                size: 4,
                              ),
                              SizedBox(width: 12,),
                              Icon(Icons.star,
                                color: const Color.fromARGB(255, 245, 185, 6),
                                size: 14,
                              ),
                              SizedBox(width: 5,),
                              FittedBox(
                                child: Text("${widget.post.rating}",
                                style: TextStyle(
                                    fontSize: 12,
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
                                child: Text("${widget.post.distance}",
                                  style: TextStyle(
                                    color: AppColors.secondaryColor,
                                    fontSize: 12
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
            
                      Container(
                        padding: EdgeInsets.only(left: 40.5, top: 3),
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          child: Text("${widget.post.postTitle}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                          ),
                          ),
                        ),
                      )
                    ],
                  ),
                  // date
                  Positioned(
                    top: 5,
                    right: 10,
                    child: Text(
                      "${widget.post.date}",
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
                ],
              ),
            ),
            //profile
            Positioned(
              bottom: 42.5,
              child: GestureDetector(
                onTap: () {
                  // Add your click action here
                  print('profile clicked');
                },
                child: Container(
                  margin: EdgeInsets.only(left: 18),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1000),
                      border: Border.all(
                        color: Colors.white, // You can change the color of the border here
                        width: 2, // Adjust the width of the border
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4), // Shadow color with opacity
                          offset: Offset(2, 1), // Shadow position (x, y)
                          blurRadius: 6, // Blur effect
                          spreadRadius: 1, // Spread effect
                        ),
                      ],
                    ),
                  child: ClipOval(
                    child:  Image.network(
                      '${widget.post.profileImage}',
                      height: 35,
                      width: 35,
                      fit: BoxFit.cover,
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