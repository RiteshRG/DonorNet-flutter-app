import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/materials/access_throught_link.dart';
import 'package:donornet/services%20and%20provider/user_service.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:flutter/material.dart';

class RatingPage extends StatefulWidget {
  final Map<String, dynamic> postData;
  const RatingPage({Key? key, required this.postData}) : super(key: key);

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
                                      color: index < selectedStars ? const Color.fromARGB(255, 255, 214, 7) : const Color.fromARGB(255, 255, 255, 255), 
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedStars = index + 1; 
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
                          onPressed: () async {
                            if (selectedStars > 0) {
                            print("You rated: $selectedStars stars");

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(child: LoadingIndicator(isLoading: true)),
                            );
                            bool success = await UserService().rateUser(widget.postData['user_id'], selectedStars);
                            Navigator.pop(context);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Rating submitted successfully!"),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              Future.delayed(const Duration(seconds: 1), () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  'homePageRoute',
                                  (route) => false,
                                );
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to submit rating. Please try again."),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select a rating before proceeding."),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor, 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(200), 
                              side: BorderSide(color: Colors.white, width: 2), 
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            elevation: 5, 
                            shadowColor: Colors.black54, 
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