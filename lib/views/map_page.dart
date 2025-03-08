import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/map_service.dart';
import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, 
        height: double.infinity, 
        child: ShowMapService()
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
        currentIndex: 1, // Set initial index
          onTap: (index) {
            if(index == 2){
               Navigator.of(context).pushNamed('addItemPageRoute');
            }
            if(index == 3){
               Navigator.of(context).pushNamed('chatPageRoute');
            }
            if(index == 4){
               Navigator.of(context).pushNamed('myProfilePageRoute');
            }
            if(index == 0){
             Navigator.of(context).pushNamedAndRemoveUntil(
                'homePageRoute', 
                (Route<dynamic> route) => false,  
              );
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
}