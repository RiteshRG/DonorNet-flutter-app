import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageCard extends StatelessWidget {
  final Map<String, dynamic> message;
  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String msgText = message['message'] ?? "";
    String senderId = message['sender_id'] ?? "";
    Timestamp ts = message['sent_at'] ?? Timestamp.now();
    DateTime sentTime = ts.toDate();
    String formattedTime = DateFormat("hh:mm a · dd MMM yyyy").format(sentTime);
    bool isMe = senderId == FirebaseAuth.instance.currentUser!.uid;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isMe ?Colors.grey.shade300 : const Color.fromARGB(228, 38, 182, 122),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msgText,
              style: TextStyle(
                color: isMe ? Colors.black  : Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              formattedTime,
              style: TextStyle(
                color: isMe ?  Colors.black  : Colors.white,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}