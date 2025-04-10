import 'package:flutter/material.dart';
import 'about_page2.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
                  "JUST DO IT!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWide ? 36 : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "A Simple, Yet Effective Way to Be More Productive.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWide ? 22 : 20,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Developed by Issayeva Vera, Sailau Ayaulym, Turgimbayev Amirkhan. In the scope of the course “Crossplatform Development” at Astana IT University.\nMentor : Assistant Professor Abzal Kyzyrkanov",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
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
                      MaterialPageRoute(builder: (context) => const AboutPage2()),
                    );
                  },
                  child: const Text(
                    " → ",
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
