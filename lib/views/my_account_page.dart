import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/user_provider.dart';
import 'package:donornet/views/home%20page/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    return Scaffold(
      backgroundColor: Colors.white,
       key: _scaffoldKey,
      drawer: CustomDrawer(),
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white), // Back Arrow
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'My Account',
            style: TextStyle(
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.menu, color: Colors.white), 
              onPressed: () {
                 _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
          elevation: 5,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
    ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    // Handle logout
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              
              // Profile Image
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Stack(
                  children: [
                    Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor, // Border color
                        width: 3, // Border thickness
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60, // Adjust according to your need
                      backgroundColor: const Color.fromARGB(255, 101, 101, 101), // Fallback background color
                      backgroundImage: userData != null && userData['profile_image'] != null
                          ? NetworkImage(userData['profile_image']) // Load network image
                          : null, 
                      child: userData == null || userData['profile_image'] == null
                          ? Icon(Icons.person, color: Colors.white, size: 60) // Default icon if no image
                          : null, // No child if image is available
                    ),
                  ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle save changes logic
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, color:AppColors.primaryColor),
                        ),
                      ),
                    ),

                    SizedBox(height: 10,),
          
              // Form Fields
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'First Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                     TextField(
                      controller: TextEditingController(text: userData?['first_name'] ?? ''), // Set initial text
                      readOnly: true, // Makes it non-editable
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Last Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: userData?['last_name'] ?? ''), // Set initial text
                      readOnly: true, // Makes it non-editable
                      decoration: InputDecoration(
                        hintText: 'Enter last name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: userData?['email'] ?? ''), // Set initial text
                      readOnly: true, // Makes it non-editable
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}