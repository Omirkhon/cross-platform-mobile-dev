import 'package:flutter/material.dart';
import 'about_page.dart';

class AboutPage2 extends StatelessWidget {
  const AboutPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/logo.png', 
                width: 200,
              ),
              const SizedBox(height: 20),

              const Text(
                "About App",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              

              const SizedBox(height: 50),
              
              
            ],
          ),
        ),
      ),
    );
  }
}
