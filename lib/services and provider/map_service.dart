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

import 'package:url_launcher/url_launcher.dart';


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

class MapBoxMapView extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapBoxMapView({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _MapBoxMapViewState createState() => _MapBoxMapViewState();
}

class _MapBoxMapViewState extends State<MapBoxMapView> {
  late final MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  // Function to open Google Maps with coordinates

void _openGoogleMaps(double lat, double lng) async {
  // Construct the URL to open Google Maps with the provided coordinates
  final Uri uri = Uri.https(
    'www.google.com', // Google domain
    '/maps',           // Path to maps
    {
      'q': '$lat,$lng',  // Query parameter for location
    },
  );

  try {
    // Launch the URL in an external browser
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      devtools.log("Could not open Google Maps");
    }
  } catch (e) {
    devtools.log("Error launching URL: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    final marker = Marker(
      point: LatLng(widget.latitude, widget.longitude),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () {
          devtools.log("Marker clicked at: ${widget.latitude}, ${widget.longitude}");
           _openGoogleMaps(widget.latitude, widget.longitude);
        },
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

    return Container(
      height: 200, // Increased for better zooming
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(widget.latitude, widget.longitude),
          initialZoom: 15.0,
          minZoom: 5.0,
          maxZoom: 20.0,
          onPositionChanged: (position, hasGesture) {
            if (hasGesture) {
              // Reset position to prevent movement
              mapController.move(LatLng(widget.latitude, widget.longitude), position.zoom);
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/mapbox/outdoors-v11/tiles/{z}/{x}/{y}?access_token=${APIKey.mapBox}",
            additionalOptions: {
              'accessToken': APIKey.mapBox,
            },
          ),
          MarkerLayer(
            markers: [marker],
          ),
        ],
      ),
    );
  }
}

class MapService {

Future<Position?> _getCurrentPosition() async {
  try {
    return await Geolocator.getCurrentPosition();
  } catch (e) {
    devtools.log("Error fetching location: $e");
    return null;
  }
}

/// Calculates the distance between the user's location and a post's location in kilometers.
Future<double?> calculateDistance(GeoPoint postLocation) async {
  Position? userPosition = await _getCurrentPosition(); // Await the position

  if (userPosition == null) {
    devtools.log("User location is unavailable. Cannot calculate distance.");
    return null; // Return null if the location is not available
  }

  double distanceInMeters = Geolocator.distanceBetween(
    userPosition.latitude,
    userPosition.longitude,
    postLocation.latitude,
    postLocation.longitude,
  );

  return distanceInMeters / 1000; // Convert meters to kilometers
}


  /// Sorts posts by distance and filters them based on the selected distance.
  Future<List<Map<String, dynamic>>> sortPostsByDistance(
    List<Map<String, dynamic>> posts, String selectedDistance) async {

  Position? userPosition = await _getCurrentPosition(); // Fetch user location

  if (userPosition == null) {
    devtools.log("User location is unavailable. Returning unsorted posts.");
    return posts; // Return original posts if location is unavailable
  }

  double maxDistance = _getMaxDistanceFromString(selectedDistance);
  List<Map<String, dynamic>> filteredPosts = [];

  for (var post in posts) {
    if (post.containsKey('location') && post['location'] is GeoPoint) {
      double? distance = await calculateDistance(post['location']); // Await async function

      if (distance == null) {
        post['distance_km'] = "9999.9"; // Assign a large value if distance calculation fails
      } else {
        post['distance_km'] = distance.toStringAsFixed(1);
      }

      // Add post if within the selected distance
      if (distance != null && distance <= maxDistance) {
        filteredPosts.add(post);
      }
    } else {
      post['distance_km'] = "9999.9"; // Assign large value if location is missing
      filteredPosts.add(post);
    }
  }

  // Sort posts by distance
  filteredPosts.sort((a, b) => double.parse(a['distance_km'])
      .compareTo(double.parse(b['distance_km'])));

  return filteredPosts;
}


  /// Convert the selected distance string to a numeric value in kilometers.
  double _getMaxDistanceFromString(String selectedDistance) {
    switch (selectedDistance) {
      case '1':
        return 1.0;
      case '5':
        return 5.0;
      case '10':
        return 10.0;
      case '20':
        return 20.0;
      case '50':
        return 50.0;
      case '100':
        return 100.0;
      case 'infinity':
        return double.infinity; // No distance limit (all posts are included)
      default:
        return double.infinity; // Default to 'infinity' if invalid value
    }
  }
}




// class MapService {
//   /// Calculates the distance between the user's location and a post's location in kilometers.
//   double calculateDistance(Position userPosition, GeoPoint postLocation) {
//     double distanceInMeters = Geolocator.distanceBetween(
//       userPosition.latitude,
//       userPosition.longitude,
//       postLocation.latitude,
//       postLocation.longitude,
//     );
//     return distanceInMeters / 1000; // Convert meters to kilometers
//   }

//   List<Map<String, dynamic>> sortPostsByDistance(
//       Position userPosition, List<Map<String, dynamic>> posts) {
//     for (var post in posts) {
//       if (post.containsKey('location') && post['location'] is GeoPoint) {
//         // ✅ Convert distance to string with 1 decimal place
//         double distance = calculateDistance(userPosition, post['location']);
//         post['distance_km'] = distance.toStringAsFixed(1); // Store as String
//       } else {
//         post['distance_km'] = "9999.9"; // Set a very high distance if location is missing
//       }
//     }

//     // ✅ Sort posts by parsed distance
//     posts.sort((a, b) => double.parse(a['distance_km'])
//         .compareTo(double.parse(b['distance_km'])));

//     return posts;
//   }
// }
