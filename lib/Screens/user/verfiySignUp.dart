import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

import '../SelectBrabche.dart';
import 'ResetPassword.dart';

class VerfySignup extends StatefulWidget {
  String? phone;
  String? name;
  String? password;

  VerfySignup({this.name, this.password, this.phone});

  @override
  _VerfySignupState createState() => _VerfySignupState();
}

class _VerfySignupState extends State<VerfySignup> {
  var datauser;
  TextEditingController pin = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var tokenFCM = "";
  int lan = 0;

  @override
  void initState() {
    // TODO: implement initState
    getDataFromSharedPrfs();
    FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        tokenFCM = value!;
      });
    });
    super.initState();
  }

  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    int lan1 = prefs.getInt('translateLanguage')!;
    setState(() {
      lan = lan1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => onBackPressed(context),
        child: Scaffold(
          body: Directionality(
            textDirection: lan == 1 ? TextDirection.rtl : TextDirection.ltr,
            child: Container(
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: AssetImage('assets/images/loginBackground.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: ListView(
                  children: [
                    Column(children: <Widget>[
                      // Logo Image
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 20,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 10,
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SelectBranche()),
                                  );
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    width:
                                        MediaQuery.of(context).size.width / 8,
                                    height:
                                        MediaQuery.of(context).size.width / 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(30.0),
                                      ),
                                      color: HomePage.colorYellow,
                                    ),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: MediaQuery.of(context).size.width /
                                          15,
                                    )),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 15,
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(translate('lan.verifyPhone'),
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            Expanded(child: Container()),
                          ],
                        ),
                      ),
                      SizedBox(height: 100),

                      Container(
                          height: 200,
                          width: 200,
                          child: Lottie.asset('assets/images/login2.json')),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Directionality(
                            textDirection: lan == 0
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: Text(
                              ' : ' + translate('lan.verification'),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            widget.phone!,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: HexColor('#40976c')),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.width / 20,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Form(
                          key: _formKey,
                          child: PinCodeTextField(
                            appContext: context,
                            controller: pin,
                            pastedTextStyle: TextStyle(
                              color: HexColor('#40976c'),
                              fontWeight: FontWeight.bold,
                            ),
                            length: 4,
                            pinTheme: PinTheme(
                              activeColor: HexColor('#40976c'),
                              selectedColor: HexColor('#40976c'),
                              inactiveColor: HexColor('#40976c'),
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(10),
                              fieldHeight: 60,
                              fieldWidth: 60,
                            ),
                            cursorColor: HexColor('#40976c'),
                            keyboardType: TextInputType.number,
                            backgroundColor: Colors.white,
                            onChanged: (String value) {
                              print(value);
                            },
                            onCompleted: (x) {
                              setState(() {
                                pin.text = x;
                              });
                              print(pin.text);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return translate('lan.pinRequired');
                              } else if (value.length != 4) {
                                return translate('lan.pinNotCompeleted');
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 60,
                      ),

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
                            child: Text(translate('lan.verify'),
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 20,
                                    color: Colors.white)),
                            color: HomePage.colorGreen,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (widget.name != null)
                                  sendDataToServer();
                                else
                                  resetPassword();
                              }
                            },
                          ),
                        ),
                      ),
                    ])
                  ],
                )),
          ),
        ));
  }

  Future sendDataToServer() async {
    print(pin.text + 'jftjcgtfvhyj');
    print(widget.name);
    print(widget.phone);
    print(widget.password);
    var response =
        await http.post(Uri.parse("${HomePage.URL}auth/verify"), headers: {
      "Content-Language": lan == 0 ? "en" : "ar"
    }, body: {
      "name": widget.name,
      "phone": widget.phone,
      "password": widget.password,
      "otp": pin.text,
      "device_id": tokenFCM,
    });
    setState(() {
      datauser = json.decode(response.body);
    });
    print(datauser);

    if ("${datauser['success']}" == "1") {
      // displayToastMessage(datauser['message'].toString());
      saveDataInSharedPref();
    } else {
      _showMyDialog(datauser['message'].toString());
    }
  }

  resetPassword() async {
    var response = await http.post(
        Uri.parse("${HomePage.URL}auth/verify-forget-password"),
        headers: {
          "Content-Language": lan == 0 ? "en" : "ar"
        },
        body: {
          "phone": widget.phone,
          "otp": pin.text,
        });
    setState(() {
      datauser = json.decode(response.body);
    });
    print(datauser);

    if ("${datauser['success']}" == "1") {
      displayToastMessage(datauser['message'].toString());
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResetPassword(
                    phone: widget.phone,
                  )));
    } else {
      _showMyDialog(datauser['message'].toString());
    }
  }

  void saveDataInSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', true);
    await prefs.setString('name', "${datauser['name']}");
    await prefs.setString('phone', "${datauser['phone']}");
    await prefs.setString('token', "${datauser['access_token']}");

    goToHome();
  }

  goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => HomePage(
                isHomeScreen: true,
              )),
    );
  }

  onBackPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _showMyDialog(String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            translate('lan.warning'),
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(text),
          actions: <Widget>[
            Center(
                child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 40,
                width: 150,
                decoration: BoxDecoration(
                  color: HexColor('#40976c'),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(
                    child: Text(
                  translate('lan.ok'),
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )),
              ),
            )),
          ],
        );
      },
    );
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
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        duration: Duration(seconds: 3),
        background: HomePage.colorYellow);
  }
}
