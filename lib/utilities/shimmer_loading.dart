import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostLoadingAnimation extends StatelessWidget {
  @override
 Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image Placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10),
                // Title & Description Placeholder
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildShimmerGrid() {
  return GridView.builder(
    padding: EdgeInsets.all(8),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
    ),
    itemCount: 6, // Number of shimmer placeholders
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    },
  );
}



class BuildShimmerEffect extends StatelessWidget {
  const BuildShimmerEffect({super.key});

   static const Color shimmerPlaceholderColor = Color.fromARGB(110, 38, 182, 122);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📍 Image Placeholder
          Container(
            height: 300,
            width: double.infinity,
            color: shimmerPlaceholderColor,
          ),
          const SizedBox(height: 20),

          // 📍 Title Placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(height: 20, width: 200, color: shimmerPlaceholderColor),
          ),
          const SizedBox(height: 10),

          // 📍 Distance (Left) & Date (Right)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 15, width: 100, color: shimmerPlaceholderColor), // Distance
                Container(height: 15, width: 80, color: shimmerPlaceholderColor), // Date
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 📍 Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(height: 80, width: double.infinity, color: shimmerPlaceholderColor),
          ),
          const SizedBox(height: 20),

          // 📍 Pick-Up Date & Time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(height: 15, width: 150, color: shimmerPlaceholderColor),
          ),
          const SizedBox(height: 20),

          // 📍 Profile, Name, & Rating
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(radius: 20, backgroundColor: shimmerPlaceholderColor), // Profile
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 15, width: 100, color: shimmerPlaceholderColor), // Name
                    const SizedBox(height: 5),
                    Container(height: 10, width: 50, color: shimmerPlaceholderColor), // Rating
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(height: 150, width: double.infinity, color: shimmerPlaceholderColor),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: shimmerPlaceholderColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



Widget messagePagebuildShimmerLayout() {
  return Scaffold(
    appBar: AppBar(
      title: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 20,
          width: 150,
          color: Colors.white,
        ),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Title and post image row
          Row(
            children: [
              // Shimmer for title placeholder
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10),
              // Shimmer for small rectangular post image placeholder
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 70,
                  height: 50,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Simulated messages area with multiple shimmer lines
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 15,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          // Typing box shimmer placeholder
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 40,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}