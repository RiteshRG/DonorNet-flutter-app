import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PostItemPage extends StatefulWidget {
  @override
  _PostItemPageState createState() => _PostItemPageState();
}

class _PostItemPageState extends State<PostItemPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _categories = ['Food', 'Toy', 'Pet Supplies'];
  String _selectedCategory = '';
  final List<XFile?> _images = [];
  DateTime? _pickupDate;
  DateTime? _expiryDate;
  LatLng _selectedLocation = LatLng(37.7749, -122.4194); // Default location (e.g., San Francisco)

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile?> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        if (_images.length + selectedImages.length <= 5) {
          _images.addAll(selectedImages);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You can only upload up to 5 images.')),
          );
        }
      });
    }
  }

  Future<void> _pickDate({required bool isPickupDate}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isPickupDate) {
          _pickupDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  // Commented out Firebase functionality
  /*
  Future<void> _savePost() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedCategory.isEmpty ||
        _pickupDate == null ||
        _expiryDate == null ||
        _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and upload images.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'pickup_date': _pickupDate?.toIso8601String(),
        'expiry_date': _expiryDate?.toIso8601String(),
        'location': {'latitude': _selectedLocation.latitude, 'longitude': _selectedLocation.longitude},
        'images': _images.map((image) => image?.path).toList(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post uploaded successfully!')),
      );

      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading post. Please try again.')),
      );
    }
  }
  */

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _selectedCategory = '';
      _images.clear();
      _pickupDate = null;
      _expiryDate = null;
      _selectedLocation = LatLng(37.7749, -122.4194);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Donation Post'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            Text('Select Category:'),
            Wrap(
              spacing: 8.0,
              children: _categories.map((category) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    iconColor: _selectedCategory == category ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Text(category),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text('Upload Images:'),
            ElevatedButton(
              onPressed: _pickImages,
              child: Text('Pick Images (Up to 5)'),
            ),
            SizedBox(height: 10),
            Text('Pickup Date:'),
            ElevatedButton(
              onPressed: () => _pickDate(isPickupDate: true),
              child: Text(_pickupDate == null ? 'Select Pickup Date' : _pickupDate.toString()),
            ),
            SizedBox(height: 10),
            Text('Expiry Date:'),
            ElevatedButton(
              onPressed: () => _pickDate(isPickupDate: false),
              child: Text(_expiryDate == null ? 'Select Expiry Date' : _expiryDate.toString()),
            ),
            SizedBox(height: 10),
            Text('Select Location:'),
            Container(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation,
                  zoom: 12,
                ),
                onTap: (LatLng position) {
                  setState(() {
                    _selectedLocation = position;
                  });
                },
                markers: {
                  Marker(
                    markerId: MarkerId('selectedLocation'),
                    position: _selectedLocation,
                  ),
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // You can add custom save logic here if needed
                },
                child: Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
