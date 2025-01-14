import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/utilities/show_error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

void logoutUser() async {
  try {
    await _auth.signOut();
     Navigator.of(context).pushNamedAndRemoveUntil('welcomePageRoute', (route) => false,);
    print("User successfully logged out");
    // Navigate to the login or welcome screen
  } catch (e) {

    showerrorDialog(context, "Error logging out: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       key: _scaffoldKey,
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          Positioned(
            // top: 0, 
            child: Container(
              width: double.infinity,
                height:100,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor, 
                // borderRadius: BorderRadius.only(   
                //   bottomLeft: Radius.circular(20), 
                //   bottomRight: Radius.circular(70), 
                // ),
                // gradient: LinearGradient(
                //   colors: [const Color.fromARGB(240, 15, 119, 125), AppColors.primaryColor], 
                //   begin: Alignment.topLeft,  
                //   end: Alignment.bottomRight, 
                // ),
              ),
            ),
          ),
          // Content Layer

          SafeArea(
            child: Stack(
              children: [
                 Container(
                  width: double.infinity,
                    height:125,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.only(   
                      bottomLeft: Radius.circular(20), 
                      bottomRight: Radius.circular(70), 
                    ),
                    // gradient: LinearGradient(
                    //   colors: [const Color.fromARGB(240, 15, 119, 125), AppColors.primaryColor], 
                    //   begin: Alignment.topLeft,  
                    //   end: Alignment.bottomRight, 
                    // ),
                  ),
                ),
                Column(
                  children: [
                    // Custom AppBar
                    Container(
                      alignment: Alignment.topLeft,    
                      padding: const EdgeInsets.only(top: 0, bottom: 15,left: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                child: Text(
                                  "DonorNet",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              FittedBox(
                                child: Text(
                                  "Connect and Donate",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    // fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                
                          //******Drawor */
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(
                                right: 20
                              ),
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                child: InkWell(
                                  onTap: (){
                                     _scaffoldKey.currentState?.openDrawer();
                                  },
                                  child: Icon(Icons.menu,
                                color: Colors.white,
                                size: 32,
                                ),
                                ),
                              ),
                            ),
                          ) 
                        ],
                        
                      ),
                    ),
                    // Search and Filter Section
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 12,
                        bottom: 20,
                        // horizontal: 12.0, vertical: 12
                        ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                // color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 4,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 133, 133, 133),
                                  ),
                                  prefixIcon: Icon(Icons.search, color: Color.fromARGB(255, 147, 147, 147)),
                                   border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: Colors.transparent), // Transparent border
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: Colors.transparent, width: 1.0), // Transparent enabled border
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: Colors.transparent, width: 2.0), // Transparent focused border
                                  ),
                                  filled: true,
                                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                
                          SizedBox(width: 10),
                
                          /*****Filter******* */
                          GestureDetector(
                            onTap: () {
                              logoutUser();
                            },
                            child: Container(
                              padding: EdgeInsets.all(15),
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryColor,
                                 gradient: LinearGradient(
                                  colors: [AppColors.tertiaryColor, const Color.fromARGB(255, 29, 146, 97)], 
                                  begin: Alignment.topLeft,  
                                  end: Alignment.bottomRight, 
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 252, 252, 252).withOpacity(0.4),
                                    spreadRadius: 1,
                                    blurRadius: 7,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: SvgPicture.asset('assets/icons/filter.svg',
                              height: 20,
                              width: 20,
                              fit: BoxFit.cover,
                              )
                            ), // Replace with your widget
                          ),
                        ],
                      ),
                    ),
                
                    // Scrollable Post List
                    Expanded(
                      child: ListView.builder(
                        itemCount: 10, // Replace with the dynamic post count
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Add your click action here
                              print('post clicked');
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 10,
                                left: 10,
                                bottom: 20),
                              height: 240,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2), // Shadow color with opacity
                                    spreadRadius: 3, // How far the shadow spreads
                                    blurRadius: 4, // How blurry the shadow appears
                                    offset: Offset(3, 3), // Offset of the shadow (x, y)
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Container(  
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [
                                            //image
                                            ClipRRect(
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15),
                                                ),
                                                child: Image.network(
                                                  'https://collectmyclothes.co.uk/wp-content/uploads/2019/11/donation.jpg',
                                                  width: double.infinity,
                                                  height: 178, // Adjust image height
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                  
                                            //text
                                            Container(
                                              padding: EdgeInsets.only(top:5, right: 10, left: 75),
                                              child: Expanded(
                                                child: Row(
                                                  children: [
                                                    //name
                                                    FittedBox(
                                                      child: Text("Rajesh Singh",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12,),
                                                    Icon(
                                                      Icons.arrow_drop_down_circle_rounded,
                                                      color: Colors.black,
                                                      size: 5,
                                                    ),
                                                    SizedBox(width: 12,),
                                                    Icon(Icons.star,
                                                      color: const Color.fromARGB(255, 245, 185, 6),
                                                      size: 14,
                                                    ),
                                                    SizedBox(width: 5,),
                                                    FittedBox(
                                                      child: Text("4.2",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                
                                                    Expanded(child: Container()),
                                                    Icon(Icons.location_on_sharp,
                                                      color: AppColors.primaryColor,
                                                      size: 14,
                                                    ),
                                                    SizedBox(width: 2,),
                                                    FittedBox(
                                                      child: Text("10 km",
                                                        style: TextStyle(
                                                          color: AppColors.secondaryColor,
                                                          fontSize: 12
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                  
                                            Container(
                                              padding: EdgeInsets.only(left: 40.5, top: 3),
                                              alignment: Alignment.centerLeft,
                                              child: FittedBox(
                                                child: Text("Good Condition Jeans Pants",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500
                                                ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        // date
                                        Positioned(
                                          top: 5,
                                          right: 10,
                                          child: Text(
                                            "8 Nov",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(2, 2), 
                                                  blurRadius: 4.0, 
                                                  color: Colors.black.withOpacity(0.6),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //profile
                                  Positioned(
                                    bottom: 39.5,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Add your click action here
                                        print('profile clicked');
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(left: 18),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(1000),
                                            border: Border.all(
                                              color: Colors.white, // You can change the color of the border here
                                              width: 2, // Adjust the width of the border
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.4), // Shadow color with opacity
                                                offset: Offset(2, 1), // Shadow position (x, y)
                                                blurRadius: 6, // Blur effect
                                                spreadRadius: 1, // Spread effect
                                              ),
                                            ],
                                          ),
                                        child: ClipOval(
                                          child:  Image.network(
                                            'https://i.pinimg.com/originals/83/bc/8b/83bc8b88cf6bc4b4e04d153a418cde62.jpg',
                                            height: 46,
                                            width: 46,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: const Color.fromARGB(126, 35, 151, 103),
          currentIndex: 0, // Set initial index
          onTap: (index) {
            // Handle bottom navigation tap
          },
          // showSelectedLabels: false,
          // showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 29),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.my_location_outlined, size: 29),
              label: "Location",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/add.svg',
                height: 37,
                width: 37,
                fit: BoxFit.cover,
              ),
              label: "Post",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined, size: 29),
              label: "Chat",
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 29,
                height: 29,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    )
                  ],
                  image: DecorationImage(
                    image: AssetImage('assets/profile_4.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              label: "Profile",
            ),
          ],
          selectedLabelStyle: TextStyle(
            fontSize: 10, 
            color: AppColors.tertiaryColor,
            //fontWeight: FontWeight.bold, // Optional for bold text
          ),
          unselectedLabelStyle: TextStyle(
           fontSize: 9, 
           color: AppColors.tertiaryColor,
            //fontWeight: FontWeight.normal, // Optional for normal text
          ),
        ),
      ),
    );
  }
}


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Drawer Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              // Close drawer after tapping
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () {
              // Close drawer after tapping
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}