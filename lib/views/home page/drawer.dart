
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/user_provider.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});
  static const Color leadingColor = Color.fromARGB(255, 116, 116, 116); 
  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;
    final isLoading = userProvider.isLoading;
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.secondaryColor], // Define your gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color.fromARGB(255, 101, 101, 101), // Fallback background color
                  backgroundImage: userData != null && userData['profile_image'] != null
                      ? NetworkImage(userData['profile_image'],) // Correct way to use NetworkImage
                      : null, 
                  child: userData == null || userData['profile_image'] == null
                      ? Icon(Icons.person, color: Colors.white, size: 30) // Default icon if no image
                      : null, // No child if image is available
                ),
                SizedBox(height: 10),
                Text(
                  '${userData?['first_name']} ${userData?['last_name']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Icon(Icons.volunteer_activism, color: Colors.white, size: 20),
                    SizedBox(width: 5),
                    Text(
                      'Donations: 25', // Replace with dynamic count
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            LoadingIndicator(isLoading: isLoading, loaderColor: const Color.fromARGB(255, 255, 255, 255)),
          ],
        ),
      ),

      ListTile(
        leading: Icon(Icons.home, color: CustomDrawer.leadingColor),
        title: Text('Home', style: TextStyle(color: CustomDrawer.leadingColor)),
        onTap: () {
          Navigator.of(context).pushNamedAndRemoveUntil('homePageRoute', (route) => false,);
        },
      ),
      ListTile(
        leading: Icon(Icons.auto_graph_rounded, color: CustomDrawer.leadingColor),
        title: Text('My Levels', style: TextStyle(color: CustomDrawer.leadingColor)),
        onTap: () {
          Navigator.of(context).pushNamed('myLevelPageRoute');
        },
      ),
      ListTile(
        leading: Icon(Icons.qr_code_scanner, color: CustomDrawer.leadingColor),
        title: Text('Scan & Collect', style: TextStyle(color: CustomDrawer.leadingColor)),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Icon(Icons.account_circle, color: CustomDrawer.leadingColor),
        title: Text('Account', style: TextStyle(color: CustomDrawer.leadingColor)),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Icon(Icons.notifications, color: CustomDrawer.leadingColor),
        title: Text('Notification Settings', style: TextStyle(color: CustomDrawer.leadingColor)),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Icon(Icons.info, color: CustomDrawer.leadingColor),
        title: Text('About Us', style: TextStyle(color: CustomDrawer.leadingColor)),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.logout, color: Colors.red),
        title: Text('Logout', style: TextStyle(color: Colors.red)),
        onTap: () {
          Provider.of<UserProvider>(context, listen: false).logoutUser(context);
        },
      ),
    ],
  ),
);

  }
}