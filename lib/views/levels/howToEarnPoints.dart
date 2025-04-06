import 'package:donornet/materials/access_throught_link.dart';
import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';

class HowToEarnPage extends StatelessWidget {
  const HowToEarnPage({super.key});

  final List<_LevelInfo> levels = const [
    _LevelInfo(level: 1, points: 10, posts: 1),
    _LevelInfo(level: 2, points: 40, posts: 4),
    _LevelInfo(level: 3, points: 90, posts: 9),
    _LevelInfo(level: 4, points: 150, posts: 15),
    _LevelInfo(level: 5, points: 225, posts: 23),
    _LevelInfo(level: 6, points: 300, posts: 30),
    _LevelInfo(level: 7, points: 500, posts: 50),
    _LevelInfo(level: 8, points: 800, posts: 80),
    _LevelInfo(level: 9, points: 1000, posts: 100),
    _LevelInfo(level: 10, points: 1500, posts: 150),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tertiaryColor.withOpacity(0.05),
      appBar: AppBar(
        title: const Text("How to Earn Points"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Container(
        color:  Color.fromARGB(255, 255, 255, 255),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("📌 Earning Rules"),
              const SizedBox(height: 8),
              _bulletPoint("Earn **10 points** for every successful donation or when someone claims your post."),
              _bulletPoint("Points help you increase your **level** and gain community recognition."),
              _bulletPoint("Higher levels reflect more trust and contribution."),
              const SizedBox(height: 24),
        
              _sectionTitle("🎯 Level System"),
              const SizedBox(height: 12),
              ...levels.map((level) => _buildLevelCard(level)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.secondaryColor,
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18, color: AppColors.leadingColor)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: AppColors.leadingColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(_LevelInfo level) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              AccessLink.getLevelImage(level.level),
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Level ${level.level}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${level.points} points • ${level.posts} post(s)",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.leadingColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelInfo {
  final int level;
  final int points;
  final int posts;

  const _LevelInfo({
    required this.level,
    required this.points,
    required this.posts,
  });
}
