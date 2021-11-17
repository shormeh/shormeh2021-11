import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';
import 'package:shormeh/Screens/SelectBrabche.dart';
import 'package:shormeh/Screens/user/login.dart';
import 'package:shormeh/Screens/user/policy_and_conitions.dart';
import 'package:shormeh/Screens/user/verfiySignUp.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool circularIndicatorActive = false;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int lan = 0;
  bool seePassword = false;
  bool agree = false;

  @override
  void initState() {
    // TODO: implement initState
    getDataFromSharedPrfs();
    super.initState();
  }

  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    int lan1 = prefs.getInt('translateLanguage')!;
    setState(() {
      lan = lan1;
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
          body: new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: AssetImage(
                    'assets/images/loginBackground.png',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: Directionality(
                textDirection: lan == 1 ? TextDirection.rtl : TextDirection.ltr,
                child: Form(
                  key: _formKey,
                  child: ListView(children: <Widget>[
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
                            child: Text(translate('lan.signUp2'),
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

                    //الاسم
                    Container(
                      padding: new EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 15,
                          right: MediaQuery.of(context).size.width / 15),
                      child: TextFormField(
                        controller: nameCtrl,
                        keyboardType: TextInputType.name,
                        decoration: new InputDecoration(
                          icon: Icon(Icons.person, color: HexColor('#40976c')),
                          enabledBorder: new UnderlineInputBorder(
                              borderSide:
                                  new BorderSide(color: HomePage.colorGrey)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: HomePage.colorGrey),
                          ),
                          labelStyle: new TextStyle(color: HomePage.colorGrey),
                          hintText: translate('lan.name'),
                          labelText: translate('lan.name'),
                        ),
                        cursorColor: HomePage.colorGrey,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return translate('lan.nameRequired');
                          }
                          if (value.length < 2) {
                            return translate('lan.nameSmall');
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 20),
                    Container(
                      padding: new EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 15,
                          right: MediaQuery.of(context).size.width / 15),
                      child: TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: new InputDecoration(
                          icon: Icon(
                            Icons.phone,
                            color: HexColor('#40976c'),
                          ),
                          enabledBorder: new UnderlineInputBorder(
                              borderSide:
                                  new BorderSide(color: HomePage.colorGrey)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: HomePage.colorGrey),
                          ),
                          labelStyle: new TextStyle(
                            color: HomePage.colorGrey,
                          ),
                          hintText: translate('lan.phoneNumber'),
                          labelText: translate('lan.phoneNumber'),
                        ),
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
                        cursorColor: HomePage.colorGrey,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 20),
                    //كلمة السر
                    Container(
                      padding: new EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 15,
                          right: MediaQuery.of(context).size.width / 15),
                      child: TextFormField(
                        controller: passwordCtrl,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !seePassword,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return translate('lan.passwordRequired');
                          }
                          return null;
                        },
                        cursorColor: HomePage.colorGrey,
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
                        minWidth: 500.0,
                        height: MediaQuery.of(context).size.width / 8,
                        child: RaisedButton(
                          child: Text(translate('lan.signUp2'),
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 20,
                                  color: Colors.white)),
                          color: agree ? HomePage.colorGreen : Colors.black12,
                          onPressed: () {
                            if (agree) {
                              if (_formKey.currentState!.validate()) {
                                SendDataToServer(context);
                              }
                            } else
                              displayToastMessage(translate('lan.mustAgree'));
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: new EdgeInsets.only(
                          top: MediaQuery.of(context).size.width / 20),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: Center(
                        child: Text(
                          translate('lan.haveAccount'),
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 25),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 23, right: 5, left: 5),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                agree = !agree;
                              });
                            },
                            child: Image.asset(
                              agree
                                  ? 'assets/images/checkbox.png'
                                  : 'assets/images/blank-check-box.png',
                              color: HomePage.colorGreen,
                              height: 25,
                              width: 25,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ConditionsAndRules()));
                            },
                            child: Text(
                              translate('lan.policy'),
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 60,
                    ),
                  ]),
                ),
              )),
        ));
  }

  Future SendDataToServer(BuildContext context) async {
    var response = await http.post(Uri.parse("${HomePage.URL}auth/register"),
        headers: {
          "Accept": "application/json",
          "Content-Language": lan == 0 ? "en" : "ar"
        },
        body: {
          "name": nameCtrl.text,
          "password": passwordCtrl.text,
          "phone": phoneCtrl.text
        });

    var datauser = json.decode(response.body);
    print(datauser);
    if ("${datauser['success']}" == "1") {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VerfySignup(
                  name: nameCtrl.text,
                  password: passwordCtrl.text,
                  phone: phoneCtrl.text,
                )),
      );
    } else {
      _showMyDialog(datauser['errors']['phone'][0].toString());
      // displayToastMessage(datauser['errors']['phone'][0].toString());
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
    // Fluttertoast.showToast(
    //     msg: toastMessage.toString(),
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     textColor: Colors.white,
    //     fontSize: 16.0);

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
      duration: Duration(seconds: 2),
      background: HomePage.colorYellow,
      position: NotificationPosition.bottom,
    );
  }
}
