import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/materials/access_throught_link.dart';
import 'package:donornet/services%20and%20provider/post_service.dart';
import 'package:donornet/services%20and%20provider/user_service.dart';
import 'package:donornet/utilities/loading_indicator.dart';
import 'package:donornet/utilities/show_dialog.dart';
import 'package:donornet/views/rating_page.dart';
import 'package:flutter/material.dart';

class ConfirmClaimPage extends StatefulWidget {
  final String postId;

  const ConfirmClaimPage({Key? key, required this.postId}) : super(key: key);

  @override
  _ConfirmClaimPageState createState() => _ConfirmClaimPageState();
}

class _ConfirmClaimPageState extends State<ConfirmClaimPage> {
  bool isLoading = false;
  Map<String, dynamic>? postData;

  @override
  void initState() {
    super.initState();
    claimPost(widget.postId);
  }

  void claimPost(String postId) async {
    setState(() {
      isLoading = true;
    });

    var result = await UserService().checkAndClaimPost(postId);
    
    setState(() {
      isLoading = false;
      postData = result;
    });

    if (result != null && result.containsKey('error')) {
        showErrorDialog(context, result['error']).then((_) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            'homePageRoute',
            (route) => false, 
          );
        });
      }else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post is available for claiming!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 38, 182, 122),
              Color.fromARGB(255, 15, 119, 125),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              left: -40,
              child: Opacity(
                opacity: 0.8,
                child: Image.network(
                  '${AccessLink.coinGolden}',
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(); 
                  },
                ),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Confirm Claim',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(
                        width: 250,
                        child: Text(
                          'Have you successfully received the item?',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 300,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 80,
                          left: -20,
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: 0.8,
                                child: Image.network(
                                  '${AccessLink.logo}',
                                  height: 180,
                                  width: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox(); 
                                  },
                                ),
                              ),
                              Positioned(
                                right: 9,
                                top: 8,
                                child: Container(
                                  width: 85,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                  ),
                                  child: ClipOval(
                                    child: postData != null &&
                                            postData!['image_url'] != null
                                        ? Image.network(
                                            postData!['image_url'],
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Icon(Icons.image, size: 22, color: const Color.fromARGB(255, 110, 110, 110),);
                                              //LoadingIndicator(isLoading: true); 
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return _defaultImage();
                                            },
                                          )
                                        : _defaultImage(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: -15,
                          top: 0,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: ClipOval(
                              child: postData != null &&
                                      postData!['profile_image'] != null
                                  ? Image.network(
                                      postData!['profile_image'],
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Icon(Icons.image, size: 22, color: const Color.fromARGB(255, 110, 110, 110),);
                                        //LoadingIndicator(isLoading: true); 
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return _defaultProfileImage();
                                      },
                                    )
                                  : _defaultProfileImage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isLoading
                      ? null 
                      : () async {
                          if (postData != null) {
                            setState(() {
                              isLoading = true; 
                            });

                            String postId = postData!['postId'];
                            String userId = postData!['user_id'];
                            bool isUpdated = await PostService().markPostAsClaimed(postId, userId);

                            setState(() {
                              isLoading = false; 
                            });

                            if (isUpdated) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RatingPage(postData: postData!),
                                ),
                              );
                            } else {
                              showErrorDialog(context, "Error: Failed to mark post as claimed!");
                            }
                          } else {
                            showErrorDialog(context, "Error: Post data is missing!");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200),
                            side: BorderSide(color: Colors.white, width: 2),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          elevation: 5,
                          shadowColor: Colors.black54,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Yes',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null 
                            : () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  'homePageRoute',
                                  (route) => false, 
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200),
                            side: BorderSide(color: AppColors.primaryColor, width: 2),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          elevation: 5,
                          shadowColor: Colors.black54,
                        ),
                        child: Text(
                          'No',
                          style: TextStyle(fontSize: 18, color: AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.white,
                child: LoadingIndicator(isLoading: isLoading),
              ),
          ],
        ),
      ),
    );
  }

  Widget _defaultImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 40, color: Colors.grey),
    );
  }

  Widget _defaultProfileImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.person, size: 60, color: Colors.grey),
    );
  }
}

