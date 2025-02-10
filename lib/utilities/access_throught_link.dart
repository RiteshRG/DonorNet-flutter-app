class AccessLink{
  static const String logoFlip = 'https://i.postimg.cc/Ss49LVPS/logo-left-flip.png';
  static const String logo = 'https://i.postimg.cc/bwbd6kks/logo.png';

  static const String coinBlack = 'https://i.postimg.cc/v895Jfns/black-coin.png';
  static const String coinGolden = 'https://i.postimg.cc/QtKcxWnc/golden-coin.png';

  static const String level1 = "https://i.postimg.cc/N0nbGtb2/level-1-removebg-preview.png";
  static const String level2 = "https://i.postimg.cc/63RV9vyF/level-2-removebg-preview.png";
  static const String level3 = "https://i.postimg.cc/hPK8Bhg3/level-3-removebg-preview.png";
  static const String level4 = "https://i.postimg.cc/Y0RW9fkD/level-4-removebg-preview.png";
  static const String level5 = "https://i.postimg.cc/8PkvY3B2/level-5-removebg-preview.png";
  static const String level6 = "https://i.postimg.cc/66c2CcJY/level-6-removebg-preview.png";
  static const String level7 = "https://i.postimg.cc/3x4k5Hyc/level-7-removebg-preview.png";
  static const String level8 = "https://i.postimg.cc/Pq1NJzQb/level-8-removebg-preview.png";
  static const String level9 = "https://i.postimg.cc/d3NVpWJF/level-9-removebg-preview.png";
  static const String level10 = "https://i.postimg.cc/0ywyXdFg/level-10-removebg-preview.png";

  static String getLevelImage(int level) {
    switch (level) {
      case 1: return level1;
      case 2: return level2;
      case 3: return level3;
      case 4: return level4;
      case 5: return level5;
      case 6: return level6;
      case 7: return level7;
      case 8: return level8;
      case 9: return level9;
      case 10: return level10;
      default: return level1;
    }
  }
}