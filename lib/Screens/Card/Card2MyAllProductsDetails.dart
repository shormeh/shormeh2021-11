import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/CardModel2.dart';
import 'package:shormeh/Screens/Card/Card3OrderDetails.dart';
import 'package:shormeh/Screens/Card/Cars/CarsList.dart';
import 'package:shormeh/Screens/Card/OrderHome/AdressList.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class Card2 extends StatefulWidget {
  @override
  _Card2State createState() => _Card2State();
}

class _Card2State extends State<Card2> with TickerProviderStateMixin {
  bool isIndicatorActive = true;

  List<Card2Model> allOrderMethods = [];

  String cardToken = "";
  String token = "";
  List<String> images = [
    'assets/lottieBoy.json',
    'assets/lottieBranche.json',
    'assets/lottieHome.json',
    'assets/lottieRate.json'
  ];

  int translationLanguage = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();
    print("Card 2");
  }

  int? vendorID;
  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    final _translateLanguage = prefs.getInt('translateLanguage');
    final _cardToken = prefs.getString("cardToken");
    final _token = prefs.getString("token");
    final _vendorID = prefs.getInt("vendorID");
    setState(() {
      cardToken = _cardToken!;
      token = _token!;
      vendorID = _vendorID;
      translationLanguage = _translateLanguage!;
    });
    getMyCardOrderMethods();
  }

  Future getMyCardOrderMethods() async {
    var response = await http
        .get(Uri.parse("${HomePage.URL}vendors/$vendorID/ordermethods"));

    var dataMyCardProducts = json.decode(response.body);

    setState(() {
      print("${dataMyCardProducts.length}");
      for (int i = 0; i < dataMyCardProducts.length; i++) {
        allOrderMethods.add(new Card2Model(
          dataMyCardProducts[i]['id'],
          "${dataMyCardProducts[i]['title_ar']}",
          "${dataMyCardProducts[i]['title_en']}",
          "${dataMyCardProducts[i]['image']}",
        ));
      }

      isIndicatorActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          translate('lan.trkEltawseel'),
        ),
        centerTitle: true,
        backgroundColor: HexColor('#40976c'),
        elevation: 5.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: MediaQuery.of(context).size.width / 15,
          ),
          onPressed: () => onBackPressed(context),
        ),
      ),
      body: isIndicatorActive
          ? Center(
              child: Container(
              height: 100,
              width: 100,
              child: Lottie.asset('assets/images/lf20_mvihowzk.json'),
            ))
          : Directionality(
              textDirection: translationLanguage == 1
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 190,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Image.asset(
                        'assets/images/animation_500_kw20b9qy.gif',
                        fit: BoxFit.fill),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: allOrderMethods.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: GestureDetector(
                              onTap: () {
                                if (allOrderMethods[index].id == 1) {
                                  setState(() {
                                    isIndicatorActive = true;
                                  });
                                  sendMethodeOrderDeliver(1);
                                } else if (allOrderMethods[index].id == 2) {
                                  sendMethodeOrderDeliver(2);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CarsList()),
                                  );
                                } else if (allOrderMethods[index].id == 3) {
                                  sendMethodeOrderDeliver(3);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AdressList()),
                                  );
                                }
                              },
                              child: Container(
                                height: 80,
                                width: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  color: Color(0xfff7f7f7),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 10,
                                    ),
                                    //image
                                    Lottie.asset(images[index],
                                        fit: BoxFit.fill),

                                    //Name
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          translationLanguage == 0
                                              ? "${allOrderMethods[index].title_en}"
                                              : "${allOrderMethods[index].title_ar}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  25),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  )
                ],
              ),
            ),
    );
  }

  Future sendMethodeOrderDeliver(int id) async {
    var response = await http
        .post(Uri.parse("${HomePage.URL}cart/add_order_method"), headers: {
      "Authorization": "Bearer $token",
      "Content-Language": translationLanguage == 0 ? 'en' : 'ar',
    }, body: {
      "order_method": "$id",
      "cart_token": "$cardToken",
      "branch_id": "$vendorID",
    });

    var dataResponseChooseMethode = json.decode(response.body);
    log(dataResponseChooseMethode.toString() + 'coco');
    if (id == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                OrderDetails(dataOrderDetails: dataResponseChooseMethode)),
      );
      isIndicatorActive = false;
    }
  }

  // Future chooseBranche(int id) async {
  //   setState(() {
  //     isIndicatorActive = true;
  //   });
  //   var response =
  //       await http.post("${HomePage.URL}cart/choose_branch", headers: {
  //     "Authorization": "Bearer $token"
  //   }, body: {
  //     "branch_id": "$vendorID",
  //     "cart_token": "$cardToken",
  //   });
  //
  //   var dataResponseChooseMethode = json.decode(response.body);
  //   log(dataResponseChooseMethode.toString());
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) =>
  //             OrderDetails(dataOrderDetails: dataResponseChooseMethode)),
  //   );
  //
  //   isIndicatorActive = false;
  // }

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
  }

  onBackPressed(BuildContext context) async {
    Navigator.pop(context);
    // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
    //     HomePage(index:0)), (Route<dynamic> route) => false);
  }
}
