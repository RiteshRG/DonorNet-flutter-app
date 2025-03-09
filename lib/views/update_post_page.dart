import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/post/post_validation.dart';
import 'package:donornet/services%20and%20provider/map_service.dart';
import 'package:donornet/services%20and%20provider/post_service.dart';
import 'package:donornet/services%20and%20provider/update_post_location_map.dart';
import 'package:donornet/services%20and%20provider/user_service.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/utilities/show_dialog.dart';
import 'package:donornet/views/post%20details/User_post_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'package:donornet/services%20and%20provider/map_service.dart';
import 'dart:developer' as devtools;

class UpadtePostPage extends StatefulWidget {
   final String postId;
    final GeoPoint? postLocation; // Accept postLocation
    UpadtePostPage({required this.postId, this.postLocation});

  @override
  _UpadtePostPageState createState() => _UpadtePostPageState();
}

class _UpadtePostPageState extends State<UpadtePostPage> {
late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final List<String> _categories = [
    'Food', 'Footwear', 'Furniture', 'Toy',
    'Pet Supply', 'Clothing and Textile', 'Sports Equipment', 'Stationery'
  ];
  String _selectedCategory = '';
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  DateTime? _expiryDate;
  TimeOfDay? _expiryTime;
  bool isLoading = false;
  bool isProcessing = false; 

  String title = "";
  String description = "";
  String imageUrl = "";
  DateTime? pickup_date_time;
  DateTime? expiryDate;
  String qrCode = "";
  late int categories;

                      
  LatLng? selectedLocation;

  void _handleLocationSelected(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    fetchPostDetails(); // Fetch data first, then assign values in fetchPostDetails()
  }


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchPostDetails() async {
  try {
    setState(() {
        isLoading = true;
      });
    List<Map<String, dynamic>> data = await PostService().getPostWithUserDetails(widget.postId);
    if (data.isNotEmpty) {
      var postData = data.first;

      setState(() {
        title = postData['post']['title'] ?? "No Title";
        description = postData['post']['description'] ?? "No Description";
        imageUrl = postData['post']['image_url'] ?? "";
        categories = postData['post']['category_id'] - 1;

        _selectedCategory = _categories[categories];
        
        pickup_date_time = (postData['post']['pickup_date_time'] as Timestamp).toDate();
        expiryDate = (postData['post']['expiry_date_time'] as Timestamp).toDate();
        // postLocation = postData['post']['location'];

        // Set text field values
        _titleController.text = title;
        _descriptionController.text = description;

        // Assign extracted date and time values
        _pickupDate = pickup_date_time;
        _pickupTime = TimeOfDay(hour: pickup_date_time!.hour, minute: pickup_date_time!.minute);
        _expiryDate = expiryDate;
        _expiryTime = TimeOfDay(hour: expiryDate!.hour, minute: expiryDate!.minute);
        devtools.log('$postData');

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  } catch (e) {
    print("Error fetching post details: $e");
    setState(() {
      isLoading = false;
    });
  }
}


  Future<void> _pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
      });
    }
  }


 Future<void> _selectDate(BuildContext context, bool isPickup) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPickup ? (_pickupDate ?? DateTime.now()) : (_expiryDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isPickup) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isPickup ? (_pickupTime ?? TimeOfDay.now()) : (_expiryTime ?? TimeOfDay.now()),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupTime = picked;
        } else {
          _expiryTime = picked;
        }
      });
    }
  }

  // Future<void> _selectDate(BuildContext context, bool isPickup) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime.now().add(Duration(days: 365)),
  //     builder: (BuildContext context, Widget? child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           primaryColor: AppColors.primaryColor,
  //           colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
  //           buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       if (isPickup) {
  //         _pickupDate = picked;
  //       } else {
  //         _expiryDate = picked;
  //       }
  //     });
  //   }
  // }

  // Future<void> _selectTime(BuildContext context, bool isPickup) async {
  //   final TimeOfDay? picked = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //     builder: (BuildContext context, Widget? child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           primaryColor: AppColors.primaryColor,
  //           colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
  //           buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       if (isPickup) {
  //         _pickupTime = picked;
  //       } else {
  //         _expiryTime = picked;
  //       }
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Post',
          style: TextStyle(
            shadows: [
              Shadow(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        elevation: 8.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.tertiaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Selection
                // GestureDetector(
                //   onTap: () => _showImagePickerOptions(context),
                //   child: Container(
                //     height: 200,
                //     decoration: BoxDecoration(
                //       color: Colors.grey[200],
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: _image == null
                //         ? Center(
                //             child: Icon(Icons.add_a_photo, size: 50, color: const Color.fromARGB(186, 38, 182, 122)),
                //           )
                //         : ClipRRect(
                //             borderRadius: BorderRadius.circular(10),
                //             child: Image.file(File(_image!.path), fit: BoxFit.cover),
                //           ),
                //   ),
                // ),
                GestureDetector(
                onTap: () => _showImagePickerOptions(context),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image == null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl.isNotEmpty
                              ? Image.network(imageUrl, fit: BoxFit.cover) // Correct way to load network image
                              : Center(
                                  child: Icon(Icons.add_a_photo, size: 50, color: Colors.green),
                                ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(_image!.path), fit: BoxFit.cover),
                        ),
                ),
              ),

                SizedBox(height: 16),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                       hintText: "Enter the title here",
                      labelStyle: TextStyle(color: Colors.black), 
                      floatingLabelStyle: TextStyle(color: AppColors.secondaryColor, fontSize: 18, fontWeight: FontWeight.w500), 
                      floatingLabelBehavior: FloatingLabelBehavior.always, 
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLength: 50,
                    onChanged: (value) {
                      title = value; // Update title variable when text changes
                    },
                  ),
                ),
                
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: "Provide details about the item, including pickup timing, quantity, condition, and any special instructions.",
                      labelStyle: TextStyle(color: Colors.black), 
                      floatingLabelStyle: TextStyle(color: AppColors.secondaryColor, fontSize: 18,fontWeight: FontWeight.w500), 
                      floatingLabelBehavior: FloatingLabelBehavior.always, 
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLength: 300,
                    maxLines: 5,
                    onChanged: (value) {
                    description = value; 
                  },
                  ),
                ),
                
                SizedBox(height: 16),
                
                  // Category Selection
                  Text('Select Category:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                  SizedBox(height: 8),
                  Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _categories.asMap().entries.map((entry) {
                    int index = entry.key;
                    String category = entry.value;

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: _selectedCategory == category
                            ? Colors.white
                            : const Color.fromARGB(255, 106, 106, 106),
                        backgroundColor: _selectedCategory == category
                            ? AppColors.primaryColor
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCategory = category;
                          categories = index; // Update selected index
                        });
                      },
                      child: Text(category),
                    );
                  }).toList(),
                ),
                
                SizedBox(height: 30),
                
                // Pickup Date and Time
                Text('Pickup Date and Time:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                        onPressed: () => _selectDate(context, true),
                        child: Text(_pickupDate == null ? 'Pick Date' : DateFormat('yyyy-MM-dd').format(_pickupDate!),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                        onPressed: () => _selectTime(context, true),
                        child: Text(_pickupTime == null ? 'Pick Time' : _pickupTime!.format(context),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                Text('Expiry Date and Time:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                        onPressed: () => _selectDate(context, false),
                        child: Text(_expiryDate == null ? 'Expiry Date' : DateFormat('yyyy-MM-dd').format(_expiryDate!),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                        onPressed: () => _selectTime(context, false),
                        child: Text(_expiryTime == null ? 'Expiry Time' : _expiryTime!.format(context),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
            
                SizedBox(height: 25),
                
                // Pickup Date and Time
                Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                SizedBox(height: 8),
                Container(
                height: 220, // Height for the map container
                width: double.infinity,// Make it as wide as the screen
                child: UpdateMapLocation(
                onLocationSelected: (LatLng selected) {
                  print("User selected location: $selected");
                  setState(() {
                    selectedLocation = selected; // Store the selected location
                  });
                },
                postLocation: widget.postLocation != null
                    ? LatLng(widget.postLocation!.latitude, widget.postLocation!.longitude)
                    : null, // Convert GeoPoint to LatLng
              ),
              ),
            
              SizedBox(height: 10),
            Text(
              selectedLocation != null
                  ? "User's selected location: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}"
                  : "Select a location",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            
                SizedBox(height: 38),
                
                // Post Button
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 50.0, 
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30), 
                      gradient: LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.tertiaryColor], 
                        begin: Alignment.topLeft, 
                        end: Alignment.bottomRight, 
                      ),
                    ),
                    child: ElevatedButton(
                        onPressed: isProcessing
                            ? null // Disable button if processing
                            : () async {
                                if (isProcessing) return; // Prevent duplicate submissions

                                setState(() {
                                  isProcessing = true;  // Prevent duplicate clicks
                                  isLoading = true;  // Show loading indicator
                                });

                                bool isValid = await validateAndSubmitPost(
                                  imageUrl: imageUrl,
                                  imageFile: _image,
                                  title: _titleController.text.trim(),
                                  description: _descriptionController.text.trim(),
                                  category: _selectedCategory,
                                  pickupDate: _pickupDate,
                                  pickupTime: _pickupTime,
                                  expiryDate: _expiryDate,
                                  expiryTime: _expiryTime,
                                  location: selectedLocation, 
                                  task: 'update',
                                  context: context, 
                                );

                                if (isValid) {
                                  bool isUpdated = await UserService().updatePost(
                                    postId: widget.postId,
                                    oldImageUrl: imageUrl,
                                    imageFile: _image,
                                    title: _titleController.text.trim(),
                                    description: _descriptionController.text.trim(),
                                    category: _selectedCategory,
                                    pickupDate: _pickupDate!,
                                    pickupTime: _pickupTime!,
                                    expiryDate: _expiryDate!,
                                    expiryTime: _expiryTime!,
                                    location: selectedLocation!, 
                                    context: context,
                                  );

                                  if (isUpdated) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Post Updated successfully!"), backgroundColor:AppColors.primaryColor),);
                                   Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => UserPostDetailPage(widget.postId)),
                                      (route) => false, // Removes all previous routes
                                    );

                                    // showSuccessDialog(context, "Your post has been submitted successfully!");
                                    print("Your post has been Updated successfully!");
                                  } else {
                                    showErrorDialog(context, "Something went wrong with Firebase, try again later.");
                                  }
                                } else {
                                  print("Post validation failed!");
                                }

                                //Reset state after process completion
                                setState(() {
                                  isProcessing = false; 
                                  isLoading = false; 
                                });
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isProcessing ? Colors.grey : Colors.transparent, // Disabled color
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white) // Show loading indicator when submitting
                            : Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                  )
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child:  LoadingIndicator(isLoading: isLoading),
          )
           
        ],
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
        currentIndex: 2, // Set initial index
          onTap: (index) {
            if(index == 0){
               Navigator.of(context).pushNamedAndRemoveUntil('homePageRoute', (route) => false,);
            }
            if(index == 3){
               Navigator.of(context).pushNamedAndRemoveUntil('chatPageRoute', (route) => false,);
            }
            if(index == 4){
               Navigator.of(context).pushNamedAndRemoveUntil('myProfilePageRoute', (route) => false,);
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

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primaryColor),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera, color: AppColors.primaryColor),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

}
