import 'package:flutter/material.dart';

class MessageBoxScreen extends StatefulWidget {
  const MessageBoxScreen({super.key, required profileImage, required itemImage, required ownerName, required postTitle, required lastMessage, required lastMessageDate, required claimed});

  @override
  State<MessageBoxScreen> createState() => _MessageBoxScreenState();
}

class _MessageBoxScreenState extends State<MessageBoxScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}