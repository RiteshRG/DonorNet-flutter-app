import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';

// Function to show filter bottom sheet
void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => FilterBottomSheet(),
    ),
  ).then((result) {
    if (result != null) {
      print('Selected Distance: ${result['distance']}');
      print('Selected Categories: ${result['categories']}');
    }
  });
}

class FilterBottomSheet extends StatefulWidget {
  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String selectedDistance = '∞';
  Set<String> selectedCategories = {'All'};

  final List<String> distances = ['∞', '1Km', '5Km', '10Km'];
  final List<String> categories = [
    'All',
    'Food',
    'Toys',
    'Clothing and Textiles',
    'Footwear',
    'Furniture',
    'Sports Equipment',
    'Pet Supplies'
  ];

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
          selectedCategories = Set.from(['All']);
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
        crossAxisAlignment: CrossAxisAlignment.start, // Align everything to left
        children: [
          // Title Bar
          SizedBox(height: 10,),
          Stack(
            alignment: Alignment.center, // Center the title
            children: [
              Center(
                child: Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                   
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
              Positioned(
                right: 0, // Keep close button at the right
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 5,),
          Divider(),

          // Distance Filter
          Text(
            'Maximum Distance',
            style: TextStyle(fontSize: 16, ),
          ),
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
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: selectedDistance == distance
                        ? [BoxShadow(color: Colors.black12, blurRadius: 5)]
                        : [],
                  ),
                  child: Text(
                    distance,
                    style: TextStyle(
                      color: selectedDistance == distance
                          ? Colors.white
                          : Colors.black,
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
          Text(
            'Categories',
            style: TextStyle(fontSize: 16, ),
          ),
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
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: selectedCategories.contains(category)
                        ? [BoxShadow(color: Colors.black12, blurRadius: 5)]
                        : [],
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: selectedCategories.contains(category)
                          ? Colors.white
                          : Colors.black,
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
              width: double.infinity, // Make button full width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'distance': selectedDistance,
                    'categories': selectedCategories.toList(),
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(200),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12), // Remove horizontal padding
                  elevation: 5,
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Ensure text is white
                  ),
                ),
              ),
            )

          ),
        ],
      ),
    );
  }
}
