import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/Card5OrderStatusModel.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';
import 'package:shormeh/Screens/SideBar/MyOdrers.dart';

class OrderStatus extends StatefulWidget {
  String? orderID;
  bool? backToMyOrders;

  OrderStatus({
    this.orderID,
    this.backToMyOrders,
  });
  @override
  _OrderStatusState createState() => _OrderStatusState();
}

class _OrderStatusState extends State<OrderStatus> {
  List<Card5OrderStatusModel> allStatusHistory = [];
  int statusID = 0;
  String lan = '';
  bool isIndicatorActive = true;

  String expectedTime = '';
  int orderMethod = 0;

  String? token;
  bool clicked = false;
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Order Status ${widget.orderID}");
    getDataFromSharedPrfs();
  }

  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    // final _cardToken = prefs.getString("cardToken");
    final _token = prefs.getString("token");
    int _lan = prefs.getInt('translateLanguage')!;
    setState(() {
      _lan == 1 ? lan = 'ar' : lan = 'en';
      token = _token;
      isIndicatorActive = true;
      allStatusHistory.clear();
    });

    getData();
  }

  getData() async {
    var response = await http.get(
        Uri.parse("${HomePage.URL}orders/${widget.orderID}/details"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Language": lan,
        });

    var dataAllOrderDetails = json.decode(response.body);

    log(dataAllOrderDetails.toString());

    setState(() {
      for (int i = 0;
          i < dataAllOrderDetails['order']['status_histories'].length;
          i++) {
        statusID =
            dataAllOrderDetails['order']['status_histories'][i]['status']['id'];
        orderMethod = dataAllOrderDetails['order']['order_method_id'];
        expectedTime = dataAllOrderDetails['order']['expected_time'] ?? "";
        allStatusHistory.add(Card5OrderStatusModel(
          dataAllOrderDetails['order']['status_histories'][i]['status']['id'],
          dataAllOrderDetails['order']['status_histories'][i]['status']['name'],
          dataAllOrderDetails['order']['status_histories'][i]['status']
              ['created_at'],
          dataAllOrderDetails['order']['status_histories'][i]['status']
              ['image'],
          dataAllOrderDetails['order']['expected_time'] ?? '',
          dataAllOrderDetails['order']['status_histories'][i]['status']
              ['name_en'],
        ));
      }

      print(statusID);
      print(orderMethod);
      if (statusID != 9)
        setState(() {
          clicked = false;
        });
      //فى اللحظة دية كل الصيدليات بكل الاقسام اتحملت
      isIndicatorActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (widget.backToMyOrders != null)
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => HomePage(
                        isHomeScreen: true,
                      )));
        else
          Navigator.pop(context);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            translate('lan.motabaaHaltEltlb'),
          ),
          centerTitle: true,
          backgroundColor: HexColor('#40976c'),
          elevation: 5.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () {
              if (widget.backToMyOrders != null)
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => HomePage(
                              isHomeScreen: true,
                            )));
              else
                Navigator.pop(context);
            },
          ),
        ),
        body: isIndicatorActive
            ? Center(
                child: Container(
                height: 100,
                width: 100,
                child: Lottie.asset('assets/images/lf20_mvihowzk.json'),
              ))
            : ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.width / 3,
                        decoration: new BoxDecoration(
                          image: new DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                          ),
                        ),
                      ),
                      expectedTime != "" && expectedTime != "null"
                          ? Text(
                              translate('lan.expectedTime') +
                                  expectedTime +
                                  ' ' +
                                  translate('lan.minute'),
                              style: TextStyle(
                                  color: HomePage.colorGreen, fontSize: 16),
                            )
                          : Container(),
                      Text(
                        translate('lan.orderNo') +
                            ' ' +
                            widget.orderID.toString(),
                        style:
                            TextStyle(color: HomePage.colorGreen, fontSize: 16),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 2,
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemCount: allStatusHistory.length,
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(
                                  20,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: SizedBox(),
                                      flex: 2,
                                    ),
                                    Container(
                                      width: 50,
                                      child: Image.network(
                                        '${allStatusHistory[index].image}',
                                        fit: BoxFit.contain,
                                        height: 35,
                                        width: 35,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          lan == 'ar'
                                              ? Text(
                                                  "${allStatusHistory[index].name}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color:
                                                          HomePage.colorGreen),
                                                )
                                              : Text(
                                                  "${allStatusHistory[index].nameEn}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color:
                                                          HomePage.colorGreen),
                                                ),
                                          Text(
                                            "${allStatusHistory[index].created_at}",
                                            style: TextStyle(
                                                color: HomePage.colorGreen),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: SizedBox(),
                                      flex: 2,
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                      orderMethod == 2 && !clicked
                          ? statusID == 9
                              ? ButtonTheme(
                                  height: 45,
                                  minWidth: 200,
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  child: RaisedButton(
                                    child: Text(
                                        translate('lan.alameelAmamAlfar'),
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white)),
                                    color: HomePage.colorGreen,
                                    onPressed: () {
                                      setState(() {
                                        clicked = true;
                                      });
                                      reachFromBranche();
                                    },
                                  ),
                                )
                              : ButtonTheme(
                                  height: 45,
                                  minWidth: 200,
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  child: RaisedButton(
                                    child: Text(
                                        translate('lan.alameelAmamAlfar'),
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white)),
                                    color: HomePage.colorGrey,
                                    onPressed: () {},
                                  ),
                                )
                          : Container(),
                      SizedBox(
                        height: MediaQuery.of(context).size.width / 20,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(child: Container()),
                            Container(
                              height: MediaQuery.of(context).size.width / 8,
                              width: MediaQuery.of(context).size.width / 2.3,
                              child: ButtonTheme(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0)),
                                height: MediaQuery.of(context).size.width / 8,
                                child: RaisedButton(
                                  child: Text(translate('lan.myOrders'),
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              25,
                                          color: Colors.white)),
                                  color: Color(0xff40976C),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyOrders()));
                                  },
                                ),
                              ),
                            ),
                            Expanded(child: Container()),
                            Container(
                              height: MediaQuery.of(context).size.width / 8,
                              width: MediaQuery.of(context).size.width / 2.3,
                              child: ButtonTheme(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0)),
                                height: MediaQuery.of(context).size.width / 8,
                                child: RaisedButton(
                                  child: Text(translate('lan.tahdeeth'),
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              25,
                                          color: Colors.white)),
                                  color: Color(0xff40976C),
                                  onPressed: () {
                                    //Navigator.pop(context);
                                    //EditAyaDialoge(allSurahListD);
                                    getDataFromSharedPrfs();
                                  },
                                ),
                              ),
                            ),
                            Expanded(child: Container()),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
      ),
    );
  }

  void reachFromBranche() async {
    displayToastMessage(translate('lan.waitOrder'));
    var response = await http.post(
        Uri.parse("${HomePage.URL}orders/${widget.orderID}/branch"),
        headers: {"Authorization": "Bearer $token"});
  }

  void displayToastMessage(var toastMessage) {
    //   Fluttertoast.showToast(
    //       msg: toastMessage.toString(),
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    // }
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
        duration: Duration(seconds: 4),
        background: HomePage.colorYellow);
  }
}
