
import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
       child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Text(
                'Onkar Sharma',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
             SizedBox(height: 5.0),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Update the UI based on the selection
                Navigator.pop(context);
              },
            ),
             SizedBox(height: 5.0),
            ListTile(
              leading: Icon(Icons.auto_graph_rounded),
              title: Text('My Levels'),
              onTap: () {
                // Update the UI based on the selection
                Navigator.pop(context);
              },
            ),
             SizedBox(height: 5.0),
            ListTile(
              leading: Icon(Icons.qr_code_scanner),
              title: Text('Scan & Collect'),
              onTap: () {
                // Update the UI based on the selection
                Navigator.pop(context);
              },
            ),
             SizedBox(height: 5.0),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account'),
              onTap: () {
                // Update the UI based on the selection
                Navigator.pop(context);
              },
            ),

             SizedBox(height: 5.0),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notification Settings'),
              onTap: () {
                // Update the UI based on the selection
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 5.0),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About Us'),
              onTap: () {
                // Update the UI based on the selection
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 20.0),
          ],
        ),
      
    );
  }
}