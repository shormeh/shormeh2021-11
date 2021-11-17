import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

import 'login.dart';

class ResetPassword extends StatefulWidget {
  String? phone;
  ResetPassword({this.phone});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController newPasswordCtrl = new TextEditingController();
  TextEditingController confirmNewPasswordCtrl = new TextEditingController();
  int lan = 0;
  bool seePassword = false;
  bool seePassword1 = false;
  final _formKey = GlobalKey<FormState>();

  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    int lan1 = prefs.getInt('translateLanguage')!;
    setState(() {
      lan = lan1;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: lan == 0 ? TextDirection.rtl : TextDirection.ltr,
        child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: AssetImage('assets/images/loginBackground.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Directionality(
              textDirection: lan == 1 ? TextDirection.rtl : TextDirection.ltr,
              child: Form(
                key: _formKey,
                child: new ListView(children: <Widget>[
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
                                  size: MediaQuery.of(context).size.width / 15,
                                )),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 15,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(translate('lan.resetPassword'),
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

                  Container(
                    padding: new EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 15,
                        right: MediaQuery.of(context).size.width / 15),
                    child: TextFormField(
                      obscureText: !seePassword,
                      controller: newPasswordCtrl,
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              seePassword = !seePassword;
                            });
                          },
                          child: Icon(
                            seePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                        ),
                        icon: Icon(Icons.security, color: HexColor('#40976c')),
                        enabledBorder: new UnderlineInputBorder(
                            borderSide:
                                new BorderSide(color: HomePage.colorGrey)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: HomePage.colorGrey),
                        ),
                        labelStyle: new TextStyle(color: HomePage.colorGrey),
                        hintText: translate('lan.password'),
                        labelText: translate('lan.password'),
                      ),
                      cursorColor: HomePage.colorGrey,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return translate('lan.passwordRequired');
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 20),
                  //كلمة السر
                  Container(
                    padding: new EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 15,
                        right: MediaQuery.of(context).size.width / 15),
                    child: TextFormField(
                      obscureText: !seePassword1,
                      controller: confirmNewPasswordCtrl,
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              seePassword1 = !seePassword1;
                            });
                          },
                          child: Icon(
                            seePassword1
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                        ),
                        icon: Icon(Icons.security, color: HexColor('#40976c')),
                        enabledBorder: new UnderlineInputBorder(
                            borderSide:
                                new BorderSide(color: HomePage.colorGrey)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: HomePage.colorGrey),
                        ),
                        labelStyle: new TextStyle(color: HomePage.colorGrey),
                        hintText: translate('lan.confirmPassword'),
                        labelText: translate('lan.confirmPassword'),
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
                  SizedBox(height: 50),
                  //Submit
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
                        child: Text(translate('lan.arsl'),
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 20,
                                color: Colors.white)),
                        color: HomePage.colorGreen,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (newPasswordCtrl.text !=
                                confirmNewPasswordCtrl.text)
                              _showMyDialog(translate('lan.doesNotMatch'));
                            else
                              sendDataToServer(context);
                          }
                        },
                      ),
                    ),
                  ),
                ]),
              ),
            )),
      ),
    );
  }

  Future sendDataToServer(BuildContext context) async {
    var response = await http
        .post(Uri.parse("${HomePage.URL}auth/new-password"), headers: {
      "Content-Language": lan == 0 ? "en" : "ar"
    }, body: {
      "password": "${newPasswordCtrl.text}",
      "phone": widget.phone,
    });

    var datauser = json.decode(response.body);

    if (datauser['success'] == "1") {
      displayToastMessage(datauser['message'].toString());
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    } else {
      displayToastMessage(datauser['message'].toString());
    }
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
