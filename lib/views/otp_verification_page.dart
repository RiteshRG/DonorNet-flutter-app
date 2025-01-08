import 'dart:async';

import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/views/email_verification_page.dart';
import 'package:donornet/views/registration_page.dart';
import 'package:donornet/views/resetPassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({super.key});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {

  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  final TextEditingController controller4 = TextEditingController();

  int _start = 180; // Initial timer duration
  late Timer _timer;

  void initState() {
    super.initState();
    _startTimer(); // Start the timer when the screen is loaded
  }

  // Start the countdown timer
  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          _timer.cancel(); // Stop the timer when it reaches 0
        });
      } else {
        setState(() {
          _start--; // Decrease the timer value every second
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the screen is disposed
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
              color: const Color.fromARGB(255, 255, 255, 255),
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
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(
                      left: 40, 
                      top: 35, 
                      bottom: 12
                      ),
                    child: Text('OTP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.bold
                    ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30,  bottom: 40),
                    alignment: Alignment.topLeft,
                    child: IconButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EmailVerificationPage()));
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
                            blurRadius: 30, // The blur radius of the shadow (how soft it is)
                            offset: Offset(0, -9),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.only(
                        top: 25,
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 27.0,
                          left: 27.0,
                          top: 15,
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Enter the verified email address associated with your account, and we will send you an OTP via email to reset your password.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 109, 108, 108)
                                ),
                                ),
                                
                                SizedBox(height: 25,),
              
                                Text(
                                  '${_start ~/ 60}:${_start % 60 < 10 ? '0${_start % 60}' : _start % 60}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
              
                                SizedBox(height: 20,),
              
                                //*******Email Text Field**********
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OTPTextField(controller: controller1),
                                    SizedBox(width: 10),
                                    OTPTextField(controller: controller2),
                                    SizedBox(width: 10),
                                    OTPTextField(controller: controller3),
                                    SizedBox(width: 10),
                                    OTPTextField(controller: controller4),
                                  ],
                                ),
              
                                SizedBox(height: 30),
              
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Don’t receive the OTP? ",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 109, 108, 108),
                                      fontSize: 14
                                    ),),
                                    GestureDetector(
                                      onTap: () {
                                        //
                                      },
                                      child: Text(
                                        "Resend",
                                        style: TextStyle(
                                            decorationColor: AppColors.primaryColor,
                                          color:  AppColors.primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
              
                                SizedBox(height: 50),
              
                                //*******Register Button**********
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // if (_formKey.currentState?.validate() ?? false) {
                                      //   // If the form is valid, proceed with registration logic
                                      // }
                                      String otp = controller1.text + controller2.text + controller3.text + controller4.text;
                                      print("Entered OTP: $otp");
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));
                                    },
                                    child: Text(
                                      "Verify OTP",
                                      style: TextStyle(fontSize: 18,
                                      color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(240, 50),
                                      backgroundColor:  AppColors.primaryColor,
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
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Text("Don’t have an Account? ",
            //       style: TextStyle(
            //         color: Colors.black,
            //         backgroundColor: Colors.white,
            //         fontSize: 14
            //       ),),
            //       GestureDetector(
            //         onTap: () {
            //           Navigator.push(context, 
            //                 MaterialPageRoute(builder: (context) => Signup()));
            //         },
            //         child: Text(
            //           "Register",
            //           style: TextStyle(
            //             backgroundColor: Colors.white,
            //               decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.solid,
            //               decorationColor: AppColors.primaryColor,
            //             color:  AppColors.primaryColor,
            //             fontSize: 14,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //       SizedBox(height: 110.0),
            //     ],
            //   ),
            // )
        ],
      )
    );
  }
}


class OTPTextField extends StatelessWidget {
  final TextEditingController controller;

  OTPTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          counterText: "",
          hintText: "0",
          filled: true,
          fillColor: const Color.fromARGB(0, 182, 239, 215),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.secondaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.secondaryColor),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}