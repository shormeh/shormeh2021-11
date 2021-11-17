import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';
import 'package:shormeh/Screens/user/verfiySignUp.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();

  final phoneCtrl = TextEditingController();
  int lan = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();
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
    return Scaffold(
      body: Directionality(
        textDirection: lan == 1 ? TextDirection.rtl : TextDirection.ltr,
        child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: AssetImage('assets/images/loginBackground.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: ListView(
              children: [
                Form(
                  key: _formKey,
                  child: new Column(children: <Widget>[
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
                                Navigator.pop(context);
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width / 8,
                                  height: MediaQuery.of(context).size.width / 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                    color: HomePage.colorYellow,
                                  ),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size:
                                        MediaQuery.of(context).size.width / 15,
                                  )),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 15,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(translate('lan.forgetPassword'),
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 10,
                    ),

                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                      height: MediaQuery.of(context).size.width / 3,
                      decoration: new BoxDecoration(
                        image: new DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 15),

                    //الموبايل
                    Container(
                      padding: new EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 15,
                          right: MediaQuery.of(context).size.width / 15),
                      child: TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: new InputDecoration(
                          icon: Icon(Icons.phone, color: HexColor('#40976c')),
                          enabledBorder: new UnderlineInputBorder(
                              borderSide:
                                  new BorderSide(color: HomePage.colorGrey)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: HomePage.colorGrey),
                          ),
                          labelStyle: new TextStyle(color: HomePage.colorGrey),
                          hintText: translate('lan.phoneNumber'),
                          labelText: translate('lan.phoneNumber'),
                        ),
                        cursorColor: HomePage.colorGrey,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return translate('lan.phoneRequired');
                          } else if (value.length != 10) {
                            return translate('lan.phone10');
                          } else if (!value.startsWith('05')) {
                            return translate('lan.phone050');
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 60),

                    //Submit
                    Container(
                      margin: new EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 15,
                          right: MediaQuery.of(context).size.width / 15),
                      child: ButtonTheme(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
                        minWidth: 300.0,
                        height: MediaQuery.of(context).size.width / 8,
                        child: RaisedButton(
                          child: Text(translate('lan.arsl'),
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 20,
                                  color: Colors.white)),
                          color: HomePage.colorGreen,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              sendDataToServer(context);
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: new EdgeInsets.only(
                          top: MediaQuery.of(context).size.width / 20),
                    ),
                  ]),
                )
              ],
            )),
      ),
    );
  }

  Future sendDataToServer(BuildContext context) async {
    var response = await http
        .post(Uri.parse("${HomePage.URL}auth/forget-password"), headers: {
      "Content-Language": lan == 0 ? "en" : "ar"
    }, body: {
      "phone": phoneCtrl.text,
    });
    var datauser = json.decode(response.body);
    log(datauser.toString());
    if (datauser['success'] == "1") {
      displayToastMessage(datauser['message']);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerfySignup(
                    phone: phoneCtrl.text,
                  )));
    } else {
      displayToastMessage(datauser['message'].toString());
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
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        duration: Duration(seconds: 3),
        background: HomePage.colorYellow);
  }
}
