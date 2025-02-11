import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/views/home%20page/drawer.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  final String profileImage;
  final String name;
  final String rating;

  const UserProfile({
    Key? key,
    required this.profileImage,
    required this.name,
    required this.rating,
  }) : super(key: key);


  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          Column(
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
                        child:Image.network(
                            "${widget.profileImage}", // Load from Firebase or any URL
                            opacity: AlwaysStoppedAnimation(0.1),
                            fit: BoxFit.cover,
                          )
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: (){
                                      Navigator.pop(context);
                                  },
                                  child: Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255)),
                                ),
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
                                child:  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(widget.profileImage),
                                  )
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
                            '${widget.name}',
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
                                '  ${widget.rating}',
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
         // LoadingIndicator(isLoading: isLoading,loaderColor: const Color.fromARGB(255, 235, 72, 72)),
        ],
      ),
    );
  }

  Widget _buildDonationsGrid(String section) {
    return  GridView.builder(
    padding: EdgeInsets.all(8),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
    ),
    itemCount: 3, // Show 2 images
    itemBuilder: (context, index) {
      List<String> imageUrls = [
        'https://storage.needpix.com/rsynced_images/old-jeans-3589262_1280.jpg',
        'https://i.etsystatic.com/8620333/r/il/43095d/1184899900/il_570xN.1184899900_71l0.jpg',
        'https://tse4.mm.bing.net/th?id=OIP.rnfpkchacq1HmYS6oiY3NwHaJ4&pid=Api&P=0&h=180'
      ];
      
      return GestureDetector(
      onTap: () {
      
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
          ),
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
    itemCount: 1, // Show 2 images
    itemBuilder: (context, index) {
      List<String> imageUrls = [
        'https://tse3.mm.bing.net/th?id=OIP.AkBJECD9LR5tjUnpIp1cfgHaFj&pid=Api&P=0&h=180',
      ];
      
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            imageUrls[index], // Display images dynamically
            fit: BoxFit.cover,
          ),
        ),
      );
    },
  );
}
}
