import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/views/login_page.dart';
import 'package:donornet/views/registration_page.dart';
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
          Container(
            child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    height: 225,
                    width: 225,
                    fit: BoxFit.cover,
                  ),
          ),
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
            // First Positioned widget (top-left with offset)
            Positioned(
              top: -140,
              left: -80,
              child: Opacity(
                opacity: 0.55,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0), // Horizontal flip
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    height: 225,
                    width: 225,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            // Second Positioned widget (centered and applying the left position)
            Positioned(
              right: -90, // This can be adjusted based on the desired vertical positioning.
              top: MediaQuery.of(context).size.height / 2 - 125, // This centers the widget horizontally
              child: Opacity(
                opacity: 0.55,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(1.0, 1.0), // Horizontal flip
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    height: 210,
                    width: 210,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
            
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Logo Section
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                Container(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..scale(-1.0, 1.0), // Horizontal flip
                    child: SvgPicture.asset(
                      'assets/icons/logo.svg',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
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
                child: SafeArea(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
