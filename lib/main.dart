import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/user_provider.dart';
import 'package:donornet/views/authentication/email_verification_page.dart';
import 'package:donornet/views/home%20page/home.dart';
import 'package:donornet/views/authentication/login_page.dart';
import 'package:donornet/views/authentication/registration_page.dart';
import 'package:donornet/views/authentication/resetPassword.dart';
import 'package:donornet/views/authentication/verification.dart';
import 'package:donornet/views/authentication/welcome_page.dart';
import 'package:donornet/views/add_item_page.dart';
import 'package:donornet/views/message_room.dart';
import 'package:donornet/views/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

 runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()..fetchUserDetails()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  get loginRoute => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DonorNet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
       home: const WelcomePageSelector(),
      //home: ChatPage(),
      routes: {
        'welcomePageRoute': (context) => WelcomePage(),
        'loginRoute': (context) => Login(),
        'registerRoute': (context) => Register(),
        'verificationRoute': (context) => Verification(),
        'emailVerificationRoute': (context) => EmailVerificationPage(),
        'ResetPasswordPageRoute': (context) => ResetPasswordPage(email: '',),
        'homePageRoute': (context) => HomePage(),
        'addItemPageRoute': (context) => AddItemPage(),
        'chatPageRoute': (context) =>ChatPage(),
        'myProfilePageRoute': (context) => Profile_page()
      },
    );
  }
}


class WelcomePageSelector extends StatelessWidget {
  const WelcomePageSelector({super.key});

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool firstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (firstLaunch) {
      // Mark as not first launch after showing onboarding
      await prefs.setBool('isFirstLaunch', false);
    }
    return firstLaunch;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isFirstLaunch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),strokeWidth: 6,)),
          );
        } else {
          final bool firstLaunch = snapshot.data ?? true;
          if (firstLaunch) {
            return const WelcomePage(); 
          } else {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                return const HomePage(); 
              } else {
                return const Verification(); 
              }
            } else {
              return const Login(); 
            }
          }
        }
      },
    );
  }
}