import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/listen_for_level_up.dart';
import 'package:donornet/services%20and%20provider/user_provider.dart';
import 'package:donornet/views/authentication/email_verification_page.dart';
import 'package:donornet/views/confirm_claim_page.dart';
import 'package:donornet/views/filter.dart';
import 'package:donornet/views/home%20page/home.dart';
import 'package:donornet/views/authentication/login_page.dart';
import 'package:donornet/views/authentication/registration_page.dart';
import 'package:donornet/views/authentication/resetPassword.dart';
import 'package:donornet/views/authentication/verification.dart';
import 'package:donornet/views/authentication/welcome_page.dart';
import 'package:donornet/views/add_item_page.dart';
import 'package:donornet/views/message/chat_page.dart';
import 'package:donornet/views/levels/my_level_page.dart';
import 'package:donornet/views/map_page.dart';
import 'package:donornet/views/my_account_page.dart';
import 'package:donornet/views/post%20details/post_details_page.dart';
import 'package:donornet/views/post%20details/User_post_details.dart';
import 'package:donornet/views/profile/profile_page.dart';
import 'package:donornet/views/qr_code_page.dart';
import 'package:donornet/views/rating_page.dart';
import 'package:donornet/views/search/search_page.dart';
import 'package:donornet/views/search/search_post_page.dart';
import 'package:donornet/services%20and%20provider/detect_image_labels_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    // ✅ Listen for user authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        devtools.log('************########');
        
        // ✅ Use navigatorKey.currentContext instead of passing context
        BuildContext? currentContext = navigatorKey.currentContext;
        if (currentContext != null && currentContext.mounted) {
          listenForLevelUp(currentContext, user.uid);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DonorNet',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomePageSelector(),
      routes: {
        'welcomePageRoute': (context) => WelcomePage(),
        'loginRoute': (context) => Login(),
        'registerRoute': (context) => Register(),
        'verificationRoute': (context) => Verification(),
        'emailVerificationRoute': (context) => EmailVerificationPage(),
        'ResetPasswordPageRoute': (context) => ResetPasswordPage(email: ''),
        'homePageRoute': (context) => HomePage(),
        'addItemPageRoute': (context) => AddItemPage(),
        'chatPageRoute': (context) => ChatPage(),
        'myProfilePageRoute': (context) => Profile_page(),
        'myLevelPageRoute': (context) => MyLevelPage(),
        'myAccountPageRoute': (context) => MyAccountPage(),
        'mapPageRoute': (context) => MapPage(),
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
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
                strokeWidth: 6,
              ),
            ),
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
