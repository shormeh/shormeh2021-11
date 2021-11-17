import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class Card6TaqeemElkhdma extends StatefulWidget {
  int? vendorID;
  String? token;
  String? orderId;
  Card6TaqeemElkhdma({this.token, this.vendorID, this.orderId});
  @override
  _Card6TaqeemElkhdmaState createState() => _Card6TaqeemElkhdmaState();
}

class _Card6TaqeemElkhdmaState extends State<Card6TaqeemElkhdma> {
  int branchRating = 3;
  int foodRating = 3;
  int priceRating = 3;
  TextEditingController tECComment = new TextEditingController();

  @override
  void initState() {
    super.initState();

    //_rating = _initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            translate('lan.takeemElkhdma'),
          ),
          centerTitle: true,
          backgroundColor: HexColor('#40976c'),
          elevation: 5.0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 100,
                      height: 120,
                      child: Lottie.asset('assets/lottieRate.json')),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    translate('lan.pleaseTakeemElkhdma'),
                    style: TextStyle(color: HomePage.colorGrey, fontSize: 17),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                  child: Text(
                translate('lan.branchRate'),
                style: TextStyle(
                    color: HomePage.colorGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              )),
              SizedBox(
                height: 10,
              ),
              Center(
                child: RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      print("XXXXXXX$rating");
                      branchRating = rating.toInt();
                    });
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                  child: Text(
                translate('lan.foodRate'),
                style: TextStyle(
                    color: HomePage.colorGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              )),
              SizedBox(
                height: 10,
              ),
              Center(
                child: RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    print("XXXXXXX$rating");

                    setState(() {
                      foodRating = rating.toInt();
                    });
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                  child: Text(
                translate('lan.priceRate') + '..',
                style: TextStyle(
                    color: HomePage.colorGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              )),
              SizedBox(
                height: 10,
              ),
              Center(
                child: RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      priceRating = rating.toInt();
                    });
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                margin: EdgeInsets.all(MediaQuery.of(context).size.width / 20),
                child: Stack(
                  children: <Widget>[
                    //خلفية الكارت
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width / 2.5,
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
                            offset: Offset(0, 2), // changes position of shadow
                          ),
                        ],
                      ),
                    ),
                    //المحتوى
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(
                              MediaQuery.of(context).size.width / 20),
                          child: TextField(
                            controller: tECComment,
                            decoration: new InputDecoration(
                              hintText:
                                  translate('lan.molhazatawektrahet') + ' ...',
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 30),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: HexColor('#40976c')),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: HexColor('#40976c')),
                              ),
                            ),
                            cursorColor: HomePage.colorGreen,
                            maxLines: 3,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
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
                      senToRate();
                    },
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 20,
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ));
  }

  void senToRate() async {
    var response =
        await http.post(Uri.parse("${HomePage.URL}rate/vendor"), headers: {
      "Authorization": "Bearer ${widget.token}",
    }, body: {
      "vendor_id": widget.vendorID.toString(),
      "rate_vendor": branchRating.toString(),
      "rate_taste": foodRating.toString(),
      "rate_price": priceRating.toString(),
      "comment": tECComment.text,
      "order_id": widget.orderId
    });

    var datauser = json.decode(response.body);

    if ("${datauser['success']}" == "1") {
      displayToastMessage(translate('lan.survey'));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => HomePage(
                    isHomeScreen: true,
                  )),
          (Route<dynamic> route) => false);
    }
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
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        duration: Duration(seconds: 3),
        background: HomePage.colorYellow);
  }
}
