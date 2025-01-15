import 'package:donornet/utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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
  final ImagePicker _picker = ImagePicker();

  // Function to handle image picking from camera or gallery
  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context); // Close the BottomSheet
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context); // Close the BottomSheet
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to pick image based on source
  Future<void> _pickImageFromSource(ImageSource source) async {
    // Request permissions for the required source
    PermissionStatus status = source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();

    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (_images.length < 5) {
            _images.add(image);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You can only upload up to 5 images.')),
            );
          }
        });
      }
    } else if (status.isPermanentlyDenied) {
      // Open app settings if permission is permanently denied
      openAppSettings();
    } else {
      permissionDialog(context, "Permission denied! Please grant access to continue.");
    }
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
                    backgroundColor: _selectedCategory == category ? Colors.blue : Colors.grey,
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
              onPressed: _showImagePickerOptions,
              child: Text('Pick Images (Up to 5)'),
            ),
            SizedBox(height: 10),
            
             _images.isEmpty
                ? Text(
                    'Add up to 5 images',
                    style: TextStyle(color: Colors.grey),
                  )
                : 
            Wrap(
              spacing: 8.0,
              children: _images.asMap().entries.map((entry) {
                int index = entry.key;
                XFile? image = entry.value;
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.file(
                        File(image!.path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _images.removeAt(index);
                          });
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.cancel,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Save logic
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
