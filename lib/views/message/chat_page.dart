import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/user_service.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/views/message/MessageBoxScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> chatList = [];
  bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  Future<void> fetchChats() async {
    try {
      List<Map<String, dynamic>> chats = await UserService().getUserChats();
      setState(() {
        chatList = chats;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching chats: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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
      backgroundColor: const Color.fromARGB(255, 209, 234, 223),

      body:isLoading
          ? LoadingIndicator(isLoading: true) // Show loading indicator
          : chatList.isEmpty
              ? Center(child: Text("No chats available")) // Show if no chats found
              : ListView.builder(
                  padding: EdgeInsets.only(top: 15),
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                      chatData: chatList[index], // Pass the full chat data to MessageTile
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




class MessageTile extends StatelessWidget {
  final Map<String, dynamic> chatData;

  MessageTile({required this.chatData});


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageBoxScreen(
              chatId: chatData['chatId'],
              postId: chatData['post_id'],
              postOwnerId: chatData['post_owner_id'],
            ),
          ),
        );
      },
      child: Stack(
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
                        chatData['image_url'],
                        width: 120,
                        height: 90,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(width: 120, height: 90,  color: const Color.fromARGB(255, 195, 195, 195), child: Icon(Icons.image, size: 22, color: const Color.fromARGB(255, 110, 110, 110),));
                      },
                        errorBuilder: (context, error, stackTrace) {
                           return Container(width: 120, height: 90,  color: const Color.fromARGB(255, 195, 195, 195), child: Icon(Icons.image, size: 22, color: const Color.fromARGB(255, 110, 110, 110),));
                        },
                      ),
                    ),
      
                    if ( chatData['status'] == 'claimed')
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
                          child: chatData['profile_image']  == null
                              ? CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey,
                                  child: Icon(Icons.person, color: Colors.white, size: 25),
                                )
                              : Image.network(
                                  chatData['profile_image'] ,
                                  width: 30,
                                  height: 30,
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
                      )
      
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
                        "${chatData['first_name'] ?? 'Unknown'} ${chatData['last_name'] ?? ''}".trim(),
                        style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      SizedBox(height: 0,),
      
                      Text(
                        chatData['title'] ?? 'No Title',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
      
                      SizedBox(height: 5,),
      
                      Text(
                        chatData['last_message'] ?? 'No messages yet',
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
              (chatData['last_message_time'] is Timestamp)
                  ? DateFormat('d MMM').format((chatData['last_message_time'] as Timestamp).toDate())
                  : "N/A", // Fallback text in case of error
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}