import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final Color? loaderColor; // Nullable color

  const LoadingIndicator({
    Key? key,
    required this.isLoading,
    this.loaderColor, // Nullable, so it can be omitted
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  loaderColor ?? AppColors.secondaryColor), // Default color if null
              strokeWidth: 6,
            )
          : SizedBox.shrink(),
    );
  }
}
