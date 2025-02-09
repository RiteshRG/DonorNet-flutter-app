import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/views/MessageBoxScreen.dart';
import 'package:flutter/material.dart';

// MessageTile class to represent each message tile
class MessageTile extends StatelessWidget {
  final String profileImage;
  final String itemImage;
  final String ownerName;
  final String postTitle;
  final String lastMessage;
  final String lastMessageDate;
  final bool claimed;

  MessageTile({
    required this.profileImage,
    required this.itemImage,
    required this.ownerName,
    required this.postTitle,
    required this.lastMessage,
    required this.lastMessageDate,
    required this.claimed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Donation Item Image with Profile Image on Top-Left
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      itemImage,
                      width: 120,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(Icons.image, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  if (!claimed)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor, // Red background color
                              borderRadius: BorderRadius.circular(10), // Border radius of 20
                            ),
                            child: Text(
                              "Claimed",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Positioned Profile Image in Top-Left Corner
                  Positioned(
                    top: -10,
                    left: -10,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      border: Border.all(
                        color: AppColors.primaryColor, // White border color
                        width: 1, // Border width
                      ),
                    ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          profileImage,
                          width: 25,
                          height: 25,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white, size: 25),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Positioned Date in Top Right Corner
                ],
              ),
              SizedBox(width: 10),
        
              // Message Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ownerName,
                      style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 0, 0, 0)),
                    ),
                    SizedBox(height: 0,),
                    Text(
                      postTitle,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 8,),
                    Text(
                      lastMessage,
                      style: TextStyle(fontSize: 14, color: AppColors.secondaryColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 15,
          right: 23,
          child: Text(
            lastMessageDate,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

// Stateful widget to display the list of message tiles with same data for each tile
class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Same static data for all tiles
  final List<Map<String, dynamic>> messageData = [
    {
      'profileImage': 'https://i.pinimg.com/originals/83/bc/8b/83bc8b88cf6bc4b4e04d153a418cde62.jpg',
      'itemImage': 'https://collectmyclothes.co.uk/wp-content/uploads/2019/11/donation.jpg',
      'ownerName': 'Jason',
      'postTitle': 'cloths',
      'lastMessage': 'Thanks for your help!',
      'lastMessageDate': 'Feb 8',
      'claimed': true,
    },
    {
      'profileImage': 'https://i.pinimg.com/originals/83/bc/8b/83bc8b88cf6bc4b4e04d153a418cde62.jpg',
      'itemImage': 'https://collectmyclothes.co.uk/wp-content/uploads/2019/11/donation.jpg',
      'ownerName': 'John',
      'postTitle': 'Winter',
      'lastMessage': 'Thanks for your help!',
      'lastMessageDate': 'Feb 8',
      'claimed': false ,
    },
    {
      'profileImage': 'https://i.pinimg.com/originals/83/bc/8b/83bc8b88cf6bc4b4e04d153a418cde62.jpg',
      'itemImage': 'https://collectmyclothes.co.uk/wp-content/uploads/2019/11/donation.jpg',
      'ownerName': 'Doe',
      'postTitle': 'Jacket',
      'lastMessage': 'Thanks for your help!',
      'lastMessageDate': 'Feb 8',
      'claimed': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.tertiaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Text(
              'Chat',
              style: TextStyle(
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            elevation: 5,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.white), // Set the back arrow icon color to white
          ),
        ),
      ),

      body: ListView.builder(
        padding: EdgeInsets.only(top:15),
        itemCount: 3, // We want 3 identical message tiles
        itemBuilder: (context, index) {
          final message = messageData[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageBoxScreen(
                    profileImage: message['profileImage'],
                    itemImage: message['itemImage'],
                    ownerName: message['ownerName'],
                    postTitle: message['postTitle'],
                    lastMessage: message['lastMessage'],
                    lastMessageDate: message['lastMessageDate'],
                    claimed: message['claimed'],
                  ),
                ),
              );
            },
            child: MessageTile(
              profileImage: message['profileImage'],
              itemImage: message['itemImage'],
              ownerName: message['ownerName'],
              postTitle: message['postTitle'],
              lastMessage: message['lastMessage'],
              lastMessageDate: message['lastMessageDate'],
              claimed: message['claimed'],
            ),
          );
        },
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
        currentIndex: 3, // Set initial index
          onTap: (index) {
            if(index == 2){
               Navigator.of(context).pushNamed('addItemPageRoute');
            }
            if(index == 4){
               Navigator.of(context).pushNamed('myProfilePageRoute');
            }
            if(index == 0){
             Navigator.of(context).pushNamedAndRemoveUntil(
                'homePageRoute', 
                (Route<dynamic> route) => false,  // This will remove all previous routes
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
