
import 'package:donornet/materials/access_throught_link.dart';
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



void showLevelUpPopup(BuildContext context, int level) {
  String message = getLevelUpMessage(level);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismiss by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Prevent unnecessary space
            children: [
              Image.network(
                AccessLink.getLevelImage(level), // Fetch image from URL
                height: 120, 
                width: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.auto_graph_outlined, size: 100, color:AppColors.primaryColor); 
                },
              ),
              const SizedBox(height: 15),
              Text(
                "Congratulations!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  });
}



String getLevelUpMessage(int level) {
  if (level == 1) return "Great start! You've reached Level 1! 🎯";
  if (level == 2) return "You're making a difference! Level 2 unlocked! 🌍";
  if (level == 3) return "Amazing! You're now at Level 3! Keep going! 💪";
  if (level == 4) return "Incredible! Level 4 achieved! 🌟";
  if (level == 5) return "Halfway there! Level 5 unlocked! 🚀";
  if (level == 6) return "You're unstoppable! Welcome to Level 6! ⚡";
  if (level == 7) return "Legendary! You've reached Level 7! 🏆";
  if (level == 8) return "A true hero! Level 8 unlocked! 🎖";
  if (level == 9) return "Superstar! You're now at Level 9! ✨";
  if (level == 10) return "Ultimate Donor! Level 10 achieved! 🔥";
  return "You've leveled up! Keep making an impact! 🎉";
}