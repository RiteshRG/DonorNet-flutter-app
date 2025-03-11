import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/OTP_service.dart';
import 'package:donornet/materials/access_throught_link.dart';

import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/utilities/show_dialog.dart';
import 'package:donornet/views/authentication/otp_verification_page.dart';
import 'package:donornet/views/authentication/registration_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:developer' as devtools show log;


class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OTPService _otpService = OTPService();
  late final TextEditingController emailController;  
  bool isLoading = false;

  Future<void> isEmailRegister() async{
    String email = emailController.text.trim();
    if(email.isEmpty){
      showErrorDialog(context,"Please Enter your email");
      return;
    }
    setState(() {
      isLoading = true;
    });

     try {
      final querySnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();

       bool isRegistered = querySnapshot.docs.isNotEmpty;

      if (isRegistered) {
        devtools.log("registed");
        bool isSent = await _otpService.sendOtp(email);
        if(isSent){
          //Fluttertoast.showToast(msg: "OTP sent successfully to $email");
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP sent successfully to $email")),);

            // ignore: use_build_context_synchronously
            Navigator.push(context,MaterialPageRoute(builder: (context) => OTPVerificationPage(email: email)),);
            //Navigator.push(context, MaterialPageRoute(builder: (context) => OTPVerificationPage()));
        }else{
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send OTP. Try again.")));
        }
      }else{
        devtools.log("No account found");
        showErrorDialog(context, "No account found associated with this email address.");
      }

    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        showErrorDialog(context, "You don't have permission to access Firestore.");
      } else if (e.code == 'unavailable') {
        showErrorDialog(context, "Firestore service is temporarily unavailable.");
      } else {
        showErrorDialog(context, "Firestore error: ${e.message}");
      }
    } catch (e) {
      devtools.log("An unexpected error occurred: ${e.toString()}");
      showErrorDialog(context, "An unexpected error occurred: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
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
              top: -70,
              right: -80,
              child: Opacity(
                opacity: 0.77,
                child: Center(
                  child: Image.network(
                     '${AccessLink.logoFlip}',
                    height: 225,
                    width: 225,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                          return SizedBox.shrink(); 
                        },
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(
                      left: 40, 
                      top: 35, 
                      bottom: 12
                      ),
                    child: Text('Forgot\nPassword ?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.bold
                    ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30,  bottom: 35),
                    alignment: Alignment.topLeft,
                    child: IconButton(onPressed: (){
                      Navigator.of(context).pushNamedAndRemoveUntil('loginRoute', (route) => false,);
                    }, icon: Icon(Icons.arrow_back,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    size: 28,
                    )),
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
                            blurRadius: 18, // The blur radius of the shadow (how soft it is)
                             offset: Offset(0, -9),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.only(
                        top: 25,
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 25.0,
                          left: 25.0,
                          top: 25,
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Please enter your verified email address, and we will send you an OTP to proceed with resetting your password.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 109, 108, 108)
                                ),
                                ),
                                
                                SizedBox(height: 32,),
              
                                //*******Email Text Field**********
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    floatingLabelStyle: TextStyle(
                                      fontSize: 19,
                                      color: AppColors.secondaryColor,
                                    ),hintText: "example@gmail.com",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          color: AppColors.secondaryColor,
                                          width: 1.2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          color: AppColors.secondaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      //contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                                    ),
                                    style: TextStyle(
                                      fontSize: 15, 
                                    ),
                                    obscureText: false,
                                    keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
              
                                SizedBox(height: 70),
              
                                //*******Register Button**********
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Navigator.push(context, MaterialPageRoute(builder: (context) => OTPVerificationPage()));
                                       isEmailRegister();                                      
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(240, 50),
                                      backgroundColor:  AppColors.primaryColor,
                                    ),
                                    child: Text(
                                      "Send OTP",
                                      style: TextStyle(fontSize: 18,
                                      color: Colors.white,
                                      ),
                                    ),
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
                                    SizedBox(height: 100.0),
                                  ],
                                ),
                                              ],
                          )
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            //*********Text(Don’t have an Account?)******/
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: 
            // )
            LoadingIndicator(isLoading: isLoading),
        ],
      )
    );
  }
}
