import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/views/login_page.dart';
import 'package:donornet/views/registration_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isChecked = false;

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
                                      // if (_formKey.currentState?.validate() ?? false) {
                                      //   // If the form is valid, proceed with registration logic
                                      // }
                                      Navigator.push(context, 
                                      MaterialPageRoute(builder: (context) => Login()));
                                    },
                                    child: Text(
                                      "Change password",
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
                                    Text("Go back to the ",
                                    style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor: Colors.white,
                                      fontSize: 14
                                    ),),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, 
                                              MaterialPageRoute(builder: (context) => Login()));
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
        ],
      )
    );
  }
}
