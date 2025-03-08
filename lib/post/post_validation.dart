import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/utilities/show_dialog.dart';
import 'package:donornet/services%20and%20provider/detect_image_labels_service.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

Future<bool> validateAndSubmitPost({
  required String imageUrl,
  required XFile? imageFile,
  required String title,
  required String description,
  required String category,
  required DateTime? pickupDate,
  required TimeOfDay? pickupTime,
  required DateTime? expiryDate,
  required TimeOfDay? expiryTime,
  required LatLng? location,
  required String task,
  required BuildContext context,
}) async {
  List<String> detectedLabels = [];

  // 1️⃣ Ensure at least one image is provided
  if ((imageUrl.isEmpty || imageUrl.trim() == "") && imageFile == null) {
    showErrorDialog(context, "Please provide an image");
    return false;
  }

  // 2️⃣ Validate Required Fields
  if (title.trim().isEmpty || 
      description.trim().isEmpty || 
      category.trim().isEmpty || 
      pickupDate == null || 
      pickupTime == null || 
      expiryDate == null || 
      expiryTime == null || 
      location == null) {
    showErrorDialog(context, "All fields are required. Please fill in all details.");
    return false;
  }

  // 3️⃣ Validate Image Size (≤ 1MB)
  if (imageFile != null) {
    File file = File(imageFile.path);
    int imageSize = await file.length();
    if (imageSize > 1024 * 1024) {
      showErrorDialog(context, "The image size is too large. Please upload an image less than 1MB.");
      return false;
    }
  }

  // 4️⃣ Validate Title Format
  final RegExp titleRegex = RegExp(r'^(?=(?:.*[a-zA-Z0-9]){3,})[a-zA-Z0-9\- ]+$');
  if (!titleRegex.hasMatch(title)) {
    showErrorDialog(context, "Invalid title. It must contain at least three letters or numbers and can only include spaces and '-'.");
    return false;
  }

  // 5️⃣ Validate Description Length
  if (description.length < 3) {
    showErrorDialog(context, "Description must be at least 3 characters long.");
    return false;
  }

  // 6️⃣ Check for Restricted Words
  List<String> restrictedWords = [
     'gun', 'weapon', 'knife', 'dagger', 'bomb', 'explosive', 'firearm', 'pistol', 'rifle', 'shotgun', 'ammunition', 'bullet', 'grenade', 'machete', 'sword', 'crossbow', 'taser', 'stun gun', 'baton', 'nunchaku', 'brass knuckles', 'pepper spray', 'tear gas', 'molotov', 'landmine', 'rocket launcher', 'missile', 'torpedo', 'silencer', 'assault rifle', 'sniper', 'illegal', 'contraband', 'counterfeit', 'forged', 'fraudulent', 'stolen', 'black market', 'smuggled', 'scam', 'fake id', 'human trafficking', 'prostitution', 'bribery', 'extortion', 'hijack', 'kidnap', 'ransom', 'embezzlement', 'hacking', 'cybercrime', 'money laundering', 'terrorism', 'gang', 'cartel', 'mafia', 'drug cartel', 'drugs', 'cocaine', 'heroin', 'meth', 
  'marijuana', 'weed', 'ecstasy', 'lsd', 'opioid', 'fentanyl', 'morphine', 'crystal meth', 'hashish', 'psychedelic', 'amphetamine', 'steroids', 'narcotic', 'ketamine', 'shrooms', 'pills', 'xanax', 'adderall', 'oxycontin', 'mdma', 'ghb', 'lean', 'codeine', 'opium', 'synthetic drugs', 'bath salts', 'dmt', 'methaqualone', 'herbal high', 'k2', 'spice', 'cough syrup abuse', 'alcohol', 'vodka', 'whiskey', 'rum', 'tequila', 'brandy', 'beer', 'wine', 'moonshine', 'cigarette', 'tobacco', 'vape', 'e-cigarette', 'cigar', 'hookah', 'shisha', 'rolling paper', 'nicotine', 'e-liquid', 'binge drinking', 'alcohol poisoning', 'drunk driving', 'poison', 'toxic', 'radioactive', 'hazardous', 'chemical weapon', 'bioweapon', 'cyanide', 'arsenic', 'mercury', 'lead', 'chloroform', 'asbestos', 'methanol', 'napalm', 'mustard gas', 'sarin', 'anthrax', 'ricin', 'nerve gas', 'plutonium', 'uranium', 'chainsaw', 'razor blade', 'shank', 'fist weapon', 'projectile', 'slingshot', 'explosive device', 'firework', 'torch', 'acid', 'flamethrower', 'spike', 'syringe', 'needle', 'sharp object', 'garrote', 'ballistic knife', 'bayonet', 'sex', 'porn', 'pornography', 'nude', 'naked', 'strip', 'stripper', 'escort', 'brothel', 'erotic', 'fetish', 'bdsm', 'bondage', 'orgy', 'masturbation', 'vibrator', 'dildo', 'adult toy', 'sex toy', 'explicit', 'xxx', 'hardcore', 'softcore', 'onlyfans', 'camgirl', 'cam model', 'webcam sex', 'incest', 'bestiality', 'child porn', 'cp', 'pedo', 'pedophile', 'underage sex', 'rape', 'molestation', 'abuse', 'sexual assault', 'prostitute', 'escort service', 'lingerie model', 'sugar daddy', 'sugar baby', 'sexting', 'lewd', 'hentai', 'smut', 'cam show', 'peeping tom', 'voyeur', 'flasher', 'exhibitionist', 'public indecency', 'revenge porn', 'grooming', 'non-consensual', 'date rape', 'groping', 'lewd act', 'voyeurism', 'self-harm', 'suicide', 'cutting', 'burning', 'choking', 'asphyxiation', 'bloodletting', 'scarring', 'pain olympics', 'hanging', 'overdose', 'torture', 'animal cruelty', 'cockfight', 'dogfight', 'child abuse', 'domestic violence', 'human sacrifice', 'organ harvesting', 'doxxing', 'blackmail', 'sextortion', 'cyberbullying', 'phishing', 'identity theft', 'dark web', 'illegal streaming', 'hacking tools', 'trojan', 'ransomware', 'deepfake porn', 'catfishing', 'scam site', 'malware', 'racial slur', 'hate speech', 'ethnic cleansing', 'genocide', 'supremacy', 'white power', 'nazi', 'kkk', 'neo-nazi', 'hate crime', 'bigotry', 'xenophobia', 'homophobia', 'transphobia', 'misogyny', 'sexist', 'credit card fraud', 'money mule', 'identity fraud', 'fake passport', 'fake visa', 'counterfeit currency', 'pyramid scheme', 'ponzi scheme', 'wire fraud', 'child labor', 'human smuggling', 'forced labor', 'underage exploitation', 'child soldier', 'orphans for sale', 'dog fighting', 'cock fighting', 'illegal betting', 'fixed match', 'race fixing', 'blood sport', 'black magic', 'voodoo', 'satanic ritual', 'fuck', 'witchcraft', 'milf', 'sorcery', 'cursed item', 'necromancy', 'bhanchod', 'gand', 'gandmar', 'chutiya', 'randi', 'madarchod', 'behenchod', 'lanat', 'kutti', 'bhenki', 'jhaant', 'chikni', 'gandu', 'patli gali', 'gaali', 'bakka', 'saala', 'madharchod', 'fake', 'banned', 'unauthorized', 'restricted', 'adult', 'intimate', 'sensual', 'lingerie', 'blood', 'sperm', 'organs', 'human tissue', 'plasma', 'bone marrow', 'medicine', 'weapons', 'explosives', 'hazardous materials', 'pussy', 'boobs', 'boob', 'dick', 'penis', 'vagina', 'clit', 'breasts', 'nipples', 'butt', 'ass', 'anus', 'cock', 'bitch', 'slut', 'whore', 'fucker', 'shit', 'bastard', 'cunt', 'nigga', 'nigger', 'chink', 'spic', 'fag', 'faggot', 'tranny', 'retard', 'gook', 'wetback', 'simp', 'thot', 'fuckboy', 'hoe', 'bussy', 'stfu', 'lmao', 'roast', 'yeet', 'lit', 'deadass', 'sus', 'cap', 'no cap', 'finna', 'clout', 'stan', 'cringe', 'slay', 'vibe check', 'slaps', 'capper', 'bae', 'fam', 'mc', 'bc', 'banger', 'skrrt', 'woke', 'cancelled', 'flamed', 'twerk', 'booty'
  ];

  bool containsRestrictedWords(String text) {
    String cleanText = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return restrictedWords.any((word) => cleanText.contains(word));
  }

  if (containsRestrictedWords(title) || containsRestrictedWords(description)) {
    showErrorDialog(context, "Your post contains prohibited content. Please review and edit.");
    return false;
  }

  // 7️⃣ Validate Pickup Date & Time
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime pickupDateOnly = DateTime(pickupDate.year, pickupDate.month, pickupDate.day);
  DateTime pickupDateTime = DateTime(
    pickupDate.year, pickupDate.month, pickupDate.day, pickupTime.hour, pickupTime.minute
  );

  if (pickupDateOnly.isBefore(today)) {
    showErrorDialog(context, "Pickup date cannot be in the past.");
    return false;
  }

  if (pickupDateOnly.isAtSameMomentAs(today) && pickupDateTime.isBefore(now)) {
    showErrorDialog(context, "Pickup time must be after the current time if pickup is today.");
    return false;
  }

  // 8️⃣ Validate Expiry Date & Time
  DateTime expiryDateTime = DateTime(
    expiryDate.year, expiryDate.month, expiryDate.day, expiryTime.hour, expiryTime.minute
  );

  Duration minGap = Duration(hours: 1);
  Duration maxGap = Duration(days: 30);
  Duration actualGap = expiryDateTime.difference(pickupDateTime);

  if (expiryDateTime.isBefore(pickupDateTime)) {
    showErrorDialog(context, "Expiry date and time must be after the pickup date and time.");
    return false;
  }

  if (actualGap < minGap) {
    showErrorDialog(context, "Expiry time must be at least 1 hour after pickup time.");
    return false;
  }

  if (actualGap > maxGap) {
    showErrorDialog(context, "Expiry time cannot be more than 30 days after pickup time.");
    return false;
  }

  // 9️⃣ Image Label Detection
  if (task == 'update') {
    if ((imageUrl.isNotEmpty && imageUrl.trim() != "") && imageFile != null) {
      print("❌ Both imageUrl and imageFile are provided. Only one should be used.");
      detectedLabels = await detectImageLabels(context, File(imageFile.path)); 
    } else {
      if ((imageUrl.isNotEmpty && imageUrl.trim() != "") && imageFile == null) {
        detectedLabels = await detectImageUrlLabels(context, imageUrl);
      } else if (imageFile != null) {
        detectedLabels = await detectImageLabels(context, File(imageFile.path)); 
      } else {
        showErrorDialog(context, "Please provide an image.");
        return false;
      }
    }
  } else {
    if (imageFile != null) {
      detectedLabels = await detectImageLabels(context, File(imageFile.path));
    } else {
      showErrorDialog(context, "Please provide an image.");
      return false;
    }
  }

  if (detectedLabels.isEmpty) {
    showErrorDialog(context, "Failed to analyze the image. Please try again.");
    return false;
  }

  // 🔟 Validate Category Match
  bool isMatch = await isCategoryMatch(context, detectedLabels, category);
  if (!isMatch) {
    showErrorDialog(context, "The uploaded image does not match the selected category.");
    return false;
  }

  // 1️⃣1️⃣ Validate Title with Image Labels
  bool titleMatch = isTitleMatch(title, detectedLabels);
  if (!titleMatch) {
    showErrorDialog(context, "The title should be relevant to the image content. Consider using words that best describe the image.\n\nSuggested keywords: $detectedLabels.");
    return false;
  }

  return true;
}

// ✅ Check if Title Matches Detected Labels
bool isTitleMatch(String title, List<String> detectedLabels) {
  String titleLower = title.toLowerCase().trim();

  for (String label in detectedLabels) {
    if (titleLower.contains(label)) {
      print("✅ Title matches detected label: $label");
      return true;
    }
  }

  print("❌ No match found between title and detected labels.");
  return false;
}

// ✅ Validate Category Match
Future<bool> isCategoryMatch(BuildContext context, List<String> detectedLabels, String categoryName) async {
  final firestore = FirebaseFirestore.instance;

  try {
    print("Fetching category ID for: $categoryName");

    QuerySnapshot categorySnapshot = await firestore
        .collection('category')
        .where('category_name', isEqualTo: categoryName)
        .get();

    if (categorySnapshot.docs.isEmpty) {
      print("Error: Category not found in database.");
      return false;
    }

    int categoryId = categorySnapshot.docs.first['categoryId'];  
    print("Category ID: $categoryId");

    QuerySnapshot keywordSnapshot = await firestore
        .collection('category_keywords')
        .where('category_id', isEqualTo: categoryId)
        .get();

    if (keywordSnapshot.docs.isEmpty) {
      print("No keywords found for category: $categoryName");
      return false;
    }

    List<String> categoryKeywords = keywordSnapshot.docs
        .expand((doc) => List<String>.from(doc['keywords']))
        .map((e) => e.toLowerCase().trim())
        .toList();

    return detectedLabels.any((label) =>
        categoryKeywords.any((keyword) => label.contains(keyword)));

  } catch (e) {
    print("Error while fetching category data: $e");
    return false;
  }
}


// Future<bool> validateAndSubmitPost({
//   required String  imageUrl,
//   required XFile? imageFile,
//   required String title,
//   required String description,
//   required String category,
//   required DateTime? pickupDate,
//   required TimeOfDay? pickupTime,
//   required DateTime? expiryDate,
//   required TimeOfDay? expiryTime,
//   required LatLng? location,
//   required String task,
//   required BuildContext context,
// }) async {

//   List<String> detectedLabels;

//   if ((imageUrl.isEmpty || imageUrl.trim() == "") && imageFile == null) {
//     showErrorDialog(context, "Please provide an image");
//     return false;
//   }

//   // 1️⃣ Validate Required Fields
//   if (title.trim().isEmpty || 
//       description.trim().isEmpty || 
//       category.trim().isEmpty || 
//       pickupDate == null || 
//       pickupTime == null || 
//       expiryDate == null || 
//       expiryTime == null || 
//       location == null) {
//     showErrorDialog(context, "All fields are required. Please fill in all details.");
//     return false;
//   }

//   // 2️⃣ Validate Image Size (Should be ≤ 1MB)
//   File file = File(imageFile!.path);
//   int imageSize = await file.length(); 
//   if (imageSize > 1024 * 1024) {
//     showErrorDialog(context, "The image size is too large. Please upload an image less than 1MB.");
//     return false;
//   }

//   final RegExp titleRegex = RegExp(r'^(?=(?:.*[a-zA-Z0-9]){3,})[a-zA-Z0-9\- ]+$');
//   if (!titleRegex.hasMatch(title)) {
//   showErrorDialog(context, "Invalid title. It must contain at least three letters or numbers and can only include spaces and '-'.");
//   return false;
//   }

//   // 3️⃣ **Validate Description (Min 3 characters)**
//   if (description.length < 3) {
//     showErrorDialog(context, "Description must be at least 3 characters long.");
//     return false;
//   }

//   // 3️⃣ Validate Title & Description (Advanced Restricted Word Check)
//   List<String> restrictedWords = [
//     'gun', 'weapon', 'knife', 'dagger', 'bomb', 'explosive', 'firearm', 'pistol', 'rifle', 'shotgun', 'ammunition', 'bullet', 'grenade', 'machete', 'sword', 'crossbow', 'taser', 'stun gun', 'baton', 'nunchaku', 'brass'];

//    bool containsRestrictedWords(String text) {
//     String cleanText = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
//     return restrictedWords.any((word) => cleanText.contains(word));
//   }

//   if (containsRestrictedWords(title) || containsRestrictedWords(description)) {
//     showErrorDialog(context, "Your post contains prohibited content. Please review and edit.");
//     return false;
//   }

//   // 4️⃣ Validate Pickup Date & Time 
//   DateTime now = DateTime.now();
//   DateTime today = DateTime(now.year, now.month, now.day);
//   DateTime pickupDateOnly = DateTime(pickupDate.year, pickupDate.month, pickupDate.day);
//   DateTime pickupDateTime = DateTime(
//     pickupDate.year, pickupDate.month, pickupDate.day, pickupTime.hour, pickupTime.minute
//   );

//   // Pickup date must not be in the past
//   if (pickupDateOnly.isBefore(today)) {
//     showErrorDialog(context, "Pickup date cannot be in the past.");
//     return false;
//   }

//   // If pickup is today, time must be in the future
//   if (pickupDateOnly.isAtSameMomentAs(today) && pickupDateTime.isBefore(now)) {
//     showErrorDialog(context, "Pickup time must be after the current time if pickup is today.");
//     return false;
//   }

//   // 5️⃣ Validate Expiry Date & Time (Must be after Pickup Time, with at least 1-hour gap, max 30 days)
//   DateTime expiryDateTime = DateTime(
//     expiryDate.year, expiryDate.month, expiryDate.day, expiryTime.hour, expiryTime.minute
//   );
  
//   Duration minGap = Duration(hours: 1);
//   Duration maxGap = Duration(days: 30);
//   Duration actualGap = expiryDateTime.difference(pickupDateTime);

//   if (expiryDateTime.isBefore(pickupDateTime)) {
//     showErrorDialog(context, "Expiry date and time must be after the pickup date and time.");
//     return false;
//   }

//   if (actualGap < minGap) {
//     showErrorDialog(context, "Expiry time must be at least 1 hour after pickup time.");
//     return false;
//   }

//   if (actualGap > maxGap) {
//     showErrorDialog(context, "Expiry time cannot be more than 30 days after pickup time.");
//     return false;
//   }

//   if(task == 'update'){
//     if ((imageUrl.isNotEmpty && imageUrl.trim() != "") && imageFile != null) {
//     print("❌ Both imageUrl and imageFile are provided. Only one should be used.");
//     detectedLabels = await detectImageLabels(context, file); 
//     }else{
//       if ((imageUrl.isNotEmpty && imageUrl.trim() != "") && imageFile == null) {
//         detectedLabels = await detectImageUrlLabels(context, imageUrl);
//       }else{
//         detectedLabels = await detectImageLabels(context, file); 
//       }
//     }
//   }else{
//     detectedLabels = await detectImageLabels(context, file);
//   }



// if (detectedLabels.isEmpty) {
//   showErrorDialog(context, "Failed to analyze the image. Please try again.");
//   return false;
// }

// bool isMatch = await isCategoryMatch(context, detectedLabels, category);

// if (!isMatch) {
//   showErrorDialog(context, "The uploaded image does not match the selected category.");
//   return false;
// }

// // Step 1️⃣: Check if the title matches any detected labels
// bool titleMatch = isTitleMatch(title, detectedLabels);
// if (!titleMatch) {
//   showErrorDialog(context, "The title should be relevant to the image content. Consider using words that best describe the image.\n\nSuggested keywords: $detectedLabels.");
//   return false;
// }


// return true;
// }

// bool isTitleMatch(String title, List<String> detectedLabels) {
//   String titleLower = title.toLowerCase().trim();

//   for (String label in detectedLabels) {
//     if (titleLower.contains(label)) {
//       print("✅ Title matches detected label: $label");
//       return true;
//     }
//   }

//   print("❌ No match found between title and detected labels.");
//   return false;
// }


// // Modify isCategoryMatch function
// Future<bool> isCategoryMatch(BuildContext context, List<String> detectedLabels, String categoryName) async {
//   final firestore = FirebaseFirestore.instance;

//   try {
//     print(" Fetching category ID for: $categoryName");

//     QuerySnapshot categorySnapshot = await firestore
//         .collection('category')
//         .where('category_name', isEqualTo: categoryName)
//         .get();

//     if (categorySnapshot.docs.isEmpty) {
//       print(" Error: Category not found in database.");
//       return false;
//     }

//     int categoryId = categorySnapshot.docs.first['categoryId'];  
//     print(" Category ID: $categoryId");

//     print(" Fetching keywords for category ID: $categoryId");
//     QuerySnapshot keywordSnapshot = await firestore
//         .collection('category_keywords')
//         .where('category_id', isEqualTo: categoryId)
//         .get();

//     if (keywordSnapshot.docs.isEmpty) {
//       print(" No keywords found for category: $categoryName");
//       return false;
//     }

//     List<String> categoryKeywords = keywordSnapshot.docs
//         .expand((doc) => List<String>.from(doc['keywords']))
//         .map((e) => e.toLowerCase().trim())
//         .toList();

//     print("Category Keywords: $categoryKeywords");

//     // Check if any detected label matches the category's keywords
//     bool isMatch = detectedLabels.any((label) =>
//         categoryKeywords.any((keyword) => label.contains(keyword)));

//     if (isMatch) {
//       print(" Match found! Image belongs to category: $categoryName");
//       return true;
//     }

//     print(" No match found. Image does not belong to category: $categoryName");
//     return false;
//   } catch (e) {
//     print(" Error while fetching category data: $e");
//     return false;
//   }
// }


//   // 6️⃣ Validate Image Against Category
//   bool isMatch = await detectImageMatchesCategory(context, file, category);
  
//   if (!isMatch) {
//     showErrorDialog(context, "The uploaded image does not match the selected category.");
//     return false;
//   }

//   return true;
// }

// Future<bool> isCategoryMatch(
//     BuildContext context, List<String> detectedLabels, String categoryName) async {
//   final firestore = FirebaseFirestore.instance;

//   try {
//     print("📌 Fetching category ID for: $categoryName");

//     QuerySnapshot categorySnapshot = await firestore
//         .collection('category')
//         .where('category_name', isEqualTo: categoryName)
//         .get();

//     if (categorySnapshot.docs.isEmpty) {
//       print("❌ Error: Category not found in database.");
//       showErrorDialog(context, "Category not found in database.");
//       return false;
//     }

//     // Extract category_id as an integer
//     int categoryId = categorySnapshot.docs.first['categoryId'];  
//     print("✅ Category ID: $categoryId");

//     print("📌 Fetching keywords for category ID: $categoryId");
//     QuerySnapshot keywordSnapshot = await firestore
//         .collection('category_keywords')
//         .where('category_id', isEqualTo: categoryId)
//         .get();

//     if (keywordSnapshot.docs.isEmpty) {
//       print("⚠️ No keywords found for category: $categoryName");
//       showErrorDialog(context, "No keywords found for category: $categoryName");
//       return false;
//     }

//     List<String> categoryKeywords = [];
//     for (var doc in keywordSnapshot.docs) {
//       categoryKeywords.addAll(
//         List<String>.from(doc['keywords'])
//             .map((e) => e.toLowerCase().trim()) // Ensure lowercase & trim spaces
//       );
//     }

//     print("✅ Category Keywords: $categoryKeywords");

//     // Check if any detected label matches the category's keywords (allows partial matching)
//     for (String detectedLabel in detectedLabels) {
//       if (categoryKeywords.any((keyword) => detectedLabel.contains(keyword))) {
//         print("🎯 Match found! Image belongs to category: $categoryName");
//         return true;
//       } else {
//         print("❌ No match for: $detectedLabel");
//       }
//     }

//     print("⚠️ No match found. Image does not belong to category: $categoryName");
//     return false;
//   } catch (e) {
//     print("❌ Error while fetching category data: $e");
//     showErrorDialog(context, "Error while fetching category data: $e");
//     return false;
//   }
// }
