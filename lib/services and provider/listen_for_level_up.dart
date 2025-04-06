import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/main.dart';
import 'package:donornet/materials/access_throught_link.dart';
import 'package:donornet/utilities/show_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as devtools;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools;


class LevelMemory {
  static final Map<String, int> _tempLevels = {};

  static int getTempLevel(String userId) => _tempLevels[userId] ?? 0;

  static void setTempLevel(String userId, int level) {
    _tempLevels[userId] = level;
  }

  static void clearTempLevel(String userId) {
    _tempLevels.remove(userId);
  }

  static void clearAll() {
    _tempLevels.clear();
  }
}

void listenForLevelUp(BuildContext context, String userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    int lastKnownLevel = prefs.getInt('last_level_$userId') ?? 0;

    // Initialize temp from shared preferences (or wherever)
    LevelMemory.setTempLevel(userId, lastKnownLevel);

    devtools.log(" Listening for real-time level updates for: $userId");

    FirebaseFirestore.instance
        .collection('levels')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        var levelDoc = querySnapshot.docs.first;
        int currentLevel = levelDoc['level'] ?? 0;
        int temp = LevelMemory.getTempLevel(userId);

        devtools.log(" currentLevel: $currentLevel | lastKnown: $lastKnownLevel | temp: $temp");

        if (currentLevel > 0 && temp > 0 && lastKnownLevel < currentLevel) {
          devtools.log("🎉 Real-Time First Level Up: $temp ➝ $currentLevel");

          BuildContext? currentContext = navigatorKey.currentContext;
          if (context.mounted) {
            showLevelUpPopup(currentContext!, currentLevel);
          }
        }

        // Update persistent storage
        await prefs.setInt('last_level_$userId', currentLevel);
        lastKnownLevel = currentLevel;

        // Also update temp in memory
        LevelMemory.setTempLevel(userId, currentLevel);
      } else {
        devtools.log(" No level document found for real-time listener.");
      }
    }, onError: (error) {
      devtools.log("Firestore stream error: $error");
    });
  } catch (e) {
    devtools.log("Error initializing level listener: $e");
  }
}


Future<void> clearUserLevelData(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('last_level_$userId');
  LevelMemory.clearTempLevel(userId);
  devtools.log("Cleared stored and temp level data for user: $userId");
}



// void listenForLevelUp(BuildContext context, String userId) async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     int lastKnownLevel = prefs.getInt('last_level_$userId') ?? 0;
//     int temp = lastKnownLevel;

//     devtools.log("👂 Listening for real-time level updates for: $userId");

//     FirebaseFirestore.instance
//         .collection('levels')
//         .where('user_id', isEqualTo: userId)
//         .snapshots()
//         .listen((querySnapshot) async {
//       if (querySnapshot.docs.isNotEmpty) {
//         var levelDoc = querySnapshot.docs.first;
//         int currentLevel = levelDoc['level'] ?? 0;

//         devtools.log("🟢 currentLevel Level: $currentLevel | Last Known Level: $lastKnownLevel | temp = $temp");

//         if (currentLevel > 0 && temp >0 && lastKnownLevel<currentLevel) { 
//           devtools.log("🎉 Real-Time First Level Up: 0 ➝ $currentLevel");

//            BuildContext? currentContext = navigatorKey.currentContext;

//           if (context.mounted) {
//             showLevelUpPopup(currentContext!, currentLevel);
//           }
//         }

//         await prefs.setInt('last_level_$userId', currentLevel);
//         lastKnownLevel = prefs.getInt('last_level_$userId') ?? 0;
//          devtools.log("prefs currentLevel Level: $currentLevel | Last Known Level: $lastKnownLevel");
//       } else {
//         devtools.log("⚠️ No level document found for real-time listener.");
//       }
//     }, onError: (error) {
//       devtools.log("❌ Firestore stream error: $error");
//     });
//   } catch (e) {
//     devtools.log("❌ Error initializing level listener: $e");
//   }
// }

// // Function to clear stored level data when a user logs out
// Future<void> clearStoredLevelData() async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.clear(); // Clears all stored preferences
//   devtools.log("Cleared stored level data on logout.");
// }

// // Alternative: Remove only the specific user's level data instead of clearing all preferences
// Future<void> clearUserLevelData(String userId) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.remove('last_level_$userId');
//   devtools.log("Cleared stored level data for user: $userId");
// }





// 🎉 Function to show the Level-Up Popup

