import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/utilities/show_error_dialog.dart';
import 'package:donornet/views/home%20page/drawer.dart';
import 'package:donornet/views/home%20page/post.dart';
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
                      child: Container(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: ListView.builder(
                          itemCount: 10, // Replace with the dynamic post count
                          itemBuilder: (context, index) {
                            return Post();
                          },
                        ),
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
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: const Color.fromARGB(126, 35, 151, 103),
          currentIndex: 0, // Set initial index
          onTap: (index) {
            if(index == 2){
               Navigator.of(context).pushNamed('addItemPage');
            }
          },
          // showSelectedLabels: false,
          // showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 25),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.my_location_outlined, size: 25),
              label: "Location",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/add.svg',
                height: 34,
                width: 34,
                fit: BoxFit.cover,
              ),
              label: "Post",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined, size: 25),
              label: "Chat",
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 2,
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

