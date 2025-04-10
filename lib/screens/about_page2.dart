import 'package:flutter/material.dart';
import 'main_page.dart';

class AboutPage2 extends StatelessWidget {
  const AboutPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: isWide ? 250 : 200,
                ),
                const SizedBox(height: 20),
                Text(
                  "About App",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWide ? 36 : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "JUST DO IT!'s main aim is to help users organize their tasks efficiently. It allows them to add, remove, edit and track any daily activity, ensuring productivity and time management.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWide ? 20 : 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  },
                  child: const Text(
                    "Let's start → ",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}