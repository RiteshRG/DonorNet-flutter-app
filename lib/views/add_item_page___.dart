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
  TimeOfDay? selectExpiryTime;
  final _titleMaxLength = 50;
  final _descriptionMaxLength = 300;
  final List<String> _categories = ['Food', 'Toy', 'Pet Supplies', 'Clothing and Textiles', 'Footwear', 'Furniture', 'Sports Equipment'];
  String _selectedCategory = '';

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

  Future<void> _selectExpiryTime(BuildContext context) async {
    final TimeOfDay? expiryTimePicked = await showTimePicker(
      context: context,
      initialTime: selectExpiryTime ?? TimeOfDay.now(),
    );
    if (expiryTimePicked != null && expiryTimePicked != selectExpiryTime)
      setState(() {
        selectExpiryTime = expiryTimePicked;
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
                AppColors.secondaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              height: 120,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle image addition
                      },
                      child: DottedBorder(
                        color: const Color.fromARGB(200, 38, 182, 122),
                        strokeWidth: 2,
                        dashPattern: [6, 3],
                        borderType: BorderType.RRect,
                        radius: Radius.circular(20),
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            color: const Color.fromARGB(148, 15, 119, 125),
                            size: 45,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Wrap(
                      spacing: 10,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.network(
                                'https://d3s3zh7icgjwgd.cloudfront.net/AcuCustom/Sitename/DAM/267/King-Charles-by-Mark-Harrison.jpg',
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
                                  // Handle image removal
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
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.network(
                                'https://d3s3zh7icgjwgd.cloudfront.net/AcuCustom/Sitename/DAM/267/King-Charles-by-Mark-Harrison.jpg',
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
                                  // Handle image removal
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
                        // Add more images here
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 28),
            Text(
              "Title",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 9),
            TextField(
              controller: title,
              maxLength: _titleMaxLength,
              decoration: InputDecoration(
                counterText: '${title.text.length} / ${_titleMaxLength}',
                counterStyle: TextStyle(
                  color: title.text.length > _titleMaxLength ? Colors.red : Colors.grey,
                  fontSize: 10,
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
              onChanged: (value) {
                if (value.length > _titleMaxLength) {
                  title.text = value.substring(0, _titleMaxLength);
                  title.selection = TextSelection.fromPosition(
                    TextPosition(offset: _titleMaxLength),
                  );
                }
                setState(() {});
              },
            ),
            SizedBox(height: 15),
            Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 9),
            TextField(
              maxLines: 5,
              controller: description,
              maxLength: _descriptionMaxLength,
              decoration: InputDecoration(
                counterText: '${description.text.length} / ${_descriptionMaxLength}',
                counterStyle: TextStyle(
                  color: description.text.length > _descriptionMaxLength ? Colors.red : Colors.grey,
                  fontSize: 10,
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
              onChanged: (value) {
                if (value.length > _descriptionMaxLength) {
                  description.text = value.substring(0, _descriptionMaxLength);
                  description.selection = TextSelection.fromPosition(
                    TextPosition(offset: _descriptionMaxLength),
                  );
                }
                setState(() {});
              },
            ),
            SizedBox(height: 15),
            Text(
              "Choose Category",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 9),
            Wrap(
              spacing: 8.0,
              children: _categories.map((category) {
                Color backgroundColor = _selectedCategory == category ? AppColors.primaryColor : const Color.fromARGB(255, 217, 217, 217);
                Color textColor = _selectedCategory == category ? Colors.white : const Color.fromARGB(255, 106, 106, 106);

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: textColor,
                    backgroundColor: backgroundColor,
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
            SizedBox(height: 28),
            Text(
              "Pick up Date & Time",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 9),
            Column(
              children: [
                Container(
                  width: 250,
                  child: ListTile(
                    tileColor: const Color.fromARGB(187, 35, 151, 103),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 250,
                  child: ListTile(
                    tileColor: const Color.fromARGB(187, 35, 151, 103),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      selectedTime == null
                          ? 'Pick Time'
                          : 'Time: ${selectedTime!.format(context)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.access_time,
                      color: Colors.white,
                    ),
                    onTap: () => _selectTime(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            Text(
              "Expiry Date",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 9),
            Container(
              width: 250,
              child: ListTile(
                tileColor: const Color.fromARGB(187, 35, 151, 103),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  formattedExpiryDate,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                trailing: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                ),
                onTap: () => _selectExpiryDate(context),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 250,
              child: ListTile(
                tileColor: const Color.fromARGB(187, 35, 151, 103),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  selectExpiryTime == null
                      ? 'Expiry Time'
                      : 'Time: ${selectExpiryTime!.format(context)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                trailing: Icon(
                  Icons.access_time,
                  color: Colors.white,
                ),
                onTap: () => _selectExpiryTime(context),
              ),
            ),
            SizedBox(height: 28),
            Text(
              "Your Location",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 220,
              width: double.infinity,
              color: const Color.fromARGB(127, 255, 82, 82),
              // Add map or location widget here
            ),
            SizedBox(height: 35),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  // Handle post action
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondaryColor,
                        AppColors.primaryColor,
                        AppColors.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 250,
                      maxHeight: 50,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Post",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}