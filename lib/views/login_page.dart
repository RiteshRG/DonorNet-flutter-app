import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/utilities/show_error_dialog.dart';
import 'package:donornet/views/home.dart';
import 'package:donornet/views/registration_page.dart';
import 'package:donornet/views/email_verification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:developer' as devtools show log;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  bool isPasswordVisible = false;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;


  Future<void> loginUser() async{
    String email =emailController.text.trim();
    String password =passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
       showerrorDialog(context,"Please fill all the details!");
       return;
    }

    setState(() {
      isLoading = true;
    });
    try{
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final currentUser = _auth.currentUser;

      if(currentUser?.emailVerified ?? false){
        await _firestore.collection('users').doc(currentUser?.uid).update({'is_verified': true});

        Navigator.of(context).pushNamedAndRemoveUntil('homePageRoute', (route) => false,);
      }else{
        await currentUser?.sendEmailVerification();
        Navigator.of(context).pushNamedAndRemoveUntil('verificationRoute', (route) => false,);
      }

    }on FirebaseAuthException catch (e){
      if (e.code == 'wrong-password') {
        showerrorDialog(context, "Incorrect password. Please try again.");
      }else if (e.code == 'invalid-email') {
        showerrorDialog(context,"The email address is invalid.");
      }else if (e.code == 'user-not-found') {
        showerrorDialog(context, "User not found. Please check your credentials or sign up.");
      }else {
        devtools.log("${e.message}");
        showerrorDialog(context, "Oops! Something went wrong. Try again later");
      }
    }catch (e){
      devtools.log("An unexpected error occurred: ${e.toString()}");
      showerrorDialog(context,"An unexpected error occurred: ${e.toString()}");
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }

   @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                   AppColors.secondaryColor, 
                  AppColors.tertiaryColor, 
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
           Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
           Positioned(
              top: -40,
              right: -80,
              child: Opacity(
                opacity: 0.77,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    height: 225,
                    width: 225,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // text - hello sign....
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(
                      left: 40, 
                      top: 35, 
                      bottom: 55
                      ),
                    child: Text('Hello\nSign in!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 37,
                      fontWeight: FontWeight.bold
                    ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),  
                          topRight: Radius.circular(50),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(39, 0, 0, 0),  // Shadow color (can use black, gray, etc.)
                            blurRadius: 18,         // The blur radius of the shadow (how soft it is)
                            offset: Offset(0, -9),   // The position of the shadow (dx, dy)
                          ),
                        ],
                      ),
                      padding: EdgeInsets.only(
                        top: 50,
                      ),
                      child: SingleChildScrollView(
              
                          padding: EdgeInsets.only(
                          left: 25,
                          right: 25,
                      ) ,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Container(
                            //   padding: EdgeInsets.only(left: 10),
                            //   alignment: Alignment.topLeft,
                            //   child: Text("Email",
                            //   style: TextStyle(
                            //     color: Colors.black,
                            //     fontSize: 16
                            //   ),
                            //   ),
                            // ),
                            SizedBox(height: 13),
                            TextField(
                              controller: emailController,
                               decoration: InputDecoration(
                                labelText: 'Email',
                                 floatingLabelStyle: TextStyle(
                                  fontSize: 20,
                                  color: AppColors.secondaryColor,
                                ),
                                hintText: "example@gmail.com",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 1.2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                              ),
                              style: TextStyle(
                                fontSize: 15, // Set the font size to 23
                              ),
                              obscureText: false,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 37.0),
              
                            // Container(
                            //   alignment: Alignment.topLeft,
                            //   padding: EdgeInsets.only(left: 10),
                            //   child: Text("Password",
                            //   style: TextStyle(
                            //     color: Colors.black,
                            //     fontSize: 16
                            //   ),
                            //   ),
                            // ),
                            //SizedBox(height: 13),
                            
                            TextField(
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                floatingLabelStyle: TextStyle(
                                  fontSize: 20,
                                  color: AppColors.secondaryColor,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 1.2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                suffixIcon: IconButton(onPressed: (){
                                  setState(() {
                                    isPasswordVisible =!isPasswordVisible;
                                  });
                                }, icon:  Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: AppColors.primaryColor,
                                size: (20),
                                  )
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 18),
                              ),
                              style: TextStyle(
                                fontSize: 15,
                              ),
                              keyboardType: TextInputType.visiblePassword,
                            ),
              
                            SizedBox(height: 4),
              
                            //*********Forget Password? */
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EmailVerificationPage()));
                                },
                                child: Text('Forget Password?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.secondaryColor,
                                  ),
                                ),
                              ),
                            ),
              
                            SizedBox(height: 30
                            //MediaQuery.of(context).size.height * 0.099, 
                            ),
              
                            //*********login */
                            ElevatedButton(
                              onPressed: () {
                                 loginUser();
                              },
                              child: Text('login',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white
                              ),
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(240, 50),
                                backgroundColor:  AppColors.primaryColor,
                              ),
                            ),   
              
                            SizedBox(height: 80.0),
              
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don’t have an Account? ",
                                style: TextStyle(
                                  color: Colors.black,
                                  backgroundColor: Colors.white,
                                  fontSize: 14
                                ),),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, 
                                          MaterialPageRoute(builder: (context) => Register()));
                                  },
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                      backgroundColor: Colors.white,
                                        decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.solid,
                                        decorationColor: AppColors.primaryColor,
                                      color:  AppColors.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 100,)
                              ],
                            ),                    
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: 
            // ),   
            LoadingIndicator(isLoading: isLoading),  
        ],
      ),
    );
  }
}
