import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/services%20and%20provider/post_service.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/utilities/shimmer_loading.dart';
import 'package:donornet/views/message/message_card.dart';
import 'package:donornet/views/post%20details/post_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:donornet/materials/app_colors.dart';
import 'dart:developer' as devtools;

class MessageBoxScreen extends StatefulWidget {
  final String? chatId; // May be null if no chat exists yet.
  final String postId;
  final String postOwnerId;

  const MessageBoxScreen({
    Key? key,
    this.chatId,
    required this.postId,
    required this.postOwnerId,
  }) : super(key: key);

  @override
  _MessageBoxScreenState createState() => _MessageBoxScreenState();
}

class _MessageBoxScreenState extends State<MessageBoxScreen> {
  List<Map<String, dynamic>> postsAndUserData = [];
  String title = "";
  String profile = "";
  String imageUrl = "";
  String userName = "";
  String status = "";
  DateTime? expiryDate;
  DateTime? pickUpDate;
  bool isLoading = true;
  bool _isCreatingChat = false;
  String? _chatId;

  late final TextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _fetchData();

    if (widget.chatId != null) {
      _chatId = widget.chatId!;
    } else {
      _createChatForPost();
    }

    _updateFcmToken();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetches post and user details
  Future<void> _fetchData() async {
    try {
      postsAndUserData = await PostService().getPostWithUserDetails(widget.postId);
      if (postsAndUserData.isNotEmpty) {
        var postData = postsAndUserData.first;

        setState(() {
          title = postData['post']['title'] ?? "No Title";
          pickUpDate = (postData['post']['pickup_date_time'] as Timestamp?)?.toDate();
          expiryDate = (postData['post']['expiry_date_time'] as Timestamp?)?.toDate();
          imageUrl = postData['post']['image_url'] ?? "";
          userName = "${postData['user']['first_name'] ?? ''} ${postData['user']['last_name'] ?? ''}".trim();
          profile = postData['user']['profile_image'] ?? "";
          status = postData['post']['status'] ?? "";
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, stacktrace) {
      devtools.log("Error fetching post details: $e", stackTrace: stacktrace);
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar("Failed to fetch post details.");
    }
  }

  /// Creates a chat document in Firestore
  Future<void> _createChatForPost() async {
    setState(() {
      _isCreatingChat = true;
    });

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception("User not authenticated");
      }

      DocumentReference chatDocRef = FirebaseFirestore.instance.collection('chats').doc();
      _chatId = chatDocRef.id;

      await chatDocRef.set({
        'chatId': _chatId,
        'post_id': widget.postId,
        'post_owner_id': widget.postOwnerId,
        'participants': [currentUserId],
        'last_message': '',
        'last_message_time': null,
      });

    } catch (e, stacktrace) {
      devtools.log("Error creating chat: $e", stackTrace: stacktrace);
      _showErrorSnackBar("Failed to create chat.");
    } finally {
      setState(() {
        _isCreatingChat = false;
      });
    }
  }

  /// Updates FCM token for push notifications
  Future<void> _updateFcmToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({'fcmToken': token});
    } catch (e, stacktrace) {
      devtools.log("Error updating FCM token: $e", stackTrace: stacktrace);
    }
  }

  /// Returns a stream of messages in a chat
  Stream<QuerySnapshot> getMessagesStream() {
    if (_chatId == null) {
      devtools.log("Chat ID is null, cannot fetch messages.");
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .orderBy('sent_at', descending: false)
        .snapshots();
  }

  /// Sends a message to Firestore
  Future<void> _sendMessage() async {
    devtools.log("In _sendMessage");

    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;
    _messageController.clear();

    try {
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception("User not authenticated");
      }
      if (_chatId == null) {
        throw Exception("Chat ID is null");
      }

      CollectionReference messagesRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages');

      await messagesRef.add({
        'chatId': _chatId,
        'sender_id': currentUserId,
        'message': messageText,
        'sent_at': FieldValue.serverTimestamp(),
      });

      // Update chat document metadata
      await FirebaseFirestore.instance.collection('chats').doc(_chatId).update({
        'last_message': messageText,
        'last_message_time': FieldValue.serverTimestamp(),
      });

    } catch (e, stacktrace) {
      devtools.log("Error sending message: $e", stackTrace: stacktrace);
      _showErrorSnackBar("Failed to send message.");
    }
  }

  /// Shows a snackbar with an error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Stack(
        children: [
          messagePagebuildShimmerLayout(),
          LoadingIndicator(isLoading: true),
        ],
      );
      //return messagePagebuildShimmerLayout();
    }

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
            title: Row(
              children: [
               Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: (profile == "")
                      ? CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        )
                      : Image.network(
                          profile,
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white, size: 30),
                            );
                          },
                        ),
                ),
              ),

          
                SizedBox(width: 15),
                Text(
                 userName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top:16, bottom:13, right:20, left:20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 126, 126, 126)),
                     overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                  ),
                ),
                SizedBox(width: 20,),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PostDetailsPage(widget.postId)),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        width: 70,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.image, color: Colors.grey, size: 40),
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text("Error loading messages"));
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return Center(child: Text("No messages yet."));
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> msgData = docs[index].data() as Map<String, dynamic>;
                    return MessageCard(message: msgData);
                  },
                );
              },
            ),
          ),

          //Expanded(all message display........)

          Padding(
            padding: EdgeInsets.all(8),
            child: status != 'available'
                ? Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 4, 171, 183),
                        const Color.fromARGB(255, 1, 133, 36)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        spreadRadius: 2,
                        offset: Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    "Claimed",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )

                : Row( 
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.grey, width: 2),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.tertiaryColor, AppColors.primaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed:_sendMessage,
                        ),
                      )
                    ],
                  ),
          )

        ],
      ),
    );
  }
}







//           Expanded(
//   child: ListView(
//     padding: EdgeInsets.all(10),
//     children: [
//       // Recipient Message (You) - Now on the Left
      
//       // Donor Message - Now on the Right
//       Align(
//         alignment: Alignment.centerRight,
//         child: Container(
//           margin: EdgeInsets.symmetric(vertical: 5),
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),  
//               topRight: Radius.circular(3),  
//               bottomLeft: Radius.circular(20),  
//               bottomRight: Radius.circular(20),  
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Hi! Are you giving away a warm blanket?",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                 ),
//               ),
//               SizedBox(height: 5),
//               Text(
//                 "08:33 AM · 09 Feb 2025",
//                 style: TextStyle(
//                   color: Colors.black54,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),

//       Align(
//         alignment: Alignment.centerLeft,
//         child: Container(
//           margin: EdgeInsets.symmetric(vertical: 5),
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: const Color.fromARGB(228, 38, 182, 122), // Your primary color
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(3),  
//               topRight: Radius.circular(20),  
//               bottomLeft: Radius.circular(20),  
//               bottomRight: Radius.circular(20),  
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Yes, I have one available.",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                 ),
//               ),
//               SizedBox(height: 5),
//               Text(
//                 "08:33 AM · 09 Feb 2025",
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),


//       // Recipient Message (You) - Now on the Left
//       Align(
//         alignment: Alignment.centerLeft,
//         child: Container(
//           margin: EdgeInsets.symmetric(vertical: 5),
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: const Color.fromARGB(228, 38, 182, 122),
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(3),  
//               topRight: Radius.circular(20),  
//               bottomLeft: Radius.circular(20),  
//               bottomRight: Radius.circular(20),  
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "You can come at 6 PM. Does that work for you?",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                 ),
//               ),
//               SizedBox(height: 5),
//               Text(
//                 "08:33 AM · 09 Feb 2025",
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),

//       Align(
//         alignment: Alignment.centerRight,
//         child: Container(
//           margin: EdgeInsets.symmetric(vertical: 5),
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),  
//               topRight: Radius.circular(3),  
//               bottomLeft: Radius.circular(20),  
//               bottomRight: Radius.circular(20),  
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "yes",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                 ),
//               ),
//               SizedBox(height: 5),
//               Text(
//                 "08:33 AM · 09 Feb 2025",
//                 style: TextStyle(
//                   color: Colors.black54,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),

//       // Donor Message - Now on the Right
//       Align(
//         alignment: Alignment.centerRight,
//         child: Container(
//           margin: EdgeInsets.symmetric(vertical: 5),
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),  
//               topRight: Radius.circular(3),  
//               bottomLeft: Radius.circular(20),  
//               bottomRight: Radius.circular(20),  
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Thank you so much for sharing",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                 ),
//               ),
//               SizedBox(height: 5),
//               Text(
//                 "06:33 PM · 09 Feb 2025",
//                 style: TextStyle(
//                   color: Colors.black54,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),

      
//     ],
//   ),
// ),

