import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/services/map_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'package:donornet/services/map_service.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _categories = [
    'Food', 'Toy', 'Pet Supplies', 'Clothing and Textiles',
    'Footwear', 'Furniture', 'Sports Equipment'
  ];
  String _selectedCategory = '';
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  DateTime? _expiryDate;
  TimeOfDay? _expiryTime;

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
      initialDate: DateTime.now(),
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
      initialTime: TimeOfDay.now(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Items',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Selection
            GestureDetector(
              onTap: () => _showImagePickerOptions(context),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _image == null
                    ? Center(
                        child: Icon(Icons.add_a_photo, size: 50, color: const Color.fromARGB(186, 38, 182, 122)),
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
              ),
            ),
            
            SizedBox(height: 16),
            
            // Category Selection
            Text('Select Category:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _categories.map((category) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: _selectedCategory == category ? Colors.white : const Color.fromARGB(255, 106, 106, 106), backgroundColor: _selectedCategory == category ?AppColors.primaryColor : Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                    style: TextStyle(color: Colors.white),),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                    onPressed: () => _selectTime(context, true),
                    child: Text(_pickupTime == null ? 'Pick Time' : _pickupTime!.format(context),
                    style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Expiry Date and Time
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
            child:MapLocationService(),
          ),

            SizedBox(height: 38),
            
            // Post Button
            Center(
              child: Container(
                width: double.infinity, // You can change this depending on your layout needs
                height: 50.0, // Adjust the height of the button
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.tertiaryColor], // Gradient colors (purple gradient)
                    begin: Alignment.topLeft, // Gradient starts from the top left
                    end: Alignment.bottomRight, // Gradient ends at the bottom right
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Make the button background transparent
                    shadowColor: Colors.transparent, // Remove shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                  ),
                  child: Text(
                    'Post', // Button text
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 18.0, // Text size
                      fontWeight: FontWeight.bold, // Text boldness
                    ),
                  ),
                ),
              )
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: const Color.fromARGB(126, 35, 151, 103),
          currentIndex: 2, // Set initial index
          onTap: (index) {
            if(index == 0){
               Navigator.of(context).pushNamedAndRemoveUntil('homePageRoute', (route) => false,);
            }
          },
          // showSelectedLabels: false,
          // showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 25),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.my_location_outlined, size: 25),
              label: "Location",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/add.svg',
                height: 34,
                width: 34,
                fit: BoxFit.cover,
              ),
              label: "Post",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined, size: 25),
              label: "Chat",
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 2,
                      offset: Offset(0, 2),
                    )
                  ],
                  image: DecorationImage(
                    image: AssetImage('assets/profile_4.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              label: "Profile",
            ),
          ],
          selectedLabelStyle: TextStyle(
            fontSize: 10, 
            color: AppColors.tertiaryColor,
            //fontWeight: FontWeight.bold, // Optional for bold text
          ),
          unselectedLabelStyle: TextStyle(
          fontSize: 9, 
          color: AppColors.tertiaryColor,
            //fontWeight: FontWeight.normal, // Optional for normal text
          ),
        ),
      ),
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

  void _submitPost() {
    // Implement your post submission logic here
    print('Submitting post...');
  }
}


