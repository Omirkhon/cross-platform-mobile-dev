import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
                "slogan".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isWide ? 36 : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "description".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isWide ? 20 : 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "credits".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
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
