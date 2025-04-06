import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/services%20and%20provider/internet_checker.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/views/home%20page/drawer.dart';
import 'package:donornet/views/levels/howToEarnPoints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:donornet/materials/access_throught_link.dart';
import 'package:donornet/materials/app_colors.dart';


class MyLevelPage extends StatefulWidget {
  @override
  _MyLevelPageState createState() => _MyLevelPageState();
}

class _MyLevelPageState extends State<MyLevelPage> {
  int currentPoints = 0;
  int currentLevel = 0;
  int pointsToNextLevel = 10;
  bool isLoading = false; // Loading state
  bool isConnected = true; 

  final List<Map<String, dynamic>> levels = [
    {'level': 1, 'points': 10},
    {'level': 2, 'points': 40},
    {'level': 3, 'points': 90},
    {'level': 4, 'points': 150},
    {'level': 5, 'points': 225},
    {'level': 6, 'points': 300},
    {'level': 7, 'points': 500},
    {'level': 8, 'points': 800},
    {'level': 9, 'points': 1000},
    {'level': 10, 'points': 1500},
  ];

  @override
  void initState() {
    super.initState();
      _checkInternetStatus();
     InternetChecker.init((bool connected) {
      setState(() {
        isConnected = connected;
      });
    });
    fetchUserPointsAndLevel();
    updateLevel();
  }

  void dispose() {
    InternetChecker.dispose();
    super.dispose();
  }

    Future<void> _checkInternetStatus() async {
    isConnected = await InternetChecker.hasInternet();
    setState(() {});
  }


Future<void> fetchUserPointsAndLevel() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch user points from 'points' collection
    QuerySnapshot pointsSnapshot = await firestore
        .collection('points')
        .where('user_id', isEqualTo: user.uid)
        .limit(1)
        .get();

    int fetchedPoints = 0;
    if (pointsSnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = pointsSnapshot.docs.first;
      fetchedPoints = (doc['points_earned'] ?? 0).toInt();
    }

    // Fetch user level from 'levels' collection
    QuerySnapshot levelSnapshot = await firestore
        .collection('levels')
        .where('user_id', isEqualTo: user.uid)
        .limit(1)
        .get();

    int fetchedLevel = 0;
    int pointsRequired = 10; // Default to level 1 requirement

    if (levelSnapshot.docs.isNotEmpty) {
      DocumentSnapshot levelDoc = levelSnapshot.docs.first;
      fetchedLevel = (levelDoc['level'] ?? 0).toInt();
      pointsRequired = (levelDoc['points_required'] ?? 10).toInt();
    } else {
      // If no level document exists, create one for the user
      await firestore.collection('levels').add({
        'user_id': user.uid,
        'level': 0,
        'points_required': 10,
      });
    }

    // Update UI state
    setState(() {
      currentPoints = fetchedPoints;
      currentLevel = fetchedLevel;
      pointsToNextLevel = pointsRequired;
    });

    print("Fetched Points: $fetchedPoints, Level: $fetchedLevel, Points Required: $pointsRequired");

  } catch (e) {
    print("Error fetching user points and level: $e");
  }
}



  Future<void> _refreshPage() async {
  if (!mounted) return; // Prevents calling setState() on an unmounted widget

  setState(() {
    isLoading = true; // Show loading indicator
  });

  await fetchUserPointsAndLevel(); // Fetch latest points without restarting the page

  if (!mounted) return;

  setState(() {
    updateLevel(); 
    isLoading = false; // Hide loading indicator
  });

   Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => MyLevelPage()), // Replace with your page
  );
}



void updateLevel() {
  setState(() {
    currentLevel = 0; // Start at Level 0

    for (int i = 0; i < levels.length; i++) {
      if (currentPoints >= levels[i]['points']) {
        currentLevel = levels[i]['level']; // Assign max eligible level
      } else {
        break; // Stop once the required points exceed currentPoints
      }
    }
  });
}


double calculateProgress() {
  if (currentLevel == 0) {
    return currentPoints / levels[0]['points']; // Progress from Level 0 to 1
  }

  int prevPoints = (currentLevel > 0) ? levels[currentLevel - 1]['points'] : 0;
  int nextPoints = (currentLevel < levels.length) ? levels[currentLevel]['points'] : prevPoints;

  if (nextPoints == prevPoints) return 0.0; // Prevent division by zero

  double progress = (currentPoints - prevPoints) / (nextPoints - prevPoints);
  return progress.clamp(0.0, 1.0);
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.tertiaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Text(
              'My Level',
              style: TextStyle(
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            elevation: 5,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.white), // Set the back arrow icon color to white
          ),
        ),
      ),
      drawer: CustomDrawer(),
      backgroundColor: Colors.white,
      body: !isConnected ? _buildNoInternetWidget(): Stack(
        children: [

          RefreshIndicator(
            color: AppColors.primaryColor, 
            backgroundColor: Colors.white,  
            onRefresh: _refreshPage,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildCurrentLevel(),
                    const SizedBox(height: 40),
                       Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 10,),
                        Text(
                          'Level',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Points',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10,),
                      ],
                    ),
                    _buildLevelList(),
                    const SizedBox(height: 5),
                    _buildHowToGetPoints(),
                    // const SizedBox(height: 20),
                    //_buildAddPointsButton(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
          top: 20, // Adjust vertical position
          left: 0, // Align to left side
          child: Container(
            padding: EdgeInsets.only(top: 6,left: 5,bottom: 6,right: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 0, 0, 0),const Color.fromARGB(255, 0, 0, 0)], 
                begin: Alignment.topLeft,  
                end: Alignment.bottomRight, 
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.zero,          
                topRight: Radius.circular(20), 
                bottomLeft: Radius.circular(0), 
                bottomRight: Radius.circular(20), 
              ),
              //border: Border.all(color: Colors.amber, width: 2), 
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Keeps content compact
              children: [
               Image.network(
                  '${AccessLink.coinGolden}',  
                  height: 22,
                  width: 22,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.copyright_outlined, // Fallback icon
                      size: 22,
                      color: Colors.grey, // Optional color
                    );
                  },
                ),
 // Coin icon
                SizedBox(width: 10),
                Text(
                  '${currentPoints}', 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
          if (isLoading) LoadingIndicator(isLoading: isLoading, loaderColor: AppColors.secondaryColor),
        ],
      ),
    );
  }

      // Widget for "No Internet Connection"
 Widget _buildNoInternetWidget() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.wifi_off, size: 60, color: const Color.fromARGB(128, 38, 182, 122)),
        SizedBox(height: 8),
        Text(
          "No Internet Connection",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color.fromARGB(128, 38, 182, 122)),
        ),
        SizedBox(height: 4),
        Text(
          "Please check your connection and try again.",
          style: TextStyle(fontSize: 14, color: const Color.fromARGB(146, 158, 158, 158)),
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
            bool isConnected = await InternetChecker.hasInternet();
            if (isConnected) {
              // Restart the page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyLevelPage()), // Replace with your actual page
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Still no internet connection. Please try again later."),backgroundColor:const Color.fromARGB(255, 222, 78, 78)),
              );
            }
          },
          icon: Icon(Icons.refresh, color: Colors.white,),
          label: Text("Retry"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 38, 182, 122), // Button color
            foregroundColor: Colors.white, // Text & icon color
          ),
        ),
      ],
    ),
  );
}


  Widget _buildCurrentLevel() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Show an icon if level is 0, otherwise show the level image
            currentPoints < 10 
                ? Icon(
                    Icons.emoji_events_outlined, // Use an appropriate icon
                    size: 120,
                    color: Colors.grey[400], // Customize the icon color
                  )
                : Image.network(
                    AccessLink.getLevelImage(currentLevel),
                    height: 120,
                    width: 120,
                    errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.emoji_events_outlined, // Fallback icon
                      size: 120,
                      color: Colors.grey, // Optional color
                    );
                  },
                  ),
          ],
        ),
        const SizedBox(height: 16),
         Text(
          currentPoints < 10 ? 'Level 0' : 'Level $currentLevel',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: calculateProgress(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
        (currentPoints < levels[0]['points'])
            ? '${pointsToNextLevel} points to Level 1'
            : (currentLevel < levels.length)
                ? '${pointsToNextLevel} points to Level ${currentLevel + 1}'
                : 'Max Level Reached!',
        style: TextStyle(color: Colors.grey[600], fontSize: 16),
      ),
      ],
    );
  }

  Widget _buildLevelList() {
    return Column(
      children: levels.map((level) {
        bool isCurrent = level['level'] == currentLevel;
        return Opacity(
          opacity: isCurrent ? 1.0 : 0.3,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Image.network(
                  AccessLink.getLevelImage(level['level']),
                  height: 50,
                  width: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.emoji_events_rounded, // Fallback icon
                      size: 50,
                      color: Colors.grey, // Optional color
                    );
                  },
                ),
                const SizedBox(width: 16),
                Text(
                  'Level ${level['level']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                Image.network(
                  '${AccessLink.coinBlack}',  
                  height: 22,
                  width: 22,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.copyright_outlined, // Fallback icon
                      size: 22,
                      color: const Color.fromARGB(255, 183, 139, 18), // Optional color
                    );
                  },
                ),
                const SizedBox(width: 16),
                Text(
                  '${level['points']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHowToGetPoints() {
    return  InkWell(
      onTap: () {
        // Handle how to get points
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: (){
                 Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => HowToEarnPage()));
              },
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: const Color.fromARGB(115, 15, 119, 125),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'How to get points?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,color: AppColors.secondaryColor
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.tertiaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointRule(String description, int points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 10),
          Expanded(child: Text(description)),
          Text("+$points pts", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAddPointsButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isLoading = true;
        });

        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            currentPoints += 10;
            updateLevel();
            isLoading = false;
          });
        });
      },
      child: Text('Add 10 Points'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
    );
  }
}
