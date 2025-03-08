import 'package:donornet/api.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateMapLocation extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  final LatLng? postLocation; // Post location from postData

  UpdateMapLocation({
    required this.onLocationSelected,
    this.postLocation, // Post location, optional
  });

  @override
  _UpdateMapLocationState createState() => _UpdateMapLocationState();
}

class _UpdateMapLocationState extends State<UpdateMapLocation> {
  late MapController mapController;
  LatLng? currentLocation;
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    mapController = MapController();

    if (widget.postLocation != null) {
      selectedLocation = widget.postLocation; // Set post location as initial
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        if (selectedLocation == null) {
          selectedLocation = currentLocation; // Fallback if post location is null
        }
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
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null && widget.postLocation == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      height: 300,
      width: double.infinity,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: selectedLocation ?? currentLocation!,
          initialZoom: 15.0,
          onTap: (tapPosition, latLng) {
            _updateMarkerLocation(latLng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/mapbox/outdoors-v11/tiles/{z}/{x}/{y}?access_token=${APIKey.mapBox}",
            additionalOptions: {'accessToken': APIKey.mapBox},
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
          ), // Blue for user's location
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
          ), // Red for post location
        ),
      );
    }

    return markers;
  }
}
