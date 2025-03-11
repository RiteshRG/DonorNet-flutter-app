import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/materials/access_throught_link.dart';
import 'package:donornet/views/authentication/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<StatefulWidget> createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          // Container(
          //   child: Image.network(
          //           '${AccessLink.logo}',
          //           height: 225,
          //           width: 225,
          //           fit: BoxFit.cover,
          //         ),
          // ),
          // Gradient Overlay
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
         Stack(
          children: [
            Positioned(
              top: -140,
              left: -80,
              child: Opacity(
                opacity: 0.55,
                child: Image.network(
                  '${AccessLink.logo}',
                  height: 225,
                  width: 225,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox.shrink(); 
                  },
                )
              ),
            ),
            
            Positioned(
              right: -90, 
              top: MediaQuery.of(context).size.height / 2 - 125, 
              child: Opacity(
                opacity: 0.55,
                child: Image.network(
                  '${AccessLink.logoFlip}',
                    height: 210,
                    width: 210,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                    return SizedBox.shrink(); 
                  },
                  ),
              ),
            ),
          ],
        ),
            
          SafeArea(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Logo Section
                  SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                  Container(
                    child: Image.network(
                    '${AccessLink.logo}',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox.shrink(); 
                        },
                      ),
                  ),
            
                  const SizedBox(height: 16),
                  const Text(
                    'DonorNet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 30, // Increased for emphasis
                      color: Colors.white,
                      fontFamily: 'Roboto-Bold',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            
                  // Buttons Section
                  Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 25, 
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  
                      const SizedBox(height: 40), 
                  
                      ElevatedButton(
                            onPressed: () {
                               Navigator.pushReplacementNamed(context, 'registerRoute');
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(240, 50),
                              backgroundColor:  const Color.fromARGB(255, 255, 255, 255),
                            ),
                            child: Text('Register',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.secondaryColor
                            ),
                            ),
                          ), 
                  
                        const SizedBox(height: 20), 
                         ElevatedButton(
                              onPressed: () {
                                //sign-in logic
                                Navigator.push(context, 
                              MaterialPageRoute(builder: (context) => Login()));
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(240, 50),
                                backgroundColor:  const Color.fromARGB(255, 255, 255, 255),
                              ),
                              child: Text('Login',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.secondaryColor
                              ),
                              ),
                            ), 
                        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
