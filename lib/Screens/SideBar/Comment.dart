import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';
import 'package:http/http.dart' as http;

class Comment extends StatefulWidget {
  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  TextEditingController tECCommentSubject = new TextEditingController();
  TextEditingController tECComment = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  senToMustafa() async {
    var response = await http.post(Uri.parse("${HomePage.URL}settings/contactus"), body: {
      "title": tECCommentSubject.text,
      "message": tECComment.text,
    });
    var data = json.decode(response.body);
    if ("${data['success']}" == "1") {
      displayToastMessage(data['message'].toString());

    } else {
      displayToastMessage(data['message'].toString());
    }
  }

  onBackPressed(BuildContext context) async {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () => onBackPressed(context),
      child: Scaffold(
        appBar: new AppBar(
          backgroundColor: HexColor('#40976c'),
          title: Text(
            translate('lan.contactUs'),
          ),
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios),
          ),
        ),
        body: Container(
          color: Color(0xfff8f9f9),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(MediaQuery.of(context).size.width / 12),
                  child: Text(translate('lan.leaveMessage'),
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 25,
                          color: Colors.black)),
                ),
                //Subject
                Container(
                  margin: EdgeInsets.all(MediaQuery.of(context).size.width / 20),
                  child: Stack(
                    children: <Widget>[
                      //المحتوى
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  //مستوى الوضوح مع اللون
                                  color: Colors.grey.withOpacity(0.7),
                                  //مدى انتشارة
                                  spreadRadius: 2,
                                  //مدى تقلة
                                  blurRadius: 5,
                                  offset:
                                      Offset(0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width / 30),
                            child: TextFormField(
                              controller: tECCommentSubject,
                              decoration: new InputDecoration(
                                hintText: translate('lan.subject'),
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                    MediaQuery.of(context).size.width / 30),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color:HexColor('#40976c')),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: HexColor('#40976c')),
                                ),

                              ),
                              cursorColor: HomePage.colorGreen,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return translate('lan.fieldRequired');
                                }
                                return null;
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                //Message
                Container(
                  margin: EdgeInsets.all(MediaQuery.of(context).size.width / 20),
                  child: Stack(
                    children: <Widget>[
                      //المحتوى
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  //مستوى الوضوح مع اللون
                                  color: Colors.grey.withOpacity(0.7),
                                  //مدى انتشارة
                                  spreadRadius: 2,
                                  //مدى تقلة
                                  blurRadius: 5,
                                  offset:
                                      Offset(0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width / 30),
                            child: TextFormField(
                              controller: tECComment,
                              decoration: new InputDecoration(
                                hintText: translate('lan.AddQuestion'),
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                    MediaQuery.of(context).size.width / 30),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color:HexColor('#40976c')),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: HexColor('#40976c')),
                                ),
                              ),
                              cursorColor: HomePage.colorGreen,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return translate('lan.fieldRequired');
                                }
                                return null;
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                //SEND
                Container(
                  margin: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width / 3.5,
                      MediaQuery.of(context).size.width / 10,
                      MediaQuery.of(context).size.width / 3.5,
                      0.0),
                  child: ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width / 3,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0)),
                    height: MediaQuery.of(context).size.width / 8,
                    child: RaisedButton(
                      child: Text(translate('lan.send'),
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 20,
                              color: Colors.white)),
                      color: HomePage.colorGreen,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          senToMustafa();

                        }

                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
        Container(height: 50,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(toastMessage,
              style: TextStyle(color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold),),
          ),
        ),
        duration: Duration(seconds: 3),
        background:HomePage.colorYellow

    );
    tECCommentSubject.text='';
    tECComment.text='';
  }
}
