import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/materials/access_throught_link.dart';
import 'package:donornet/views/rating_page.dart';
import 'package:flutter/material.dart';

class ConfirmClaimPage extends StatelessWidget {
  const ConfirmClaimPage({Key? key}) : super(key: key);

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
                  top: -40,
                  left: -40,
                  child: Opacity(
                    opacity: 0.8,
                    child: Image.network(
                          '${AccessLink.coinGolden}',
                            height: 180,
                            width: 180,
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
                                  'Confirm Claim',
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
                                    'Have you successfully received the item?',
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
                        SizedBox(height: 20,),
                         
                        Container(
                          width: double.infinity,
                          height: 300,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 80,
                                left: -20,
                                child: Container( // container for item
                                  child: Stack(
                                    children: [
                                      Opacity(
                                        opacity: 0.8,
                                        child: Image.network(
                                          '${AccessLink.logo}',
                                            height: 180,
                                            width: 180,
                                            fit: BoxFit.cover,
                                          ),
                                      ),
                                      Positioned(
                                        right: 9,
                                        top: 8,
                                        child: Container(
                                          width: 85,
                                          height: 85,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                            image: const DecorationImage(
                                              image: NetworkImage('https://tse3.mm.bing.net/th?id=OIP.AkBJECD9LR5tjUnpIp1cfgHaFj&pid=Api&P=0&h=180'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -15,
                                top: 0,
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    image: const DecorationImage(
                                      image: NetworkImage('https://i.pinimg.com/originals/5d/a8/76/5da8768c07eb3db7dbf5f394ab4444a6.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Buttons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Yes Button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => RatingPage()),
                                );
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
                                'Yes',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 20),
                    
                            // No Button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  'homePageRoute',
                                  (route) => false, // Removes all previous routes
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // Filled white
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(200), // Rounded corners
                                  side: BorderSide(color: AppColors.primaryColor, width: 2), // Red border
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                elevation: 5, // Adds shadow effect
                                shadowColor: Colors.black54, // Shadow color
                              ),
                              child: Text(
                                'No',
                                style: TextStyle(fontSize: 18, color:AppColors.primaryColor),
                              ),
                            ),
                          ],
                        )
                    
                      ],
                ),
              ),
          ],
        ),
        ),
    );
  }
}

// import 'package:donornet/materials/app_colors.dart';
// import 'package:donornet/utilities/access_throught_link.dart';
// import 'package:flutter/material.dart';

// class ConfirmClaimPage extends StatefulWidget {
//   const ConfirmClaimPage({super.key});

//   @override
//   State<ConfirmClaimPage> createState() => _ConfirmClaimPageState();
// }

// class _ConfirmClaimPageState extends State<ConfirmClaimPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppColors.primaryColor,
//               AppColors.tertiaryColor,
//             ],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left
//             children: [
//               // Centered Title
//               Align(
//                 alignment: Alignment.center,
//                 child: Text(
//                   'Confirm Claim',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),

//               // Left-Aligned Second Text
//               Text(
//                 'Have you successfully received the item from Maya Das?',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//                 textAlign: TextAlign.left,
//               ),
//               SizedBox(height: 20),

//               // Circular Avatar at the Right
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: CircleAvatar(
//                   radius: 60,
//                   backgroundImage: NetworkImage('${AccessLink.logo}'),
//                 ),
//               ),
//               SizedBox(height: 20),

//               // Positioned Widget at Bottom Left
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Image.network(
//                 '${AccessLink.logo}',
//                   height: 140,
//                   width: 140,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
