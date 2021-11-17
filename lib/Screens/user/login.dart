import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';
import 'package:shormeh/Screens/user/signup.dart';

import '../SelectBrabche.dart';
import 'forgetpassword.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final phoneNumberCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  var datauser;
  int lan = 0;
  bool seePassword = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();
    FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        tokenFCM = value!;
      });
    });
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
          body: new Container(
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SelectBranche()),
                                );
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
                            child: Text(translate('lan.login'),
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
                        controller: phoneNumberCtrl,
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
                    SizedBox(height: MediaQuery.of(context).size.width / 20),
                    //تحميل

                    //كلمة السر
                    Container(
                      padding: new EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 15,
                          right: MediaQuery.of(context).size.width / 15),
                      child: TextFormField(
                        obscureText: !seePassword,
                        controller: passwordCtrl,
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
                          icon:
                              Icon(Icons.security, color: HexColor('#40976c')),
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
                    SizedBox(height: 35),
                    InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgetPassword()),
                          );
                        },
                        child: Container(
                            height: 20,
                            alignment: Alignment.center,
                            child: Text(
                              translate('lan.forgetPassword'),
                              style: TextStyle(fontSize: 16),
                            ))),

                    SizedBox(
                      height: 30,
                    ),

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
                          child: Text(translate('lan.login'),
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
                    new Padding(
                      padding: new EdgeInsets.only(
                          top: MediaQuery.of(context).size.width / 20),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                        );
                      },
                      child: Center(
                        child: Text(
                          translate('lan.newAccount'),
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 25),
                        ),
                      ),
                    ),
                  ]),
                ),
              )),
        ));
  }

  var tokenFCM = "";

  Future SendDataToServer(BuildContext context) async {
    var response =
        await http.post(Uri.parse("${HomePage.URL}auth/login"), headers: {
      "Content-Language": lan == 0 ? "en" : "ar"
    }, body: {
      "phone": phoneNumberCtrl.text,
      "password": passwordCtrl.text,
      "device_id": tokenFCM,
    });
    datauser = json.decode(response.body);
    print(datauser);
    if ("${datauser['success']}" == "1") {
      displayToastMessage(translate('lan.welcome'));
      saveDataInSharedPref(context);
    } else {
      _showMyDialog(datauser['message'].toString());
    }
  }

  void saveDataInSharedPref(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLogin', true);
    await prefs.setString('name', "${datauser['name']}");
    await prefs.setString('phone', "${datauser['phone']}");
    await prefs.setString('token', "${datauser['access_token']}");

    print("=>${datauser['name']}");
    print("=>${datauser['phone']}");
    print("=>${datauser['email']}");
    print("=>${datauser['access_token']}");

    goToHome(context);
  }

  goToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => HomePage(
                isHomeScreen: true,
              )),
    );

//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => Login(fromMyAccount: false,)),
//    );
  }

  onBackPressed(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  isHomeScreen: true,
                )));
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
