import 'package:flutter/material.dart';

class AboutPage2 extends StatelessWidget {
  const AboutPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          final size = MediaQuery.of(context).size;
          final isWide = size.width > 600;

          final logo = Image.asset(
            'assets/logo.png',
            width: isWide ? 250 : 200,
          );

          final textContent = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                "JUST DO IT!'s main aim is to help users organize their tasks efficiently. It allows them to add, remove, edit and track any daily activity, ensuring productivity and time management.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isWide ? 20 : 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Developed by Issayeva Vera, Sailau Ayaulym, Turgimbayev Amirkhan. In the scope of the course “Crossplatform Development” at Astana IT University.\nMentor : Assistant Professor Abzal Kyzyrkanov",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          );

          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: isPortrait
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          logo,
                          const SizedBox(height: 20),
                          textContent,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: Center(child: logo)),
                          const SizedBox(width: 40),
                          Expanded(child: textContent),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
