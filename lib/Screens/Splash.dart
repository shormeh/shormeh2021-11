import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width*0.6,
          height: MediaQuery.of(context).size.height*0.35,
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: AssetImage('assets/images/logo.png',),
            ),
          ),
        ),
      ),
    );
  }
}
