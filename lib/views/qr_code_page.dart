import 'package:donornet/materials/app_colors.dart';
import 'package:donornet/utilities/access_throught_link.dart';
import 'package:flutter/material.dart';

class QRCodeScreen extends StatelessWidget {
  const QRCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://thumbs.dreamstime.com/b/cricket-bat-ball-26570619.jpg', 
              fit: BoxFit.cover,  // Covers the whole screen
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(174, 38, 182, 122),
                  Color.fromARGB(166, 15, 119, 125),
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 18,
                    right: -20,
                    child: Opacity(
                    opacity: 0.7,
                    child: Image.network(
                          '${AccessLink.logoFlip}',
                            height: 180,
                            width: 180,
                            fit: BoxFit.cover,
                          ),
                      ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(112, 0, 0, 0),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // QR Code Container
                  Center(
                    child: Container(
                      width: 280,
                      height: 280,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.network(
                        'https://i.postimg.cc/qRdpHVGr/qr-code.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
          
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}