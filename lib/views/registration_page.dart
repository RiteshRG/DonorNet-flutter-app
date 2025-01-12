import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/utilities/show_error_dialog.dart';
import 'package:donornet/views/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:developer' as devtools show log;
import 'package:donornet/utilities/loading_indicator.dart';

import 'package:fluttertoast/fluttertoast.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isChecked = false;
  late final TextEditingController emailController;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController passwordController;
  late final TextEditingController cPasswordController;

  bool isLoading = false;

     @override
  void initState() {
    emailController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    passwordController = TextEditingController();
    cPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    cPasswordController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async{
    String email =emailController.text.trim();
    String firstName =firstNameController.text.trim();
    String lastName =lastNameController.text.trim();
    String password =passwordController.text.trim();
    String cPassword =cPasswordController.text.trim();
      setState(() {
      isLoading = true;
      });


    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || cPassword.isEmpty) {
       showerrorDialog(context,"Please fill all the details!");
       return;
    }else if(firstName.length > 20 || RegExp(r'[^a-zA-Z]').hasMatch(firstName)){
      showerrorDialog(context,"First name must be at most 20 characters long and contain only letters.");
      return;
    }else if(lastName.length > 20 || RegExp(r'[^a-zA-Z]').hasMatch(lastName)){
      showerrorDialog(context,"Last name must be at most 20 characters long and contain only letters.");
      return;
    }else if(password != cPassword){
       showerrorDialog(context,"Password do not match!");
       return;
      }else if (!(password.length >= 8 && password.length <= 15 && RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:,.<>?])').hasMatch(password))) {
      showerrorDialog(context, "Password must be 8-15 characters, with at least one uppercase letter, one lowercase letter, one number, and one special character.");
      return;
    }else if(isChecked == false){
      showerrorDialog(context, "You must accept the terms and conditions to proceed.");
    }else{

      try{
        UserCredential userCredential = await _auth.
        createUserWithEmailAndPassword(email: email, password: password);

        // devtools.log("User data: ${userCredential.user}");
 
        // Send email verification link
        await userCredential.user?.sendEmailVerification();

         // Store user data in Firestore
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'first_name':firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'is_verified': false,
          'registration_date': DateTime.now(),
        });

        showerrorDialog(context,"Registration successful! Please verify your email.");

        _auth.authStateChanges().listen((user) async {
        if (user != null && user.emailVerified) {
          // Update Firestore after email is verified
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'is_verified': true,
          });
          devtools.log("User email verified: ${user.uid}");
        }
      });

        Navigator.pushReplacementNamed(context, 'verificationRoute');
        devtools.log('User registered: $userCredential');

      } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth errors
      if (e.code == 'weak-password') {
        // ignore: use_build_context_synchronously
        showerrorDialog(context, "The password is too weak.");
      } else if (e.code == 'email-already-in-use') {
        showerrorDialog(context,"An account already exists for that email.");
      } else if (e.code == 'invalid-email') {
        showerrorDialog(context,"The email address is invalid.");
      } else {
        devtools.log("${e.message}");
        showerrorDialog(context, "Oops! Something went wrong. Try again later");
      }
    } catch (e) {
      // Handle any other errors
      devtools.log("An unexpected error occurred: ${e.toString()}");
      showerrorDialog(context,"An unexpected error occurred: ${e.toString()}");
    }finally {
      setState(() {
        isLoading = false;
      });
    }

    }

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
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(
                      left: 40, 
                      top: 35, 
                      bottom: 50
                      ),
                    child: Text('Create Your\nAccount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
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
                        top: 25,
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 25.0,
                          left: 25.0,
                          top: 25,
                          ),
                          child: Form( // Wrap the form fields in a Form widget
                            // key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                // Email Field (TextFormField with validator)
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
                                SizedBox(height: 15),
                                // First Name and Last Name Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: firstNameController,
                                        decoration: InputDecoration(
                                          labelText: "First Name",
                                          floatingLabelStyle: TextStyle(
                                            fontSize: 19,
                                            color: AppColors.secondaryColor,
                                          ),
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
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your first name';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
              
                                    SizedBox(width: 10),
              
                                    Expanded(
                                      child: TextFormField(
                                        controller: lastNameController,
                                        decoration: InputDecoration(
                                          labelText: "Last Name",
                                          floatingLabelStyle: TextStyle(
                                            fontSize: 19,
                                            color: AppColors.secondaryColor,
                                          ),
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
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your last name';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
              
                                // Password Field (TextFormField with validator)
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: !isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    floatingLabelStyle: TextStyle(
                                      fontSize: 19,
                                      color: AppColors.secondaryColor,
                                    ),
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
                                    suffixIcon: IconButton(onPressed: (){
                                      setState(() {
                                        isPasswordVisible =!isPasswordVisible;
                                      });
                                    }, icon:  Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: AppColors.secondaryColor,
                                    size: (20),
                                      )
                                    ),
                                    //contentPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 18),
                                  ),
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 15),
              
                                Text('Password must be at least 8 or 15 characters long, and include an uppercase letter, a lowercase letter, a number, and a special character.',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: const Color.fromARGB(147, 0, 0, 0),
                                  fontSize: 12
                                ),),
              
                                SizedBox(height: 15),
              
                                // Confirm Password Field (TextFormField with validator)
                                TextFormField(
                                  controller: cPasswordController,
                                  obscureText: !isConfirmPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: "Confirm Password",
                                    floatingLabelStyle: TextStyle(
                                      fontSize: 19,
                                      color: AppColors.secondaryColor,
                                    ),
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
                                    suffixIcon: IconButton(onPressed: (){
                                      setState(() {
                                        isConfirmPasswordVisible =!isConfirmPasswordVisible;
                                      });
                                    }, icon:  Icon(isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: AppColors.secondaryColor,
                                    size: (20),
                                      )
                                    ),
                                    //contentPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 18),
                                  ),
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    return null;
                                  },
                                ),
              
                                SizedBox(height: 20),
                                // Terms and Conditions Checkbox
                                Row(
                                  children: [
                                  
                                  //**********checkbos*********
                                    Checkbox(
                                    fillColor: MaterialStateProperty.all(AppColors.primaryColor),
                                      value: isChecked,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          isChecked = value ?? false;
                                        });
                                        // Handle checkbox state change
                                      },
                                    ),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "I agree to DonorNet's ",
                                              style: TextStyle(color: Colors.black), // Default text color
                                            ),
                                            TextSpan(
                                              text: 'Terms and Conditions, Privacy Policy,',
                                              style: TextStyle(color: AppColors.primaryColor,
                                              fontWeight: FontWeight.bold
                                              ), // Change the color of the quoted text
                                            ),
                                            TextSpan(
                                              text: ' and ',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: 'End User License Agreement',
                                              style: TextStyle(color: AppColors.primaryColor,
                                              fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            TextSpan(
                                              text: '.',
                                              style: TextStyle(color: Colors.black), // Default text color after the quoted part
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 50),
                                // Register Button
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // if (_formKey.currentState?.validate() ?? false) {
                                      //   // If the form is valid, proceed with registration logic
                                      // }
                                      // Navigator.push(context, 
                                      // MaterialPageRoute(builder: (context) => OTPVerificationPage()));
                                      createAccount();
                                    },
                                    child: Text(
                                      "Register",
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
                                SizedBox(height: 30),
                                // Login Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Already have an account? "),
                                    GestureDetector(
                                      onTap: () {
                                         Navigator.push(context, 
                                      MaterialPageRoute(builder: (context) => Login()));
                                      },
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            LoadingIndicator(isLoading: isLoading),
        ],
      )
    );
  }
}
