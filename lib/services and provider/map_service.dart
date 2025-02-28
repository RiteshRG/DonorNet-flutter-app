import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/api.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as devtools show log;
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapLocationService extends StatefulWidget {
  final Function(LatLng) onLocationSelected;  // Callback function

  MapLocationService({required this.onLocationSelected});

  @override
  _MapLocationServiceState createState() => _MapLocationServiceState();
}

class _MapLocationServiceState extends State<MapLocationService> {
  late MapController mapController;
  LatLng? currentLocation;  // To store the current location of the user
  LatLng? selectedLocation;  // To store the location where the user places the marker

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _getCurrentLocation();
  }

  // Request location permission and fetch user's current location
  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        selectedLocation = currentLocation;  
         widget.onLocationSelected(selectedLocation!);
      });
    } else {
      print("Location permission not granted");
    }
  }

  void _updateMarkerLocation(LatLng newLocation) {
    setState(() {
      selectedLocation = newLocation; 
    });
     widget.onLocationSelected(newLocation);

    print("Selected Location: Latitude: ${newLocation.latitude}, Longitude: ${newLocation.longitude}");
  }

 
  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return Center(child: LoadingIndicator(isLoading: true));
    }

    return Container(
      height: 300,
      width: double.infinity,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: currentLocation!,  
          initialZoom: 15.0,  
          minZoom: 5.0,
          maxZoom: 18.0,
          onTap: (tapPosition, latLng) {
            _updateMarkerLocation(latLng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/outdoors-v11/tiles/{z}/{x}/{y}?access_token=${APIKey.mapBox}",

            additionalOptions: {
              'accessToken': APIKey.mapBox,  
            },
          ),
          MarkerLayer(
            markers: _getMarkers(),  
          ),
        ],
      ),
    );
  }

  List<Marker> _getMarkers() {
    List<Marker> markers = [];

    if (currentLocation != null) {
      markers.add(
        Marker(
          point: currentLocation!,  
          width: 20,
          height: 20,
          child: Icon(
            Icons.location_history,
            color: AppColors.secondaryColor,
            size: 25,
          ),
        ),
      );
    }

    if (selectedLocation != null) {
      markers.add(
        Marker(
          point: selectedLocation!,  
          width: 40,
          height: 40,
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [const Color.fromARGB(255, 255, 0, 0), const Color.fromARGB(255, 176, 1, 1)],  
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Icon(
              Icons.location_on_rounded,
              color: Colors.white,  
              size: 40,
            ),
          ),
        ),
      );
    }

    return markers;
  }
}


class MapService {
  /// Calculates the distance between the user's location and a post's location in kilometers.
  double calculateDistance(Position userPosition, GeoPoint postLocation) {
    double distanceInMeters = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      postLocation.latitude,
      postLocation.longitude,
    );
    return distanceInMeters / 1000; // Convert meters to kilometers
  }

  List<Map<String, dynamic>> sortPostsByDistance(
      Position userPosition, List<Map<String, dynamic>> posts) {
    for (var post in posts) {
      if (post.containsKey('location') && post['location'] is GeoPoint) {
        // ✅ Convert distance to string with 1 decimal place
        double distance = calculateDistance(userPosition, post['location']);
        post['distance_km'] = distance.toStringAsFixed(1); // Store as String
      } else {
        post['distance_km'] = "9999.9"; // Set a very high distance if location is missing
      }
    }

    // ✅ Sort posts by parsed distance
    posts.sort((a, b) => double.parse(a['distance_km'])
        .compareTo(double.parse(b['distance_km'])));

    return posts;
  }
}
