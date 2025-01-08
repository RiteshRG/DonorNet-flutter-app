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
                gradient: LinearGradient(
                  colors: [const Color.fromARGB(240, 15, 119, 125), AppColors.primaryColor], 
                  begin: Alignment.topLeft,  
                  end: Alignment.bottomRight, 
                ),
              ),
            ),
          ),
          // Content Layer

          SafeArea(
            child: Stack(
              children: [
                 Container(
                  width: double.infinity,
                    height:140,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 0, 0, 0), 
                    borderRadius: BorderRadius.only(   
                      bottomLeft: Radius.circular(20), 
                      bottomRight: Radius.circular(70), 
                    ),
                    gradient: LinearGradient(
                      colors: [const Color.fromARGB(240, 15, 119, 125), AppColors.primaryColor], 
                      begin: Alignment.topLeft,  
                      end: Alignment.bottomRight, 
                    ),
                  ),
                ),
                Column(
                  children: [
                    // Custom AppBar
                    Container(
                      alignment: Alignment.topLeft,    
                      padding: const EdgeInsets.only(top: 15, bottom: 15,left: 15),
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
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 4,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 147, 147, 147),
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
                                color: AppColors.secondaryColor,
                                 gradient: LinearGradient(
                                  colors: [const Color.fromARGB(240, 15, 119, 125), AppColors.primaryColor], 
                                  begin: Alignment.topLeft,  
                                  end: Alignment.bottomRight, 
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: Offset(1, 4),
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
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  "P",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text("Post Title $index"),
                              subtitle: Text("Description of the post goes here."),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // Handle post tap
                              },
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
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, -1),
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
          showSelectedLabels: false,
          showUnselectedLabels: false,
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
                width: 28,
                height: 28,
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