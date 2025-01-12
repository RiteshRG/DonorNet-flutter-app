import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/utilities/show_error_dialog.dart';
import 'package:donornet/views/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:developer' as devtools show log;

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({Key? key, required this.email}) : super(key: key);
    
  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isChecked = false;
  bool isLoading = false;
  late final TextEditingController passwordController;
  late final TextEditingController cPasswordController;

    @override
  void initState() {
    passwordController = TextEditingController();
    cPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    cPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async{
    
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if(password.isEmpty){
      showerrorDialog(context,"Please enter both password and confirm password.");
      return;
    }else if(password != cPassword){
      showerrorDialog(context,"Passwords do not match. Please make sure both passwords are identical.");
      return;
    }else if (!(password.length >= 8 && password.length <= 15 && RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:,.<>?])').hasMatch(password))) {
      showerrorDialog(context, "Password must be 8-15 characters, with at least one uppercase letter, one lowercase letter, one number, and one special character.");
      return;
    }else{
      try{
         setState(() {
      isLoading = true;
      });
        String email = widget.email;

        final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

          final document = querySnapshot.docs.first;
          final currentPassword = document['password'];
          await _firestore.collection('users').doc(document.id).update({'password': password});
          bool passwordUpdated = await _newPassword(password, currentPassword, email);

          if(passwordUpdated){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Password changed successfully!'),));
            Navigator.of(context).pushNamedAndRemoveUntil('loginRoute', (route) => false,);
          }else{
            await _firestore.collection('users').doc(document.id).update({'password': currentPassword});
            showerrorDialog(context, "Oops! Something went wrong. Try again later");
          }
      }on FirebaseAuthException catch (e){
        if (e.code == 'weak-password') {
        // ignore: use_build_context_synchronously
        showerrorDialog(context, "The password is too weak.");
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
  }
  Future<bool> _newPassword(String password,String currentPassword, String email) async{   
      try{ 
        User? user = FirebaseAuth.instance.currentUser;
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: currentPassword, // Collect or verify the current password
        );
        user = (await _auth.signInWithCredential(credential)).user;

        await user!.updatePassword(password);
      
        await _auth.signOut();
        return true;
      }
      on FirebaseAuthException catch (e){
      if (e.code == 'weak-password') {
      // ignore: use_build_context_synchronously
      showerrorDialog(context, "The password is too weak.");
      return false;
      }else {
        devtools.log("${e.message}");
        showerrorDialog(context, "Oops! Something went wrong. Try again later");
        return false;
      }
      }catch (e){
        devtools.log("An unexpected error occurred: ${e.toString()}");
        showerrorDialog(context,"An unexpected error occurred: ${e.toString()}");
        return false;
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
              top: -75,
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
                      top: 40, 
                      bottom: 50
                      ),
                    child: Text('Reset Your\nPassword',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
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
                                //*******Email Text Field**********
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
              
                                SizedBox(height: 25),
              
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
              
                                SizedBox(height: 15),
              
                                Text("Make sure it's at least 15 characters OR at least 8 characters including a number and a lowercase letter.",
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: const Color.fromARGB(147, 0, 0, 0),
                                  fontSize: 12
                                ),),
              
                                SizedBox(height: 70),
              
                                //*******Register Button**********
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      resetPassword();
                                      // Navigator.push(context, 
                                      // MaterialPageRoute(builder: (context) => Login()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(240, 50),
                                      backgroundColor:  AppColors.primaryColor,
                                    ),
                                    child: Text(
                                      "Change password",
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
                                    Text("Go back to the ",
                                    style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor: Colors.white,
                                      fontSize: 14
                                    ),),
                                    GestureDetector(
                                      onTap: () {
                                         Navigator.of(context).pushNamedAndRemoveUntil('loginRoute', (route) => false,);
                                      },
                                      child: Text(
                                        "Login",
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
