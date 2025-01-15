
import 'package:flutter/material.dart';

Future<void> showerrorDialog(
  BuildContext context, 
  String text,
){
  return showDialog(
    context: context, builder: (context) {
      return AlertDialog(
        title: const Text('An Error'),
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
