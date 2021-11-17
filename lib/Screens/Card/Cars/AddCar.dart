import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Screens/Card/Cars/CarsList.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class AddCar extends StatefulWidget {
  @override
  _AddCarState createState() => _AddCarState();
}

class _AddCarState extends State<AddCar> {
  bool circularIndicatorActive = false;

  final carModelCtrl = TextEditingController();
  final platCtrl = TextEditingController();
  final colorCtrl = TextEditingController();

  String cardToken = "";
  String token = "";
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  String lan = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => onBackPressed(context),
        child: Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              elevation: 5.0,
              backgroundColor: HexColor('#40976c'),
              title: Text(
                translate('lan.addCar'),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                ),
                onPressed: () => onBackPressed(context),
              ),
            ),
            body: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: ListView(children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    //الاسم
                    Container(
                      padding: new EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 15,
                          right: MediaQuery.of(context).size.width / 15),
                      child: TextFormField(
                        controller: carModelCtrl,
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
                          hintText: translate('lan.carModel'),
                          labelText: translate('lan.carModel'),
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
                        controller: platCtrl,
                        decoration: new InputDecoration(
                          //icon:Icon(Icons.email),
                          enabledBorder: new UnderlineInputBorder(
                              borderSide:
                                  new BorderSide(color: HomePage.colorGrey)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: HomePage.colorGrey),
                          ),
                          labelStyle: new TextStyle(color: HomePage.colorGrey),
                          hintText: translate('lan.platNumber'),
                          labelText: translate('lan.platNumber'),
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

                    //color
                    Container(
                      padding: new EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 15,
                          right: MediaQuery.of(context).size.width / 15),
                      child: TextFormField(
                        controller: colorCtrl,
                        decoration: new InputDecoration(
                          //icon:Icon(Icons.email),
                          enabledBorder: new UnderlineInputBorder(
                              borderSide:
                                  new BorderSide(color: HomePage.colorGrey)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: HomePage.colorGrey),
                          ),
                          labelStyle: new TextStyle(color: HomePage.colorGrey),
                          hintText: translate('lan.carColor'),
                          labelText: translate('lan.carColor'),
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
                    SizedBox(height: 60),

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
                loading
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
                    : Container()
              ],
            )));
  }

  Future SendDataToServer(BuildContext context) async {
    setState(() {
      loading = true;
    });
    var response =
        await http.post(Uri.parse("${HomePage.URL}cart/add_car"), headers: {
      "Authorization": "Bearer $token",
      "Content-Language": lan
    }, body: {
      "car_model": "${carModelCtrl.text}",
      "plate_number": "${platCtrl.text}",
      "car_color": "${colorCtrl.text}",
      "cart_token": cardToken
    });
    print("${carModelCtrl.text}");
    print("${platCtrl.text}");
    print("${colorCtrl.text}");

    print("$cardToken");

    var datauser = json.decode(response.body);
    print("$datauser");
    if ("${datauser['success']}" == "1") {
      displayToastMessage(datauser['message']);
      print("${datauser['message']}");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (c) => CarsList(
                  added: true,
                )),
      );
    } else {
      displayToastMessage(datauser['errors'][0]['message'].toString());
    }
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
