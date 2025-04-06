import 'package:donornet/materials/app_colors.dart';
import 'package:flutter/material.dart';


class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'DonorNet – Terms & Conditions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Effective Date: April 6, 2025\n',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.tertiaryColor,
                ),
              ),
              Text(
                'By accessing and using the DonorNet mobile application (“App”), you agree to comply with and be bound by the following Terms and Conditions. If you do not agree to these terms, you may not use the App.',
                style: TextStyle(height: 1.4, color: AppColors.leadingColor),
              ),
              SizedBox(height: 24),

              _SectionTitle('1. User Responsibilities'),
              _SectionText(
                '• Users must provide accurate information while creating donation posts.\n'
                '• All donated items should be in good and usable condition.\n'
                '• Pickup and expiry dates/times must be clearly specified and honored.\n'
                '• Users are solely responsible for the content they upload.',
              ),

              _SectionTitle('2. Donation Posts & QR Verification'),
              _SectionText(
                '• Each post will contain one image, title, description, pickup/expiry details, and map location.\n'
                '• A unique QR code is generated per post to confirm item claims.\n'
                '• The QR must be scanned by the recipient to confirm collection.\n'
                '• Donors earn 10 points per successful claim, contributing to level progression.',
              ),

              _SectionTitle('3. Messaging & Communication'),
              _SectionText(
                '• Users can communicate with each other through a secure in-app messaging system.\n'
                '• Harassment, spamming, or abusive language is strictly prohibited and may lead to account suspension or termination.',
              ),

              _SectionTitle('4. Points & Level System'),
              _SectionText(
                '• Donors receive 10 points for each successful item claim.\n'
                '• Points accumulate and determine the user\'s level within the App.\n'
                '• Points have no cash value and are non-transferable.',
              ),

              _SectionTitle('5. Filtering & Search'),
              _SectionText(
                '• Users may search or filter posts based on distance, category, and availability.\n'
                '• Location services must be enabled for nearby filtering to function properly.',
              ),

              _SectionTitle('6. Privacy & Data Usage'),
              _SectionText(
                '• DonorNet collects location and usage data to improve user experience.\n'
                '• Personal data is securely stored and not shared with third parties without consent.\n'
                '• Users may request data removal in accordance with privacy laws.',
              ),

              _SectionTitle('7. Termination of Access'),
              _SectionText(
                '• DonorNet reserves the right to suspend or terminate access for any user violating these terms.\n'
                '• Violations include but are not limited to fraud, abuse, or misrepresentation.',
              ),

              _SectionTitle('8. Modifications'),
              _SectionText(
                '• DonorNet may update these Terms & Conditions at any time.\n'
                '• Continued use of the App after changes indicates acceptance of the updated terms.',
              ),

              SizedBox(height: 24),
              Text(
                'Thank you for contributing to a better community through DonorNet.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: AppColors.secondaryColor,
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for section titles
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.tertiaryColor,
        ),
      ),
    );
  }
}

// Widget for section body text
class _SectionText extends StatelessWidget {
  final String content;
  const _SectionText(this.content);

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: const TextStyle(
        height: 1.5,
        color: AppColors.leadingColor,
      ),
    );
  }
}
