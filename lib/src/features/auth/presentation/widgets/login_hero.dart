import 'package:flutter/material.dart';

class LoginHero extends StatelessWidget {
  const LoginHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Image
          Image.asset('assets/images/panda_login.png', fit: BoxFit.contain),
        ],
      ),
    );
  }
}
