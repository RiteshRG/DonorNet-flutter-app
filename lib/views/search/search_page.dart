import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/views/search/search_post_page.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<String> searchOptions = [
    'Food', 'Toy', 'Pet Supplies', 'Clothing and Textiles',
    'Footwear', 'Furniture', 'Sports Equipment'
  ];
  List<String> filteredOptions = [];

  @override
  void initState() {
    super.initState();
    filteredOptions = List.from(searchOptions);
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredOptions = searchOptions
          .where((option) => option.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _setSearchText(String text) {
    setState(() {
      _searchController.text = text;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
      _onSearchChanged(text);
    });
  }

  void _triggerSearch(String value) {
  String trimmedValue = value.trim();
  if (trimmedValue.isEmpty) {
    return;
  }
  print("Search Query: $trimmedValue");
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SearchPostPage(searchQuery: trimmedValue)),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
     appBar: AppBar(
      title: Text("Search", style: TextStyle(color: AppColors.primaryColor),),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primaryColor,),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255), // Start color (Change as needed)
              const Color.fromARGB(255, 255, 255, 255), // End color (Change as needed)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Soft shadow color
                      blurRadius: 10, // Soft blur effect
                      spreadRadius: 2, // Slightly spread the shadow
                      offset: Offset(0, 4), // Position the shadow downward
                    ),
                  ],
                ),
                child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: (value) {
                  _triggerSearch(value);
                },
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 133, 133, 133),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search, color: Color.fromARGB(255, 147, 147, 147)),
                    onPressed: () {
                      // Trigger search using the current text value
                      _triggerSearch(_searchController.text);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.transparent, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: Color.fromARGB(255, 147, 147, 147)),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged("");
                          },
                        )
                      : null,
                ),
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),


              ),

              SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                children: searchOptions.map((option) {
                  return GestureDetector(
                    onTap: () => _setSearchText(option),
                    child: Chip(
                      label: Text(
                        option,
                        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      backgroundColor: const Color.fromARGB(181, 255, 255, 255), // Background inside border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // More rounded corners
                      ),
                    ),
                  );
                }).toList(),
              ),


              SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6, // Makes it scrollable
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: filteredOptions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.search, color: Colors.grey[600]),
                      title: Text(
                        filteredOptions[index],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      onTap: () => _setSearchText(filteredOptions[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
