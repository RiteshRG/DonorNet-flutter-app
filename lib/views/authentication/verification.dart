
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/utilities/show_error_dialog.dart';
import 'package:donornet/views/authentication/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  bool isLoading = false;

@override
void initState() {
  super.initState();

}


  Future<void> sendVerificationEmail() async {
    setState(() {
      isLoading = true;
    });
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        showerrorDialog(context,"Verification email sent!");
      } catch (e) {
        showerrorDialog(context,"Error sending email: ${e.toString()}");
      }
    }
    setState(() {
      isLoading = false;
    });
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
          Positioned(
              top: -40,
              right: -70,
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
                    child: Text('Verify Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      //fontWeight: FontWeight.bold
                    ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30),
                    alignment: Alignment.topLeft,
                    child: IconButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                    }, icon: Icon(Icons.arrow_back,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    size: 28,
                    )),
                  ),
                  Expanded(
                    child: Container(
                      //alignment: Alignment.topCenter,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //SizedBox(height: 70,),
                            Container(
                              alignment: Alignment.topCenter,
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: Text("We've sent you an email verification. please open it to verify your acount.\n\nIf you haven't recevied a verification email yet, press the button below. Please verify your email address",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 255, 255, 255)
                              ),
                              ),
                            ),
                            
                            //SizedBox(height: 70,),
                            
                            //*******Register Button**********
                            Center(
                              child: ElevatedButton(
                                onPressed:  isLoading
                                ? null // Disable button while loading
                                : sendVerificationEmail,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(240, 50),
                                  backgroundColor:  const Color.fromARGB(255, 255, 255, 255),
                                ),
                                child: isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  "Send email verification",
                                  style: TextStyle(fontSize: 20,
                                  color: AppColors.tertiaryColor,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              // padding: EdgeInsets.only(left: 40),
                              alignment: Alignment.topLeft,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Go back to the  ",
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 18
                                  ),),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, 
                                            MaterialPageRoute(builder: (context) => Login()));
                                    },
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.solid,
                                          decorationColor: AppColors.primaryColor,
                                        color:  const Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                      ),
                    ),
                  )                 
                ],
              ),
            ),
        ],
      )
    );
  }
}