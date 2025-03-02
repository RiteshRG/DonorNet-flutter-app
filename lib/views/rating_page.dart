import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/materials/access_throught_link.dart';
import 'package:flutter/material.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int selectedStars = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 38, 182, 122),
                  Color.fromARGB(255, 15, 119, 125),
                ],
              ),
            ),
        child: Stack(
          children: [
            Positioned(
                  top: -10,
                  left: -60,
                  child: Opacity(
                    opacity: 0.8,
                    child: Image.network(
                          '${AccessLink.logo}',
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                      ),),
                    SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                    
                        Container(
                          //padding: EdgeInsets.only(left: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                child: Text(
                                  'Rate Donor',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: 250,
                                  child:  Text(
                                    'How was your experience',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500
                                    ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1, 
                        ),
                        Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return FittedBox(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.star,
                                      size: 40,
                                      color: index < selectedStars ? const Color.fromARGB(255, 255, 214, 7) : const Color.fromARGB(255, 255, 255, 255), // Change color if selected
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedStars = index + 1; // Updates the rating
                                      });
                                    },
                                  ),
                                );
                              }),
                            ),
                            SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08, 
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedStars > 0) {
                              print("You rated: $selectedStars stars");
                              Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  'homePageRoute',
                                  (route) => false, 
                                );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please select a rating before proceeding."),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor, // Filled red
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(200), // Rounded corners
                              side: BorderSide(color: Colors.white, width: 2), // White border
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            elevation: 5, // Adds shadow effect
                            shadowColor: Colors.black54, // Shadow color
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                ),
              ),
          ],
        ),
        ),
    );
  }
}