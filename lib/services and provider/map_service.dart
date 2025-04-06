import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/api.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services%20and%20provider/post_service.dart';
import 'package:donornet/services%20and%20provider/user_service.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/utilities/show_dialog.dart';
import 'package:donornet/views/post%20details/User_post_details.dart';
import 'package:donornet/views/post%20details/post_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as devtools show log;

import 'package:url_launcher/url_launcher.dart';



class ShowMapService extends StatefulWidget {
  const ShowMapService({super.key});

  @override
  State<ShowMapService> createState() => _ShowMapServiceState();
}

class _ShowMapServiceState extends State<ShowMapService> {
  late Future<List<Map<String, dynamic>>> availablePosts;
  Position? _currentPosition;
  // final String mapboxAccessToken = "YOUR_MAPBOX_ACCESS_TOKEN";

  @override
  void initState() {
    super.initState();
    availablePosts = PostService().getAvailablePostsLocation(); // Use PostService
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

void _showPostDetails(BuildContext context, Map<String, dynamic> post, Map<String, dynamic> posts) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return GestureDetector(
            onTap: () {
              final DateTime expiryDate = posts["expiry_date_time"] is Timestamp
              ? (posts["expiry_date_time"] as Timestamp).toDate()
              : DateTime.now();
              if (expiryDate.isAfter(DateTime.now())){
              if (UserService().isCurrentUser(post['user_id']?? 'Unknown')) {
                devtools.log("User can edit/delete this post.");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserPostDetailPage(post['postId'])),
                );
              } else {
                devtools.log("User can only view this post.");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostDetailsPage(post['postId'])),
                );
              }}else{
                showExpiryDialog(context);
              }
            },
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.black54], // Dark gradient background
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  posts['image_url'],
                  width: 120,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 80, color: Colors.white),
                ),
              ),
              SizedBox(width: 15),
              
              // Post Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      posts['title'],
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // SizedBox(height: 5),
                    // Text(
                    //   post['description'],
                    //   style: TextStyle(color: Colors.white70, fontSize: 14),
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    SizedBox(height: 10),
                    FutureBuilder<double?>(
                      future: MapService().calculateDistance(post['location']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            "📍 Calculating...",
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                          );
                        } else if (snapshot.hasError || snapshot.data == null) {
                          return Text(
                            "📍 -- km",
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                          );
                        } else {
                          return Text(
                            "📍 ${snapshot.data!.toStringAsFixed(2)} km",
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: availablePosts,
      builder: (context, snapshot) {
        if (!snapshot.hasData || _currentPosition == null) {
          return const Center(child: LoadingIndicator(isLoading: true));
        }

        List<Marker> markers = snapshot.data!.map((post) {
          GeoPoint location = post['location'];
          return Marker(
            point: LatLng(location.latitude, location.longitude),
            width: 50,
            height: 50,
            child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [AppColors.primaryColor, AppColors.tertiaryColor],  
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: GestureDetector(
              onTap: () async { // Ensure async is used for awaiting
              Map<String, dynamic>? posts = await PostService().getPostDetailsForMapPopUp(post['postId']); 
              if (posts != null) {
                Timestamp expiryTimestamp = posts["expiry_date_time"];
                DateTime expiryDate = expiryTimestamp.toDate(); // Convert Timestamp to DateTime
                DateTime now = DateTime.now();

                if (expiryDate.isBefore(now)) {
                  // Post is expired, show dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Post Expired"),
                        content: Text("This post is no longer available as it has already expired."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Post is still valid, show details
                  _showPostDetails(context, post, posts);
                }
              }
            },
              child: Icon(
              Icons.location_pin,
              color: Colors.white,  
              size: 50,
            ),
            ), 
          ),
          );
        }).toList();

        // Add user's current location marker
        markers.add(
          Marker(
            point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            width: 30,
            height: 30,
            child: const Icon(
              Icons.location_pin,
              color: Color.fromARGB(255, 248, 28, 28),
              size: 35,
            ),
          ),
        );

        return FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=${APIKey.mapBox}",
            ),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }
}



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
