
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

void showSuccessDialog(BuildContext context, String text) {
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
              Navigator.of(context).pop(); // Close the dialog
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
