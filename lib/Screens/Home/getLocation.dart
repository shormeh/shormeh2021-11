// import 'package:android_intent/android_intent.dart';
import 'package:android_intent/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';
import 'package:shormeh/Screens/SelectBrabche.dart';

class GetLocation extends StatefulWidget {
  @override
  _GetLocationState createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocation> {
  Position? currentLocation;
  bool noMarketsOnMap = false;
  bool circularIndicatorActive = false;
  double? lat;
  double? long;

  getLocationStatus() async {
    var status = await Geolocator.isLocationServiceEnabled();
    if (status) {
      locateUser();
    } else {
      setState(() {
        _showDialog(context);
      });
    }
  }

  void _showDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "الموقع",
            style: TextStyle(color: HomePage.colorGreen),
          ),
          content: new Text(
              "لكى تتمكن من مشاهدة المطاعم بالقرب منك الرجاء تفعيل الموقع"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
                child: new Text(
                  "تفعيل",
                  style: TextStyle(color: HomePage.colorGreen),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setActiveLocation();
                  setState(() {
                    noMarketsOnMap = true;
                    circularIndicatorActive = false;
                  });
                }),
            new FlatButton(
              child: new Text(
                "الغاء",
                style: TextStyle(color: HomePage.colorGreen),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  setActiveLocation() async {
    var platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS) {
      AppSettings.openAppSettings();
    } else {
      final AndroidIntent intent = new AndroidIntent(
        action: 'android.settings.LOCATION_SOURCE_SETTINGS',
      );
      await intent.launch();
    }
  }

  locateUser() async {
    setState(() {
      circularIndicatorActive = true;
    });
    final prefs = await SharedPreferences.getInstance();
    Position p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
    if (p.latitude != null) {
      prefs.setBool('getLocation', true);
      prefs.setDouble('lat', p.latitude);
      prefs.setDouble('long', p.longitude);
      setState(() {
        circularIndicatorActive = false;
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SelectBranche(
                    lat: p.latitude,
                    long: p.longitude,
                  )));
    } else
      locateUser();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 150,
              ),
              Image.asset(
                'assets/images/Group 9610.png',
                height: size.height * 0.4,
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        translate('lan.openGps'),
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: size.width * 0.8,
                        child: Text(
                          translate('lan.openGps2'),
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        width: size.width * 0.85,
                        height: 60,
                        decoration: BoxDecoration(
                          color: HexColor('#40976c'),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            getLocationStatus();
                          },
                          child: Center(
                            child: Text(
                              translate('lan.openGps3'),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          circularIndicatorActive
              ? Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.6),
                  child: Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Lottie.asset(
                        'assets/images/lf20_mvihowzk.json',
                        fit: BoxFit.fill,
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
