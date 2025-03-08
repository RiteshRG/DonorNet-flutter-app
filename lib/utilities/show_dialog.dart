
import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('An Error'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            }, 
            child: const Text('OK',
            style: TextStyle(color: AppColors.primaryColor),),
          ),
        ],
      );
    },
  );
}

void showExpiryDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero, // Remove default padding
        backgroundColor: Colors.transparent, // Make dialog background transparent
        content: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.tertiaryColor], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Post Expired",
                style: TextStyle(
                  color: Colors.white, // White text
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "This post is no longer available as it has already expired.",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom( // Button background
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


showSuccessDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.primaryColor, // Set background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Column(
          children: [
            Image.network(
              "https://i.postimg.cc/bwbd6kks/logo.png",
              height: 50,
              width: 50,
            ),
            SizedBox(height: 10),
            Text(
              "Success",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "${text}",
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('homePageRoute', (route) => false,);
            },
            child: Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}



Future<void> permissionDialog(
  BuildContext context, 
  String text,
){
  return showDialog(
    context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Allow Permission'),
        content: Text(text),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: const Text('OK')),
        ],
      );
    },
  );
}
