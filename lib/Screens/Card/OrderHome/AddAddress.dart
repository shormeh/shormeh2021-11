import 'dart:convert';

import 'package:android_intent/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart' as lottie;
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Screens/Card/OrderHome/AdressList.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class AddAddress extends StatefulWidget {
  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  bool circularIndicatorActive = false;

  final distictCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  bool isIndicatorActive = true;
  Position? currentLocation;

  String cardToken = "";
  String token = "";
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  String lan = '';
  GoogleMapController? mapController;
  bool markerTapped = false;

  Marker? marker;
  double? lat;
  double? lng;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();

    getLocationStatus();
  }

  getLocationStatus() async {
    var status = await Geolocator.isLocationServiceEnabled();
    if (status) {
      setState(() {
        // هفعل السيركل عشان الفيو وهى هتطفى تانى من تحت وهقول ان فى صيدليات بعد ماكان الموقع مش متفعل
        getUserLocation();
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

  getUserLocation() async {
    currentLocation = await locateUser();
    setState(() {
      markerTapped = true;
      marker =
          createMarker(currentLocation!.latitude, currentLocation!.longitude);
      lat = currentLocation!.latitude;
      lng = currentLocation!.longitude;
    });
    print(lat.toString() + 'ggg');
  }

  Future<Position> locateUser() {
    return Geolocator.getCurrentPosition();
  }

  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    final _cardToken = prefs.getString("cardToken");
    final _token = prefs.getString("token");
    int _lan = prefs.getInt('translateLanguage')!;
    setState(() {
      _lan == 1 ? lan = 'ar' : lan = 'en';
      cardToken = _cardToken!;
      token = _token!;
    });
  }

  onBackPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  Marker createMarker(double latitude, double longitude) {
    return Marker(
      draggable: true,
      markerId: MarkerId('Marker'),
      position: LatLng(latitude, longitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          backgroundColor: HexColor('#40976c'),
          elevation: 0,
          title: Text(translate('lan.addAdress')),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            new Container(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  //الاسم
                  Container(
                    padding: new EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 15,
                        right: MediaQuery.of(context).size.width / 15),
                    child: TextFormField(
                      controller: noteCtrl,
                      decoration: new InputDecoration(
                        //icon:Icon(Icons.email),
                        enabledBorder: new UnderlineInputBorder(
                            borderSide:
                                new BorderSide(color: HomePage.colorGrey)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: HomePage.colorGrey),
                        ),
                        labelStyle: new TextStyle(color: HomePage.colorGrey),
                        hintText: translate('lan.address'),
                        labelText: translate('lan.address'),
                      ),
                      cursorColor: HomePage.colorGrey,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return translate('lan.fieldRequired');
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.width / 20),
                  //plat
                  Container(
                    padding: new EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 15,
                        right: MediaQuery.of(context).size.width / 15),
                    child: TextFormField(
                      controller: distictCtrl,
                      keyboardType: TextInputType.name,
                      decoration: new InputDecoration(
                        //icon:Icon(Icons.),
                        enabledBorder: new UnderlineInputBorder(
                            borderSide:
                                new BorderSide(color: HomePage.colorGrey)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: HomePage.colorGrey),
                        ),
                        labelStyle: new TextStyle(color: HomePage.colorGrey),
                        hintText: translate('lan.details'),
                        labelText: translate('lan.details'),
                      ),
                      cursorColor: HomePage.colorGrey,
                    ),
                  ),
                  const SizedBox(height: 40),

                  markerTapped
                      ? Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: GoogleMap(
                              mapType: MapType.terrain,
                              myLocationEnabled: true,
                              zoomControlsEnabled: false,
                              onTap: (location) {
                                setState(() {
                                  marker = createMarker(
                                      location.latitude, location.longitude);
                                  lat = location.latitude;
                                  lng = location.longitude;
                                });
                                print(lat);
                              },
                              initialCameraPosition: CameraPosition(
                                target: LatLng(currentLocation!.latitude,
                                    currentLocation!.longitude),
                                zoom: 14.0,
                              ),
                              markers: Set<Marker>.of(
                                <Marker>[marker!],
                              ),
                              onMapCreated: (GoogleMapController controller) {
                                mapController = controller;
                              },
                            ),
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 40),

                  Container(
                    margin: new EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 15,
                        right: MediaQuery.of(context).size.width / 15),
                    child: ButtonTheme(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0)),
                      minWidth: 500.0,
                      height: MediaQuery.of(context).size.width / 8,
                      child: RaisedButton(
                        child: Text(translate('lan.submit'),
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 20,
                                color: Colors.white)),
                        color: HomePage.colorGreen,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            SendDataToServer(context);
                          }
                        },
                      ),
                    ),
                  ),
                ]),
              ),
            )),
            loading
                ? Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.6),
                    child: Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        child: lottie.Lottie.asset(
                          'assets/images/lf20_mvihowzk.json',
                          fit: BoxFit.fill,
                          height: 100,
                          width: 100,
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ));
  }

  Future SendDataToServer(BuildContext context) async {
    setState(() {
      loading = true;
    });
    print(lat.toString() + 'hhh');
    var response =
        await http.post(Uri.parse("${HomePage.URL}cart/add_address"), headers: {
      "Authorization": "Bearer $token",
      "Content-Language": lan
    }, body: {
      "district": "${distictCtrl.text}",
      "address": "${noteCtrl.text}",
      "lat": "${lat}",
      "lng": "${lng}",
      "cart_token": cardToken
    });
    print("${distictCtrl.text}");
    print("${noteCtrl.text}");
    print("${currentLocation!.latitude}");

    print("$cardToken");

    var datauser = json.decode(response.body);
    print("$datauser");
    if ("${datauser['success']}" == "1") {
      displayToastMessage(datauser['message']);
      print("${datauser['message']}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AdressList(
                  added: true,
                )),
      );
    } else {
      displayToastMessage(datauser['errors'][0]['message'].toString());
    }

    loading = false;
  }

  void displayToastMessage(var toastMessage) {
    showSimpleNotification(
        Container(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              toastMessage,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        duration: Duration(seconds: 3),
        background: HomePage.colorYellow);
    // Fluttertoast.showToast(
    //     msg: toastMessage.toString(),
    //     toastLength: Toast.LENGTH_LONG,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 10,
    //     textColor: Colors.white,
    //     fontSize: 16.0
    // );
    // _goToHome();
  }
}
