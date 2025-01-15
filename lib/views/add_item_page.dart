import 'package:donornet/materials/app_colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? expiryDate; 
  final _titleMaxLength = 50;
  final _descriptionMaxLength = 300;
  final List<String> _categories = ['Food', 'Toy', 'Pet Supplies', 'Clothing and Textiles', 'Footwear', 'Furniture', 'Sports Equipment'];
  String _selectedCategory = '';

   
  // Function to show date picker for selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  // Function to show date picker for expiry date
  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: expiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != expiryDate)
      setState(() {
        expiryDate = picked;
      });
  }

  // Function to show time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }


  @override
  Widget build(BuildContext context) {
    String formattedDate = selectedDate == null
    ? 'Pick Date'
    : DateFormat('yyyy-MM-dd').format(selectedDate!);

     String formattedExpiryDate = expiryDate == null
        ? 'Pick Expiry Date'
        : DateFormat('yyyy-MM-dd').format(expiryDate!);

    return Scaffold(
     appBar: AppBar(
        title: Text(
          'Add Items',
          style: TextStyle(
            shadows: [
              Shadow(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2), // Shadow color and transparency
                offset: Offset(2, 2), // Position of the shadow
                blurRadius: 4, // Spread of the shadow
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
        elevation: 8.0, // Shadow intensity for the AppBar itself
        backgroundColor: AppColors.primaryColor, // Optional: Customize background color
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), // Bottom-left corner rounded
            bottomRight: Radius.circular(20), // Bottom-right corner with no rounding
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              //color: Colors.amber,
              height: 120,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                                // setState(() {
                                //   _images.removeAt(index);
                                // });
                              },
                      child: DottedBorder(
                        color: const Color.fromARGB(200, 38, 182, 122), // Border color
                        strokeWidth: 2, // Width of the border
                        dashPattern: [6, 3], // Length and gap of dashes
                        borderType: BorderType.RRect, // Border shape (Rect, RRect, Oval)
                        radius: Radius.circular(20), 
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            //color: Colors.red,
                          ),
                          child: Icon(Icons.add_a_photo_outlined,
                          color: const Color.fromARGB(148, 15, 119, 125),
                          size: 45,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15,),
                    Wrap(
                      spacing: 10,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                        children: [
                            ClipRRect(
                            //padding: const EdgeInsets.only(top: 8.0),
                              borderRadius: BorderRadius.circular(20.0),
                            child: Image.network('https://d3s3zh7icgjwgd.cloudfront.net/AcuCustom/Sitename/DAM/267/King-Charles-by-Mark-Harrison.jpg',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: GestureDetector(
                              onTap: () {
                                // setState(() {
                                //   _images.removeAt(index);
                                // });
                              },
                              child: Icon(
                                Icons.cancel,
                                color: const Color.fromARGB(186, 255, 255, 255),
                                size: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                        Stack(
                        children: [
                            ClipRRect(
                            //padding: const EdgeInsets.only(top: 8.0),
                              borderRadius: BorderRadius.circular(10.0),
                            child: Image.network('https://d3s3zh7icgjwgd.cloudfront.net/AcuCustom/Sitename/DAM/267/King-Charles-by-Mark-Harrison.jpg',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: GestureDetector(
                              onTap: () {
                                // setState(() {
                                //   _images.removeAt(index);
                                // });
                              },
                              child: Icon(
                                Icons.cancel,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                        Stack(
                        children: [
                            ClipRRect(
                            //padding: const EdgeInsets.only(top: 8.0),
                              borderRadius: BorderRadius.circular(10.0),
                            child: Image.network('https://d3s3zh7icgjwgd.cloudfront.net/AcuCustom/Sitename/DAM/267/King-Charles-by-Mark-Harrison.jpg',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: GestureDetector(
                              onTap: () {
                                // setState(() {
                                //   _images.removeAt(index);
                                // });
                              },
                              child: Icon(
                                Icons.cancel,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                        Stack(
                          children: [
                             ClipRRect(
                              //padding: const EdgeInsets.only(top: 8.0),
                               borderRadius: BorderRadius.circular(10.0),
                              child: Image.network('https://d3s3zh7icgjwgd.cloudfront.net/AcuCustom/Sitename/DAM/267/King-Charles-by-Mark-Harrison.jpg',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 5,
                              top: 5,
                              child: GestureDetector(
                                onTap: () {
                                  // setState(() {
                                  //   _images.removeAt(index);
                                  // });
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 28,),
            Text("Title",
            style: TextStyle(
              fontSize: 18,
            ),
            ),
            SizedBox(height: 9,),
            TextField(
              controller: title,
              maxLength: _titleMaxLength,
              decoration: InputDecoration(
                counterText: '${title.text.length} / ${_titleMaxLength}',
                counterStyle: TextStyle(
                  color: title.text.length > _titleMaxLength ? Colors.red : Colors.grey,
                  fontSize: 10,
                ),
                floatingLabelStyle: TextStyle(
                fontSize: 15,
                color: AppColors.secondaryColor,
              ),
              hintText: "Enter the title here",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            ),
            style: TextStyle(
              fontSize: 15, 
            ),
            obscureText: false,
            onChanged: (value) {
                if (value.length > _titleMaxLength) {
                  // Trim the text to the maximum allowed length
                  title.text = value.substring(0, _titleMaxLength);
                  title.selection = TextSelection.fromPosition(
                    TextPosition(offset: _titleMaxLength),
                  );
                }
                setState(() {});
              }
            ),
            
            SizedBox(height: 15,),
            Text("Description",
            style: TextStyle(
              fontSize: 18,
            ),
            ),
            SizedBox(height: 9,),
            TextField(
              maxLines: 5,
              controller: description,
              maxLength: _descriptionMaxLength,
              decoration: InputDecoration(
                counterText: '${title.text.length} / ${_descriptionMaxLength}',
                counterStyle: TextStyle(
                  color: title.text.length > _descriptionMaxLength ? Colors.red : Colors.grey,
                  fontSize: 10,
                ),
                floatingLabelStyle: TextStyle(
                fontSize: 15,
                color: AppColors.secondaryColor,
              ),
              hintText: "Provide details about the item, including pickup timing, quantity, condition, and any special instructions.",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            ),
            style: TextStyle(
              fontSize: 15, 
            ),
            obscureText: false,
            onChanged: (value) {
                if (value.length > _descriptionMaxLength) {
                  // Trim the text to the maximum allowed length
                  title.text = value.substring(0, _descriptionMaxLength);
                  title.selection = TextSelection.fromPosition(
                    TextPosition(offset: _descriptionMaxLength),
                  );
                }
                setState(() {});
              }
            ),
            
            SizedBox(height: 15,),
             Text("Choose Category",
            style: TextStyle(
              fontSize: 18,
            ),),
            SizedBox(height: 9,),
             Wrap(
              spacing: 8.0, // Space between the buttons
              children: _categories.map((category) {
                Color backgroundColor;
                Color textColor;
                // Use if-else to set the background color
                if (_selectedCategory == category) {
                  backgroundColor = AppColors.primaryColor;
                  textColor = Colors.white;
                } else {
                  backgroundColor = const Color.fromARGB(255, 217, 217, 217);
                  textColor = const Color.fromARGB(255, 106, 106, 106);
                }

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: textColor,
                    backgroundColor: backgroundColor, // Apply the background color
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

            //Pick up Date & Time*******
            SizedBox(height: 28,),
            Text("Pick up Date & Time",
            style: TextStyle(
              fontSize: 18,
            ),),
             SizedBox(height: 9),
              Column(
              children: [
                // Date Picker
                Container(
                  width: 250,
                  child: ListTile(
                    tileColor: const Color.fromARGB(187, 35, 151, 103),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2000),
                    ),
                    title: Text(
                      formattedDate, // Use the formatted date string here
                      style: TextStyle(
                        fontSize: 16,
                       // fontWeight: FontWeight.w500,
                        color: selectedDate == null
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: selectedDate == null
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(255, 255, 255, 255),
                    ),
                    onTap: () => _selectDate(context), // Ensure setState is called here to update the UI
                  ),
                ),
                SizedBox(height: 10), // Space between date and time picker
                // Time Picker
                Container(
                  width: 250,
                  child: ListTile(
                    tileColor: const Color.fromARGB(187, 35, 151, 103),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2000),
                    ),
                    title: Text(
                      selectedTime == null
                          ? 'Pick Time'
                          : 'Time: ${selectedTime!.format(context)}',
                      style: TextStyle(
                        fontSize: 16,
                        //fontWeight: FontWeight.w500,
                        color: selectedTime == null
                            ? Colors.white
                            : const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    trailing: Icon(
                      Icons.access_time,
                      color: selectedTime == null
                          ? Colors.white
                          : const Color.fromARGB(255, 255, 255, 255),
                    ),
                    onTap: () => _selectTime(context), // Ensure setState is called here to update the UI
                  ),
                ),
              ],
            ),             

            //Expiry Date*******
            SizedBox(height: 18,),
            Text("Expiry Date",
            style: TextStyle(
              fontSize: 18,
            ),),
             SizedBox(height: 9),
             Container(
              width: 250,
              child: ListTile(
                tileColor: const Color.fromARGB(187, 35, 151, 103),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2000),
                ),
                title: Text(
                  formattedExpiryDate, // Use the formatted expiry date string here
                  style: TextStyle(
                    fontSize: 16,
                    //fontWeight: FontWeight.w400,
                    color: expiryDate == null
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                trailing: Icon(
                  Icons.calendar_today,
                  color: expiryDate == null
                      ? Colors.white
                      : const Color.fromARGB(255, 255, 255, 255),
                ),
                onTap: () => _selectExpiryDate(context), // Ensure setState is called here to update the UI
              ),
            ),
            SizedBox(height: 20), // Space between expiry date and time picker
            // Time Picker
            Container(
              width: 250,
              child: ListTile(
                tileColor: const Color.fromARGB(187, 35, 151, 103),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2000),
                ),
                title: Text(
                  selectedTime == null
                      ? 'Pick Time'
                      : 'Time: ${selectedTime!.format(context)}',
                  style: TextStyle(
                    fontSize: 16,
                    //fontWeight: FontWeight.w500,
                    color: selectedTime == null
                        ? Colors.white
                        : const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                trailing: Icon(
                  Icons.access_time,
                  color: selectedTime == null
                      ? Colors.white
                      : const Color.fromARGB(255, 255, 255, 255),
                ),
                onTap: () => _selectTime(context), // Ensure setState is called here to update the UI
              ),
            ),

            SizedBox(height: 28,),
            Text("Your Location",
            style: TextStyle(
              fontSize: 18,
            ),),
          ],
        ),
      ),
    );
  }
}