import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/user_provider.dart';
import 'package:donornet/views/home%20page/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile_page extends StatefulWidget {
  @override
  _Profile_pageState createState() => _Profile_pageState();
}

class _Profile_pageState extends State<Profile_page> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    @override
  void initState() {
    super.initState();
    // Fetch user data when the screen is initialized
    Provider.of<UserProvider>(context, listen: false).fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;
    final isLoading = userProvider.isLoading;
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      body: Column(
        children: [
          // Profile Header Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.tertiaryColor,
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    child: userData != null && userData['profile_image'] != null
                    ? Image.network(
                        userData['profile_image'], // Load from Firebase or any URL
                        opacity: AlwaysStoppedAnimation(0.1),
                        fit: BoxFit.cover,
                      )
                    : SizedBox(),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.mode_edit_outline_outlined, color: Colors.white, size: 25,),
                            InkWell(
                              onTap: (){
                                  _scaffoldKey.currentState?.openDrawer();
                              },
                              child: Icon(Icons.menu,
                            color: Colors.white,
                            ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromARGB(255, 197, 223, 212), // White border color
                                width: 2.0, // Border thickness
                              ),
                            ),
                            child:  userData != null && userData['profile_image'] != null
                            ? CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(userData['profile_image'],),
                              )
                            : CircleAvatar(
                                radius: 50,
                                child: Icon(Icons.person, size: 50),
                              ),
                          ),
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(0, 255, 153, 0),
                                borderRadius: BorderRadius.all(Radius.circular(100)),
                                 boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1), // Shadow color
                                    spreadRadius: 0, // How much the shadow spreads
                                    blurRadius: 0.5, // How blurry the shadow is
                                    offset: Offset(0, 3), // Shadow position (x, y)
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/level_1-removebg-preview.png',
                                height: 40,
                              width: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        '${userData?['first_name']} ${userData?['last_name']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Level 1',
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(
                            '  4.5',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tabs Section
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Pending Donations'),
                      Tab(text: 'Claimed Donations'),
                    ],
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor:  AppColors.secondaryColor,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildDonationsGrid('Pending Donations'),
                        _buildDonationsClaimedGrid('Claimed Donations'),
                      ],
                    ),
                  ),
                ],
              ),
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
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child:BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
         unselectedItemColor:const Color.fromARGB(179, 55, 170, 122),
        currentIndex: 4, // Set initial index
          onTap: (index) {
            if(index == 0){
               Navigator.of(context).pushNamedAndRemoveUntil('homePageRoute', (route) => false,);
            }
            if(index == 2){
               Navigator.of(context).pushNamed('addItemPageRoute');
            }
            if(index == 3){
               Navigator.of(context).pushNamedAndRemoveUntil('chatPageRoute', (route) => false,);
            }
          },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: ''),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.tertiaryColor], 
                    begin: Alignment.topLeft, 
                    end: Alignment.bottomRight,
                ), 
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      )),
    );
  }

  Widget _buildDonationsGrid(String section) {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6), // Apply the same border radius
            child: Image.network(
              'https://tse3.mm.bing.net/th?id=OIP.Z5u14eLiITHl-BGxhe6jYQHaFh&pid=Api&P=0&h=180',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  
  Widget _buildDonationsClaimedGrid(String section) {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6), // Apply the same border radius
            child: Image.network(
              'https://collectmyclothes.co.uk/wp-content/uploads/2019/11/donation.jpg',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
