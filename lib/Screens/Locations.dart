import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:android_intent/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geopoint/geopoint.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart' as lottie;
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/LocationsModel.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class Locations extends StatefulWidget {
  String? lan;
  Locations({this.lan});

  @override
  _LocationsState createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {
  // Completer<GoogleMapController> _controller = Completer();
  // LatLng _center;
  // LatLng _lastMapPosition;
  // MapType _currentMapType = MapType.normal;

  // CameraPosition _position1;
  Position? currentLocation;

  List<LocationModel> allLocationsGPS = [];
  bool circularIndicatorActive = true;
  bool noMarketsOnMap = false;
  String lan = 'en';

  Uint8List? markerIcon;
  Uint8List? myLoc;
  BitmapDescriptor? myIcon;
  GeoPoint? location;
  String loc = '';
  bool markerTapped = false;
  List<String> startTime = [];
  List<String> endTime = [];
  LocationModel? location1;
  GoogleMapController? mapController;
  String start = '';
  String end = '';
  bool open = true;
  List<String> startTime12Hour = [];
  List<String> endTime12Hour = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setMarker();
    _getLocation();

    lan = LocalizedApp.of(context).delegate.currentLocale.toString();
    print(lan);

    getLocationStatus();

    setMyLoc();
  }

  _getLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        currentLocation = position;
        location = new GeoPoint(
            latitude: position.latitude, longitude: position.longitude);
      });

      _getAddressFromLatLng();
      getMarketsForGPS();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          currentLocation!.latitude, currentLocation!.longitude);

      Placemark place = p[0];

      setState(() {
        loc = "${place.locality}, ${place.administrativeArea}";
      });
    } catch (e) {
      print(e);
    }
  }

  void setMarker() async {
    markerIcon = await getBytesFromAsset('assets/images/512.png', 110);
  }

  void setMyLoc() async {
    myLoc = await getBytesFromAsset('assets/images/group1.png', 300);
  }

  Marker myLocMarker() {
    if (myLoc != null)
      return Marker(
        markerId: MarkerId('myLoc'),
        position: LatLng(currentLocation!.latitude, currentLocation!.longitude),
        icon: BitmapDescriptor.fromBytes(myLoc!),
      );
    else
      return Marker(
        markerId: MarkerId('myLoc'),
        position: LatLng(currentLocation!.latitude, currentLocation!.longitude),
      );
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();

    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  getLocationStatus() async {
    var status = await Geolocator.isLocationServiceEnabled();
    if (status) {
      setState(() {
        // هفعل السيركل عشان الفيو وهى هتطفى تانى من تحت وهقول ان فى صيدليات بعد ماكان الموقع مش متفعل
        _getLocation();
      });
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
              "لكى تتمكن من مشاهدة المتاجر بالقرب منك الرجاء تفعيل الموقع"),
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

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  List<Marker> _createMarker(List<LocationModel> allLocations) {
    List<Marker> markerList = [];
    for (int i = 0; i < allLocations.length; i++) {
      if (markerIcon != null) {
        markerList.add(
          Marker(
              markerId: MarkerId(allLocations[i].nameEn),
              position: LatLng(double.parse(allLocations[i].lat),
                  double.parse(allLocations[i].lag)),
              infoWindow: InfoWindow(title: allLocations[i].nameEn),
              icon: BitmapDescriptor.fromBytes(markerIcon!),
              onTap: () {
                setState(() {
                  markerTapped = true;
                  location1 = allLocations[i];
                  open = true;
                  getTime(allLocations[i].vendor_id);
                });
              }),
        );
      } else {
        markerList.add(
          Marker(
              markerId: MarkerId(allLocations[i].nameEn),
              position: LatLng(double.parse(allLocations[i].lat),
                  double.parse(allLocations[i].lag)),
              infoWindow: InfoWindow(title: allLocations[i].nameEn),
              onTap: () {
                setState(() {
                  markerTapped = true;
                  location1 = allLocations[i];
                  open = true;
                  getTime(allLocations[i].vendor_id);
                });
              }),
        );
      }
    }
    currentLocation != null ? markerList.add(myLocMarker()) : print(markerList);
    return markerList;
  }

  getTime(int id) async {
    final response = await http.get(
      Uri.parse("${HomePage.URL}vendors/$id/times"),
    );

    var data = json.decode(response.body);
    print(data);
    startTime.clear();
    endTime.clear();
    startTime12Hour.clear();
    endTime12Hour.clear();
    setState(() {
      start = '';
      end = '';
    });

    for (int i = 0; i < data.length; i++) {
      // print(DateFormat("HH:mm")
      //     .format(DateFormat.jm().parse(data[i]['end_time'])));

      setState(() {
        startTime.add(data[i]['start_time']);
        endTime.add(data[i]['end_time']);
        if (int.parse(startTime[i].substring(0, 2)) < 12)
          startTime12Hour.add(data[i]['start_time'] + ' AM');
        else if (int.parse(startTime[i].substring(0, 2)) == 12)
          startTime12Hour.add(data[i]['start_time'] + ' PM');
        else if (int.parse(startTime[i].substring(0, 2)) == 0)
          startTime12Hour.add(data[i]['start_time'] + ' AM');
        else
          startTime12Hour.add(
              (int.parse(startTime[i].substring(0, 2)) - 12).toString() +
                  startTime[i].substring(2, 5) +
                  ' PM');
        if (int.parse(endTime[i].substring(0, 2)) < 12)
          endTime12Hour.add(data[i]['end_time'] + ' AM');
        else if (int.parse(endTime[i].substring(0, 2)) == 12)
          endTime12Hour.add(data[i]['endTime'] + ' PM');
        else if (int.parse(endTime[i].substring(0, 2)) == 0)
          endTime12Hour.add(data[i]['endTime'] + ' AM');
        else
          endTime12Hour.add(
              (int.parse(endTime[i].substring(0, 2)) - 12).toString() +
                  endTime[i].substring(2, 5) +
                  ' PM');
      });

      if (int.parse(startTime[i].substring(0, 2)) <= DateTime.now().hour &&
          int.parse(endTime[i].substring(0, 2)) >= DateTime.now().hour) {
        setState(() {
          start = startTime12Hour[i];
          end = endTime12Hour[i];
        });
      }
      print(start);
    }

    print(startTime);
    print(endTime);

    if (start == '')
      setState(() {
        open = false;
      });
    else
      setState(() {
        open = true;
      });

    // for (int i = 0; i < startTime.length; i++) {
    //
    //
    // }
  }

  getMarketsForGPS() async {
    final response = await http.get(
        Uri.parse(
            "${HomePage.URL}vendors?lat=${currentLocation!.latitude}&long=${currentLocation!.longitude}"),
        headers: {
          // "Authorization": "Bearer $token",
          "Content-Language": 'en',
        });

    var data = json.decode(response.body);
    log(data.toString());

    setState(() {
      for (int i = 0; i < data.length; i++) {
        if (data[i]['vendor']['lat'] != null) {
          allLocationsGPS.add(new LocationModel(
            data[i]['vendor']['id'],
            "${data[i]['description_ar']}",
            "${data[i]['description_en']}",
            "${data[i]['vendor']['image']}",
            "${data[i]['vendor']['lat']}",
            "${data[i]['vendor']['long']}",
            data[i]['vendor']['vendor_id'],
            "${data[i]['name_ar']}",
            "${data[i]['name_en']}",
            rate: data[i]['rate'].toDouble(),
          ));
          print(data[i]['rate']);
        }
      }

      print(data[0]);
    });
  }

  Future<Uint8List> getBytesFromAsset1(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // void displayToastMessage(var toastMessage) {
  //   Fluttertoast.showToast(
  //       msg: toastMessage.toString(),
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  //   // _goToHome();
  // }

  void goToHome(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vendorID', id);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(
                isHomeScreen: true,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (c) => HomePage(
                        isHomeScreen: true,
                      )),
              (route) => false);
          return Future.value(true);
        },
        child: Center(
          child: noMarketsOnMap
              ? Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).size.width / 1.2),
                      Center(
                        child: Text(
                          "لا يوجد متاجر بالقرب منك",
                          style: TextStyle(
                              color: HomePage.colorGreen,
                              fontSize: MediaQuery.of(context).size.width / 15),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width / 25),
                      ButtonTheme(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
                        minWidth: 100.0,
                        height: MediaQuery.of(context).size.width / 8,
                        child: RaisedButton(
                          child: Text("اعادة تحميل",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 20,
                                  color: Colors.white)),
                          color: HomePage.colorGreen,
                          onPressed: () {
                            getLocationStatus();
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: currentLocation == null
                          ? Center(
                              child: Container(
                              height: 100,
                              width: 100,
                              child: lottie.Lottie.asset(
                                  'assets/images/lf20_mvihowzk.json'),
                            ))
                          : GoogleMap(
                              mapType: MapType.normal,
                              zoomControlsEnabled: false,
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(currentLocation!.latitude,
                                      currentLocation!.longitude),
                                  zoom: 10),
                              onMapCreated: (GoogleMapController controller) {
                                mapController = controller;
                              },
                              markers: _createMarker(allLocationsGPS).toSet(),
                            ),
                    ),
                    Container(
                      height: size.height * 0.25,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.7),
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.02),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 20,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage(
                                        isHomeScreen: true,
                                      )));
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          child: Icon(
                            lan == 'en'
                                ? Icons.arrow_back_ios
                                : Icons.arrow_forward_ios,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.15,
                      right: size.width * 0.05,
                      left: size.width * 0.05,
                      child: Container(
                        width: size.width * 0.9,
                        height: 55,
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            borderRadius: new BorderRadius.all(
                                const Radius.circular(10.0))),
                        child: Center(
                          child: Text(
                            loc,
                            style:
                                TextStyle(fontSize: 18, fontFamily: 'Tajawal'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    markerTapped ? _buildContainer(location1!) : Container(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildContainer(LocationModel location) {
    print(location1!.rate!);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 190,
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.fromLTRB(20, 10, 15, 10),
            decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius:
                    new BorderRadius.all(const Radius.circular(30.0))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lan == 'ar' ? location1!.nameAr : location1!.nameEn,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            fontFamily: 'Tajawal',
                            color: open ? Colors.black : HexColor('#E20000')),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      lan == 'ar'
                          ? Text(
                              location1!.descriptionAR != "null"
                                  ? location1!.descriptionAR
                                  : '',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFamily: 'Tajawal',
                                  color: HexColor('#D5C48E')),
                            )
                          : Text(
                              location1!.descriptionEN != "null"
                                  ? location1!.descriptionEN
                                  : '',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFamily: 'Tajawal',
                                  color: HexColor('#D5C48E')),
                            ),
                      SizedBox(
                        height: 5,
                      ),
                      open
                          ? Row(
                              children: [
                                Text(
                                  translate('lan.open') + ' ',
                                  style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      color: HexColor('#40976C')),
                                ),
                                Text(
                                  start + '  :  ',
                                  style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      color: HexColor('#40976C')),
                                ),
                                Text(
                                  end,
                                  style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      color: HexColor('#40976C')),
                                ),
                              ],
                            )
                          : Text(
                              translate('lan.closed'),
                              style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  color: HexColor('#E20000'),
                                  fontSize: 14),
                            ),
                      const SizedBox(
                        height: 5,
                      ),
                      RatingBar.builder(
                        initialRating: location1!.rate!,
                        ignoreGestures: true,
                        itemSize: 20,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 12,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (open)
                            goToHome(location.vendor_id);
                          else
                            showSimpleNotification(
                                Container(
                                  height: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      translate('lan.branchClosed'),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontFamily: 'Tajawal',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                duration: Duration(seconds: 3),
                                background: HomePage.colorYellow);
                        },
                        child: Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                            color: open
                                ? HexColor('#40976C')
                                : HexColor('#E20000'),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              open
                                  ? translate('lan.orderNow')
                                  : translate('lan.closed'),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'Tajawal'),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(100.0),
                        topRight: const Radius.circular(40.0),
                        bottomLeft: const Radius.circular(40.0),
                        bottomRight: const Radius.circular(40.0),
                      )),
                  child: location.image.toString() != "null"
                      ? Image.network(
                          location.image,
                          fit: BoxFit.contain,
                        )
                      : Image.asset('assets/images/logo.png'),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 85,
        )
      ],
    );
  }
  //
  // Widget _boxes(String _image, double lat, double long, String restaurantName) {
  //   return GestureDetector(
  //     // onTap: () {
  //     //   _gotoLocation(lat,long);
  //     // },
  //     child: Container(
  //       child: new FittedBox(
  //         child: Material(
  //             color: Colors.white,
  //             elevation: 14.0,
  //             borderRadius: BorderRadius.circular(20.0),
  //             shadowColor: Color(0x802196F3),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: <Widget>[
  //                 Container(
  //                   width: MediaQuery.of(context).size.width / 5,
  //                   height: MediaQuery.of(context).size.width / 5,
  //                   child: ClipRRect(
  //                     borderRadius: new BorderRadius.circular(24.0),
  //                     child: Image(
  //                       fit: BoxFit.fill,
  //                       image: NetworkImage(_image),
  //                     ),
  //                   ),
  //                 ),
  //                 Container(
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: myDetailsContainer1(restaurantName),
  //                   ),
  //                 ),
  //               ],
  //             )),
  //       ),
  //     ),
  //   );
  // }

  // Widget myDetailsContainer1(String restaurantName) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: <Widget>[
  //       Padding(
  //         padding: const EdgeInsets.only(left: 8.0),
  //         child: Container(
  //             child: Text(
  //           restaurantName,
  //           style: TextStyle(
  //               color: Color(0xff6200ee),
  //               fontSize: 24.0,
  //               fontWeight: FontWeight.bold),
  //         )),
  //       ),
  //       SizedBox(height: 5.0),
  //       Container(
  //           child: Text(
  //         "Shormeah",
  //         style: TextStyle(
  //           color: Colors.black54,
  //           fontSize: 18.0,
  //         ),
  //       )),
  //       SizedBox(height: 70.0),
  //     ],
  //   );
  // }

  // Future<void> _gotoLocation(double lat,double long) async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, long), zoom: 15,tilt: 50.0,
  //     bearing: 45.0,)));
  // }
}
