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
  if (!isLoading) return SizedBox(); // Return an empty widget if not loading

  return Center(
    child: Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1000),
      ),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          loaderColor ?? AppColors.secondaryColor, // Default color if null
        ),
        strokeWidth: 6,
      ),
    ),
  );
}

}
