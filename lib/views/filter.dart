import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as devtools show log;

// Function to show filter bottom sheet
void showFilterBottomSheet(BuildContext context, Function refreshPageCallback) async {
  final filters = await loadFilters(); // Load saved filters
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => FilterBottomSheet(
        initialDistance: filters['distance'],
        initialCategories: filters['categories'],
        refreshPageCallback: refreshPageCallback,
      ),
    ),
  ).then((result) {
    if (result != null) {
      devtools.log('Selected Distance: ${result['distance']}');
      devtools.log('Selected Categories: ${result['categories']}');
    }
  });
}


// Function to Save Filters in SharedPreferences
Future<void> saveFilters(String distance, List<String> categories) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('selected_distance', distance);
  await prefs.setStringList('selected_categories', categories);
  devtools.log("Saved Distance: $distance");
devtools.log("Saved Categories: ${categories.toList()}");
}

// Function to Load Filters from SharedPreferences
Future<Map<String, dynamic>> loadFilters() async {
  final prefs = await SharedPreferences.getInstance();
  String distance = prefs.getString('selected_distance') ?? '∞';
  List<String> categories = prefs.getStringList('selected_categories') ?? ['All'];
  return {'distance': distance, 'categories': categories};
}


class FilterBottomSheet extends StatefulWidget {
  final String initialDistance;
  final List<String> initialCategories;
  final Function refreshPageCallback;

  FilterBottomSheet({required this.initialDistance, required this.initialCategories,  required this.refreshPageCallback,});

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String selectedDistance;
  late Set<String> selectedCategories;

  final List<String> distances = ['infinity', '1', '5', '10', '20', '50', '100'];
  final List<String> categories = [
    'All', 'Food', 'Footwear', 'Furniture', 'Toy',
    'Pet Supply', 'Clothing and Textile', 'Sports Equipment', 'Stationery'
  ];

  @override
  void initState() {
    super.initState();
    selectedDistance = widget.initialDistance;
    selectedCategories = widget.initialCategories.toSet();
  }

  void _handleDistanceSelection(String distance) {
    setState(() {
      selectedDistance = distance;
    });
  }

  void _handleCategorySelection(String category) {
    setState(() {
      if (category == 'All') {
        if (selectedCategories.contains('All')) {
          selectedCategories.clear();
        } else {
          selectedCategories = {'All'};
        }
      } else {
        if (selectedCategories.contains('All')) {
          selectedCategories.remove('All');
        }
        if (selectedCategories.contains(category)) {
          selectedCategories.remove(category);
        } else {
          selectedCategories.add(category);
        }
        if (selectedCategories.isEmpty) {
          selectedCategories.add('All');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 245, 245),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Bar
          SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, color: AppColors.secondaryColor),
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Divider(),

          // Distance Filter
          Text('Maximum Distance', style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: distances.map((distance) {
              return GestureDetector(
                onTap: () => _handleDistanceSelection(distance),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedDistance == distance
                        ? AppColors.primaryColor
                        : const Color.fromARGB(255, 227, 225, 225),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: selectedDistance == distance
                        ? [BoxShadow(color: Colors.black12, blurRadius: 5)]
                        : [],
                  ),
                  child: Text(
                    distance == "infinity" ? "∞" : "$distance km",
                    style: TextStyle(
                      color: selectedDistance == distance ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 24),

          // Category Filter
          Text('Categories', style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              return GestureDetector(
                onTap: () => _handleCategorySelection(category),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedCategories.contains(category)
                        ? AppColors.primaryColor
                        : const Color.fromARGB(255, 227, 225, 225),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: selectedCategories.contains(category)
                        ? [BoxShadow(color: Colors.black12, blurRadius: 5)]
                        : [],
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: selectedCategories.contains(category) ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 30),

          // Apply Button
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   String storedDistance = selectedDistance == "∞" ? "infinity" : selectedDistance;
                  saveFilters(storedDistance, selectedCategories.toList()); // Save filters
                  widget.refreshPageCallback();
                  Navigator.pop(context, {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  elevation: 5,
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}












