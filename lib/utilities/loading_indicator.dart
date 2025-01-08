import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final bool isLoading;

  const LoadingIndicator({Key? key, required this.isLoading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),strokeWidth: 6,
          ) 
          : SizedBox.shrink(),  
    );
  }
}