import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/Points.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class MyPoints extends StatefulWidget {
  @override
  _MyPointsState createState() => _MyPointsState();
}

class _MyPointsState extends State<MyPoints> {
  bool isIndicatorActive = true;

  onBackPressed(BuildContext context) async {
    Navigator.pop(context);
  }

  List<PointsModel> allPoints = [];

  String token = "";
  int language = 0;
  bool loading = true;
  String limit = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();
  }

  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    int lan = prefs.getInt('translateLanguage')!;

    final _token = prefs.getString("token");
    setState(() {
      token = _token!;
      language = lan;
    });

    print("$token");
    getMyPoints();
  }

  Future getMyPoints() async {
    var response =
        await http.get(Uri.parse("${HomePage.URL}customer/points"), headers: {
      "Authorization": "Bearer $token",
    });

    var data = json.decode(response.body);
    //print("$data");
    log("${data['points']}");
    allPoints = [];
    if (data["success"] == "1") {
      setState(() {
        limit = data['points_limit'].toString();
        for (int i = 0; i < data['points'].length; i++) {
          allPoints.add(new PointsModel(
              data['points'][i]['order_id'],
              data['total_points'],
              data['points_to_cash'],
              data['points'][i]['points'],
              data['points'][i]['converted']));
        }
        //فى اللحظة دية كل الصيدليات بكل الاقسام اتحمل
      });
    } else {
      print("Error");
    }
    setState(() {
      loading = false;
    });
  }

  Future usePoints() async {
    setState(() {
      loading = true;
    });
    var response = await http
        .get(Uri.parse("${HomePage.URL}customer/convert-points"), headers: {
      "Authorization": "Bearer $token",
    });

    var data = json.decode(response.body);
    print(data);
    getMyPoints();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          backgroundColor: HexColor('#40976c'),
          elevation: 5,
          title: Text(
            translate('lan.myPoints'),
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (c) => HomePage(
                          isHomeScreen: true,
                        )),
              );
            },
          ),
        ),
        body: loading
            ? Center(
                child: Container(
                height: 100,
                width: 100,
                child: Lottie.asset('assets/images/lf20_mvihowzk.json'),
              ))
            : allPoints.length == 0
                ? Column(
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      Lottie.asset('assets/images/lf20_xjqlf9e8.json'),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        translate('lan.makePoints'),
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 25,
                            color: Colors.black,
                            fontFamily: 'Tajawal'),
                      )
                    ],
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      Directionality(
                        textDirection: language == 0
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            height: 200,
                            decoration: new BoxDecoration(
                              color: Color(0xfff7f7f7),
                              borderRadius: new BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(color: Color(0xff40976C)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        translate('lan.totalEarned') + ' : ',
                                        style: TextStyle(
                                            color: Color(0xff40976C),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            fontFamily: 'Tajawal'),
                                      )),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: allPoints.length != 0
                                            ? Text(
                                                allPoints[0]
                                                        .total_points
                                                        .toString() +
                                                    ' ' +
                                                    translate('lan.point'),
                                                style: TextStyle(
                                                    color: Color(0xff40976C),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    fontFamily: 'Tajawal'),
                                              )
                                            : Text(
                                                '0' +
                                                    ' ' +
                                                    translate('lan.point'),
                                                style: TextStyle(
                                                    color: Color(0xff40976C),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    fontFamily: 'Tajawal'),
                                              ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        translate('lan.pointsLimit') + ' : ',
                                        style: TextStyle(
                                            color: Color(0xff40976C),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            fontFamily: 'Tajawal'),
                                      )),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Text(
                                          limit + ' ' + translate('lan.point'),
                                          style: TextStyle(
                                              color: Color(0xff40976C),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              fontFamily: 'Tajawal'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        translate('lan.pointsToCash') + ' : ',
                                        style: TextStyle(
                                            color: Color(0xff40976C),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            fontFamily: 'Tajawal'),
                                      )),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: allPoints.length != 0
                                            ? Text(
                                                allPoints[0]
                                                        .points_to_cash
                                                        .toString() +
                                                    ' ' +
                                                    translate('lan.rs'),
                                                style: TextStyle(
                                                    color: Color(0xff40976C),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    fontFamily: 'Tajawal'),
                                              )
                                            : Text(
                                                '0',
                                                style: TextStyle(
                                                    color: Color(0xff40976C),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    fontFamily: 'Tajawal'),
                                              ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  int.parse(limit) <= allPoints[0].total_points
                                      ? InkWell(
                                          onTap: () {
                                            usePoints();
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 220,
                                            decoration: new BoxDecoration(
                                              color: HexColor('#40976c'),
                                              borderRadius:
                                                  new BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                translate('lan.usePoints'),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    fontFamily: 'Tajawal'),
                                              ),
                                            ),
                                          ),
                                        )
                                      : InkWell(
                                          onTap: () {},
                                          child: Container(
                                            height: 40,
                                            width: 220,
                                            decoration: new BoxDecoration(
                                              color: HomePage.colorGrey,
                                              borderRadius:
                                                  new BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                translate('lan.usePoints'),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    fontFamily: 'Tajawal'),
                                              ),
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: allPoints.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              margin: EdgeInsets.fromLTRB(
                                  MediaQuery.of(context).size.width / 50,
                                  MediaQuery.of(context).size.width / 50,
                                  MediaQuery.of(context).size.width / 50,
                                  MediaQuery.of(context).size.width / 50),
                              child: Container(
                                height: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  color: Color(0xfff7f7f7),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0xfff7f7f7),
                                        spreadRadius: 0.0),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.4,
                                            child: Text(
                                              translate('lan.orderNo') +
                                                  "  ${allPoints[index].id}",
                                              style: TextStyle(
                                                  color: Color(0xff748b9d),
                                                  fontSize: 16,
                                                  fontFamily: 'Tajawal'),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 7,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.4,
                                            child: Text(
                                              translate('lan.pointsEarned') +
                                                  "   ${allPoints[index].points}",
                                              style: TextStyle(
                                                  color: Color(0xff748b9d),
                                                  fontSize: 16,
                                                  fontFamily: 'Tajawal'),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 7,
                                          ),
                                          Text(
                                            allPoints[index].converted == 0
                                                ? translate('lan.notUsed')
                                                : translate('lan.used'),
                                            style: TextStyle(
                                                color: Color(0xff748b9d),
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    30,
                                                fontFamily: 'Tajawal'),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(child: Container()),
                                    Container(
                                      alignment: Alignment.center,
                                      width:
                                          MediaQuery.of(context).size.width / 7,
                                      height:
                                          MediaQuery.of(context).size.width / 7,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xff40976C),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${allPoints[index].points}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    27,
                                                fontFamily: 'Tajawal'),
                                          ),
                                          Text(
                                            translate('lan.point'),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    27,
                                                fontFamily: 'Tajawal'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(child: Container()),
                                  ],
                                ),
                              ));
                        },
                      ),
                      Container(
                        height: 70,
                      )
                    ],
                  ));
  }
}
