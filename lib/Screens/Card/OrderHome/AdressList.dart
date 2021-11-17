import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/CardModel1.dart';
import 'package:shormeh/Models/OrderHome.dart';
import 'package:shormeh/Screens/Card/Card3OrderDetails.dart';
import 'package:shormeh/Screens/Card/OrderHome/AddAddress.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class AdressList extends StatefulWidget {
  bool? added;

  AdressList({this.added});
  @override
  _AdressListState createState() => _AdressListState();
}

class _AdressListState extends State<AdressList> {
  bool isIndicatorActive = true;

  List<OrderToHomeModel> allOrderToHome = [];
  List<Card1Model> allMyCardProducts = [];

  String cardToken = "";
  String token = "";
  String? method;
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();
  }

  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    final _cardToken = prefs.getString("cardToken");
    final _token = prefs.getString("token");
    setState(() {
      cardToken = _cardToken!;
      token = _token!;
    });

    print("Cars List");
    print("$cardToken");
    getMyAdress();
  }

  Future getMyAdress() async {
    try {
      var response = await http
          .get(Uri.parse("${HomePage.URL}customer/addresses"), headers: {
        "Authorization": "Bearer $token",
      });
      var dataMyadress = json.decode(response.body);

      setState(() {
        for (int i = 0; i < dataMyadress.length; i++) {
          allOrderToHome.add(new OrderToHomeModel(
              dataMyadress[i]['id'],
              "${dataMyadress[i]['district']}",
              "${dataMyadress[i]['address']}",
              false));
        }

        //فى اللحظة دية كل الصيدليات بكل الاقسام اتحملت
        isIndicatorActive = false;
      });
    } catch (e) {
      print("WWWWW $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: HexColor('#40976c'),
        elevation: 5.0,
        title: Container(
          child: Text(
            translate('lan.enwany'),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (widget.added != null) {
              int count = 0;
              Navigator.popUntil(context, (route) {
                return count++ == 2;
              });
            } else
              Navigator.pop(context);
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          if (widget.added != null) {
            int count = 0;
            Navigator.popUntil(context, (route) {
              return count++ == 2;
            });
          } else
            Navigator.pop(context);

          return Future.value(true);
        },
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: isIndicatorActive
                  ? Center(
                      child: Container(
                      height: 80,
                      width: 80,
                      child: Lottie.asset('assets/images/lf20_mvihowzk.json'),
                    ))
                  : Column(
                      children: [
                        Expanded(
                          child: allOrderToHome.length == 0
                              ? Center(
                                  child: Lottie.asset(
                                      'assets/images/lf20_9ery8csf.json',
                                      height: 150,
                                      width: 150),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  itemCount: allOrderToHome.length,
                                  padding: EdgeInsets.fromLTRB(
                                      0.0,
                                      MediaQuery.of(context).size.width / 50,
                                      0.0,
                                      MediaQuery.of(context).size.width / 50),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          loading = true;
                                          method =
                                              allOrderToHome[index].address;
                                          allOrderToHome.forEach((element) {
                                            element.choosed = false;
                                          });
                                          allOrderToHome[index].choosed = true;
                                        });
                                        if (loading = true)
                                          setCatAndGetMyCardProducts(
                                              allOrderToHome[index].id);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: double.infinity,
                                          height: 55,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1.0,
                                                color: allOrderToHome[index]
                                                        .choosed
                                                    ? HexColor('#40976c')
                                                    : Colors.black12),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    5.0) //                 <--- border radius here
                                                ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Radio<String>(
                                                value: allOrderToHome[index]
                                                    .address,
                                                groupValue: method,
                                                onChanged: (value) {
                                                  setCatAndGetMyCardProducts(
                                                      allOrderToHome[index].id);
                                                  setState(() {
                                                    loading = true;
                                                    method = value;
                                                    allOrderToHome
                                                        .forEach((element) {
                                                      element.choosed = false;
                                                    });
                                                    allOrderToHome[index]
                                                        .choosed = true;
                                                  });
                                                },
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                allOrderToHome[index].address,
                                                style: TextStyle(fontSize: 18),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                        ),
                        Container(
                          width: 250,
                          height: 50,
                          child: ButtonTheme(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0)),
                            height: 50,
                            child: RaisedButton(
                              child: Text(translate('lan.addAdress'),
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              25,
                                      color: Colors.white)),
                              color: HomePage.colorGreen,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddAddress()),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        )
                      ],
                    ),
            ),
            loading
                ? Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.6),
                    child: Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        child: Lottie.asset(
                          'assets/images/lf20_mvihowzk.json',
                          fit: BoxFit.fill,
                          height: 100,
                          width: 100,
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Future setCatAndGetMyCardProducts(int idAddress) async {
    setState(() {
      loading = true;
    });
    print("$idAddress");
    print("$cardToken");
    var response = await http
        .post(Uri.parse("${HomePage.URL}cart/choose_address"), headers: {
      'Authorization': 'Bearer $token',
    }, body: {
      'address_id': '$idAddress',
      'cart_token': "$cardToken",
    });

    var dataOrderDetails = json.decode(response.body);

    print("${dataOrderDetails}");
    print("${dataOrderDetails['cart']['items'].length}");
    if (dataOrderDetails['success'] == "1") {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                OrderDetails(dataOrderDetails: dataOrderDetails)),
      );
    } else {
      displayToastMessage("${dataOrderDetails['message']}");
    }
    setState(() {
      loading = false;
    });
  }

  void displayToastMessage(var toastMessage) {
    // Fluttertoast.showToast(
    //     msg: toastMessage.toString(),
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     textColor: Colors.white,
    //     fontSize: 16.0
    // );
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
