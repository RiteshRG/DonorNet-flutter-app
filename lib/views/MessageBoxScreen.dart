import 'package:flutter/material.dart';
import 'package:donornet/materials/app_colors.dart';

class MessageBoxScreen extends StatefulWidget {
  final String? profileImage;
  final String itemImage;
  final String ownerName;
  final String postTitle;
  final String lastMessage;
  final String lastMessageDate;
  final String status;

  MessageBoxScreen({
    required this.profileImage,
    required this.itemImage,
    required this.ownerName,
    required this.postTitle,
    required this.lastMessage,
    required this.lastMessageDate, 
    required this.status,
  });

  @override
  _MessageBoxScreenState createState() => _MessageBoxScreenState();
}

class _MessageBoxScreenState extends State<MessageBoxScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> messages = [];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      messages.add({
        "message": _messageController.text.trim(),
        "sender": "user",
      });
      _messageController.clear();
    });
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
            title: Row(
              children: [
               ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: (widget.profileImage == null )
                    ? CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      )
                    : Image.network(
                        widget.profileImage!,
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white, size: 30),
                          );
                        },
                      ),
              ),
          
                SizedBox(width: 15),
                Text(
                  widget.ownerName,
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
                    widget.postTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 126, 126, 126)),
                     overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                  ),
                ),
                SizedBox(width: 20,),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.itemImage,
                    width: 70,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.image, color: Colors.grey, size: 40),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          // Expanded(
          //   child: ListView.builder(
          //     padding: EdgeInsets.all(10),
          //     itemCount: messages.length,
          //     itemBuilder: (context, index) {
          //       final message = messages[index];
          //       final isSender = message["sender"] == "user";
          //       return Align(
          //         alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          //         child: Container(
          //           margin: EdgeInsets.symmetric(vertical: 5),
          //           padding: EdgeInsets.all(12),
          //           decoration: BoxDecoration(
          //             color: isSender ? AppColors.primaryColor : Colors.grey.shade300,
          //             borderRadius: BorderRadius.only(
          //               topLeft: Radius.circular(20),  
          //               topRight: Radius.circular(3),  
          //               bottomLeft: Radius.circular(20),  
          //               bottomRight: Radius.circular(20),  
          //             ),
          //           ),
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start, // Align text to left
          //             children: [
          //               Text(
          //                 message["message"]!,
          //                 style: TextStyle(
          //                   color: isSender ? Colors.white : Colors.black,
          //                   fontSize: 16, 
          //                 ),
          //               ),
          //               SizedBox(height: 5),// Space between text and timestamp
          //               Text(
          //                 "12:30 PM · 09 Feb 2025", // Replace with actual date & time
          //                 style: TextStyle(
          //                   color: isSender ? Colors.white70 : Colors.black54, 
          //                   fontSize: 12, 
          //                 ),

          //               ),
          //             ],
          //           ),
          //         )


          //       );
          //     },
          //   ),
          // ),
          Expanded(
  child: ListView(
    padding: EdgeInsets.all(10),
    children: [
      // Recipient Message (You) - Now on the Left
      
      // Donor Message - Now on the Right
      Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),  
              topRight: Radius.circular(3),  
              bottomLeft: Radius.circular(20),  
              bottomRight: Radius.circular(20),  
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi! Are you giving away a warm blanket?",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "08:33 AM · 09 Feb 2025",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),

      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(228, 38, 182, 122), // Your primary color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(3),  
              topRight: Radius.circular(20),  
              bottomLeft: Radius.circular(20),  
              bottomRight: Radius.circular(20),  
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Yes, I have one available.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "08:33 AM · 09 Feb 2025",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),


      // Recipient Message (You) - Now on the Left
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(228, 38, 182, 122),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(3),  
              topRight: Radius.circular(20),  
              bottomLeft: Radius.circular(20),  
              bottomRight: Radius.circular(20),  
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You can come at 6 PM. Does that work for you?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "08:33 AM · 09 Feb 2025",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),

      Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),  
              topRight: Radius.circular(3),  
              bottomLeft: Radius.circular(20),  
              bottomRight: Radius.circular(20),  
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "yes",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "08:33 AM · 09 Feb 2025",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),

      // Donor Message - Now on the Right
      Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),  
              topRight: Radius.circular(3),  
              bottomLeft: Radius.circular(20),  
              bottomRight: Radius.circular(20),  
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Thank you so much for sharing",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "06:33 PM · 09 Feb 2025",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),

      
    ],
  ),
),


          Padding(
            padding: EdgeInsets.all(8),
            child: widget.status == 'claimed'
                ? Stack(
              children: [
                // Container(
                //   width: double.infinity,
                //   padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: [
                //         const Color.fromARGB(255, 1, 65, 69),
                //         const Color.fromARGB(255, 0, 95, 25)
                //       ],
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //     ),
                //     borderRadius: BorderRadius.circular(12),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black26,
                //         blurRadius: 6,
                //         spreadRadius: 2,
                //         offset: Offset(2, 3),
                //       ),
                //     ],
                //   ),
                //   child: Text(
                //     "Claimed",
                //     style: TextStyle(
                //       fontSize: 18,
                //       color: Colors.white,
                //       fontWeight: FontWeight.bold,
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
                // ),

                Container(height: 180,),

                Positioned(
                  bottom: -40, 
                  left: -20, 
                  child: Transform.rotate(
                    angle: 0.4, 
                    child: Opacity(
                      opacity: 0.5, 
                      child: Image.network(
                        "https://i.postimg.cc/TYNP2Qqy/wmremove-transformed-removebg-preview.png",
                        width: 200, 
                        height: 200, 
                        fit: BoxFit.cover,
                      ),
                    )
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
                          onPressed: _sendMessage,
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


