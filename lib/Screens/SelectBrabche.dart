import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/LocationsModel.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';
import 'package:shormeh/Screens/Locations.dart';

import '../main.dart';

class SelectBranche extends StatefulWidget {
  int? lan;
  double? lat;
  double? long;
  SelectBranche({this.lan, this.lat, this.long});
  @override
  _SelectBrancheState createState() => _SelectBrancheState();
}

class _SelectBrancheState extends State<SelectBranche>
    with TickerProviderStateMixin {
  String dropdownValue = 'Select Language';
  List<String> allBranches = [];

  List<String> allSliderCities = [];

  bool isIndicatorActive = true;

  // Position currentLocation;

  bool noMarketsOnMap = false;
  List<LocationModel> allLocationsGPS = [];
  double? lat;
  double? long;
  // bool enableClick=true;

  int translateLanguage = 0;
  Timer? timer;
  int _currentIndex = 0;
  CrossFadeState _crossFadeState = CrossFadeState.showFirst;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print(widget.lat.toString() + widget.long.toString());
    getAllSliderCities();
    getDataFromSharedPref();
  }

  Future<void> getDataFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final _translateLanguage = prefs.getInt('translateLanguage');
    final _lat = prefs.getDouble('lat');
    final _long = prefs.getDouble('long');
    if (widget.lat == null) {
      setState(() {
        lat = _lat;
        long = _long;
      });
    } else
      setState(() {
        lat = widget.lat;
        long = widget.long;
      });

    if (_translateLanguage == null && widget.lan == null) {
      setState(() {
        prefs.setInt('translateLanguage', 0);
        widget.lan = 0;
      });
    } else {
      setState(() {
        translateLanguage = _translateLanguage!;
        widget.lan = _translateLanguage;
      });
    }

    getBranches();
  }

  Future getAllSliderCities() async {
    var response = await http.get(Uri.parse("${HomePage.URL}settings/app"));
    var dataAllSilderCities = json.decode(response.body);
    setState(() {
      allSliderCities = [
        dataAllSilderCities['cities_slider'][0]['img_url'],
        dataAllSilderCities['cities_slider'][1]['img_url'],
        dataAllSilderCities['cities_slider'][2]['img_url'],
      ];
    });
    // timer = Timer.periodic(Duration(seconds: 3), (timer) async {
    //   if (mounted) {
    //     setState(() {
    //       if (_currentIndex + 1 == allSliderCities.length) {
    //         _currentIndex = 0;
    //         CrossFadeState.showSecond;
    //       } else {
    //         _currentIndex = _currentIndex + 1;
    //       }
    //     });
    //   }
    // });
  }

  getBranches() async {
    // var response;
    // if (widget.lat == null) {
    //   Position position = await Geolocator.getCurrentPosition();
    //   response = await http.get(
    //       "${HomePage.URL}vendors?lat=${position.latitude}&long=${position.longitude}");
    // }
    // else
    print(widget.lat.toString() + 'gggggg');
    var response = await http
        .get(Uri.parse("${HomePage.URL}vendors?lat=${lat}&long=${long}"));

    var data = json.decode(response.body);
    print(data);
    setState(() {
      allLocationsGPS.clear();
      allLocationsGPS = [];
      print("${allLocationsGPS.length}");
      for (int i = 0; i < data.length; i++) {
        allLocationsGPS.add(new LocationModel(
          data[i]['vendor']['id'],
          "${data[i]['vendor']['id']}",
          "${data[i]['vendor']['id']}",
          "${data[i]['vendor']['id']}",
          "${data[i]['vendor']['lat']}",
          "${data[i]['vendor']['id']}",
          data[i]['vendor']['vendor_id'],
          "${data[i]['name_ar']}",
          "${data[i]['name_en']}",
        ));
      }

      isIndicatorActive = false;
      noMarketsOnMap = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //Slider
          // AnimatedCrossFade(
          //   crossFadeState: _crossFadeState,
          //   duration: const Duration(seconds: 2),
          //   reverseDuration: const Duration(seconds: 1),
          //   firstCurve: Curves.bounceInOut,
          //   firstChild: Container(
          //       width: MediaQuery.of(context).size.width,
          //       height: MediaQuery.of(context).size.height,
          //       child: Image.network(
          //         allSliderCities[_currentIndex],
          //         fit: BoxFit.fill,
          //       )),
          //   secondChild: Container(
          //       width: MediaQuery.of(context).size.width,
          //       height: MediaQuery.of(context).size.height,
          //       child: Image.network(
          //         allSliderCities[_currentIndex + 1],
          //         fit: BoxFit.fill,
          //       )),
          // ),
          // AnimatedSwitcher(
          //   duration: const Duration(milliseconds: 1200),
          //   transitionBuilder: (
          //     Widget child,
          //     Animation<double> animation,
          //   ) {
          //     return ScaleTransition(child: child, scale: animation);
          //   },
          //   child: Container(
          //       key: ValueKey(allSliderCities[_currentIndex]),
          //       width: MediaQuery.of(context).size.width,
          //       height: MediaQuery.of(context).size.height,
          //       child: Image.network(
          //         allSliderCities[_currentIndex],
          //         fit: BoxFit.fill,
          //       )),
          // ),
          CarouselSlider(
            options: CarouselOptions(
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayAnimationDuration: Duration(seconds: 1),
              autoPlayCurve: Curves.ease,
              height: MediaQuery.of(context).size.height,
              viewportFraction: 1.0,
            ),
            items: allSliderCities.map((banner) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      child: Image.network(
                        banner,
                        fit: BoxFit.fill,
                      ));
                },
              );
            }).toList(),
          ),

          //DropDownlist
          Directionality(
            textDirection:
                translateLanguage == 1 ? TextDirection.rtl : TextDirection.ltr,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //Languages
                  GestureDetector(
                    onTap: () {
                      showDialogeLanguage(context);
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 0.8, color: HexColor('#40976c')),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          color: Colors.white.withOpacity(0.8),
                        ),
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.width / 50),
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width / 50),
                        child: Row(
                          children: [
                            Container(
                                //margin:EdgeInsets.all(double2),
                                child: Text(
                              translateLanguage == 0
                                  ? translate('lan.translateEn')
                                  : translate('lan.translateAr'),
                              // "${AppLocalizations.of(context).language}",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 23),
                            )),
                            Expanded(child: Container()),
                            Container(
                                child: Icon(
                              Icons.keyboard_arrow_down,
                              size: MediaQuery.of(context).size.width / 15,
                            ))
                          ],
                        )),
                  ),

                  //Cities/Branches/Location
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: GestureDetector(
                          onTap: () {
                            if (allLocationsGPS.isEmpty)
                              showDialogeLoading(context);
                            else
                              showDialogeBranches(context);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.8, color: HexColor('#40976c')),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                color: Colors.white.withOpacity(0.8),
                              ),
                              margin: EdgeInsets.all(
                                  MediaQuery.of(context).size.width / 50),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width / 50),
                              child: Row(
                                children: [
                                  Container(
                                      //margin:EdgeInsets.all(double2),
                                      child: Text(
                                    translate('lan.branches'),
                                    // "${AppLocalizations.of(context).branches}",
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                23),
                                  )),
                                  Expanded(child: Container()),
                                  Container(
                                      child: Icon(
                                    Icons.keyboard_arrow_down,
                                    size:
                                        MediaQuery.of(context).size.width / 15,
                                  ))
                                ],
                              )),
                        ),
                      ),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          goToMyLocations();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Image.asset(
                            "assets/images/location.png",
                            width: MediaQuery.of(context).size.width / 10,
                            height: MediaQuery.of(context).size.width / 10,
                          ),
                        ),
                      ))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showDialogeBranches(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            content: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 1.1,
              height: MediaQuery.of(context).size.height / 1.1,
              decoration: ShapeDecoration(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  )),
              child: Container(
                color: Colors.transparent,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allLocationsGPS.length,
                  itemBuilder: (BuildContext context, int index) {
                    return index == 0
                        ? Column(
                            children: [
                              //DropDown Dialoge
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 0.8),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        color: Colors.white),
                                    margin: EdgeInsets.all(
                                        MediaQuery.of(context).size.width / 40),
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width / 30),
                                    child: Row(
                                      children: [
                                        Expanded(child: Container()),
                                        Container(
                                            //margin:EdgeInsets.all(double2),
                                            child: Text(
                                          translate('lan.branches'),
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  23),
                                        )),
                                        Expanded(child: Container()),
                                        Container(
                                            child: Icon(
                                          Icons.clear,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              12,
                                        ))
                                      ],
                                    )),
                              ),
                              GestureDetector(
                                onTap: () {
                                  //Navigator.pop(context);
                                  goToHome(allLocationsGPS[index].vendor_id);
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 0.8),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        color: Colors.white),
                                    margin: EdgeInsets.all(
                                        MediaQuery.of(context).size.width / 40),
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width / 30),
                                    child: Container(
                                        alignment: Alignment.center,
                                        //margin:EdgeInsets.all(double2),
                                        child: Text(
                                          widget.lan == 0
                                              ? "${allLocationsGPS[index].nameEn}"
                                              : "${allLocationsGPS[index].nameAr}",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  23),
                                        ))),
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              goToHome(allLocationsGPS[index].vendor_id);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.8),
                                    borderRadius: BorderRadius.circular(12.0),
                                    color: Colors.white),
                                margin: EdgeInsets.all(
                                    MediaQuery.of(context).size.width / 40),
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width / 30),
                                child: Container(
                                    alignment: Alignment.center,
                                    //margin:EdgeInsets.all(double2),
                                    child: Text(
                                      widget.lan == 0
                                          ? "${allLocationsGPS[index].nameEn}"
                                          : "${allLocationsGPS[index].nameAr}",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              23),
                                    ))),
                          );
                  },
                ),
              ),
            ),
          );
        });
  }

  void showDialogeLoading(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          if (!isIndicatorActive) {
            Navigator.pop(context);
          } else
            Future.delayed(Duration(seconds: 3), () {
              // getBranches();
              Navigator.pop(context);
              showDialogeBranches(context);
            });
          return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            content: Center(
              child: CircularProgressIndicator(
                color: HexColor('#40976c'),
              ),
            ),
          );
        });
  }

  void showDialogeLanguage(BuildContext context) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 400),
      context: context,
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 1.1,
              height: MediaQuery.of(context).size.height / 1.1,
              decoration: ShapeDecoration(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  )),
              child: Container(
                  child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.8),
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white),
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.width / 40),
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width / 30),
                        child: Row(
                          children: [
                            Expanded(child: Container()),
                            Container(
                                //margin:EdgeInsets.all(double2),
                                child: Text(
                              translate('lan.language'),
                              // "${AppLocalizations.of(context).language}",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 23),
                            )),
                            Expanded(child: Container()),
                            Container(
                                child: Icon(
                              Icons.clear,
                              size: MediaQuery.of(context).size.width / 12,
                            ))
                          ],
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.lan = 1;
                        translateLanguage = 1;
                      });
                      Navigator.pop(context);

                      changeLaguageAndGoToMyApp(1, context);
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.8),
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white),
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.width / 40),
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width / 30),
                        child: Container(
                            alignment: Alignment.center,
                            //margin:EdgeInsets.all(double2),
                            child: Text(
                              translate('lan.translateAr'),
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 23),
                            ))),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        translateLanguage = 0;
                        widget.lan = 0;
                      });
                      Navigator.pop(context);
                      changeLaguageAndGoToMyApp(0, context);
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.8),
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white),
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.width / 40),
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width / 30),
                        child: Container(
                            alignment: Alignment.center,
                            //margin:EdgeInsets.all(double2),
                            child: Text(
                              translate('lan.translateEn'),
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 23),
                            ))),
                  ),
                ],
              )),
            ),
          ),
        );
      },
      // transitionBuilder: (_, anim, __, child) {
      //   return SlideTransition(
      //     position: Tween(begin: Offset(0, 0), end: Offset(0, 0)).animate(anim),
      //     child: child,
      //   );
      // },
    );
  }

  void goToHome(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vendorID', id);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void goToMyLocations() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Locations()),
    );
  }

  void changeLaguageAndGoToMyApp(
    int translateLanguage,
    BuildContext context1,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    print("TTT $translateLanguage");

    if (widget.lan == 0) {
      setState(() {
        prefs.setInt('translateLanguage', 0);
        MyApp.setLocale(context, Locale('en'));
      });
    } else {
      setState(() {
        prefs.setInt('translateLanguage', 1);
        MyApp.setLocale(context, Locale('ar'));
      });
    }
  }
}
