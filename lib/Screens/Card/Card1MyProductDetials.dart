import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/CardModel1.dart';
import 'package:shormeh/Screens/Card/Card2MyAllProductsDetails.dart';
import 'package:shormeh/Screens/Cats/3ProductDetails.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class Card1 extends StatefulWidget {
  bool? fromHome;
  Card1({this.fromHome});

  @override
  _Card1State createState() => _Card1State();
}

class _Card1State extends State<Card1> {
  bool isIndicatorActive = true;
  List<Card1Model> allMyCardProducts = [];

  String cardToken = "";
  String lan = '';
  int translationLanguage = 0;
  int cardItems = 0;
  String option = '';
  List<String> addOn = [];
  String token = '';
  int? counter;
  int? vendorID;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();
  }

  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    final _cardToken = prefs.getString("cardToken");
    final _translateLanguage = prefs.getInt('translateLanguage');
    final _token = prefs.getString("token");
    final _counter = prefs.getInt("counter");
    final _vendor = prefs.getInt("vendorID");

    if (_cardToken != null) {
      setState(() {
        _translateLanguage == 1 ? lan = 'ar' : lan = 'en';
        cardToken = _cardToken;
        token = _token!;
      });
    }

    getMyCardProducts();

    setState(() {
      vendorID = _vendor;
      _counter == null ? counter = 0 : counter = _counter;
      translationLanguage = _translateLanguage!;
    });
  }

  Future getMyCardProducts() async {
    allMyCardProducts.clear();

    print(token);

    if (cardToken == '') {
      cardItems = 0;
      isIndicatorActive = false;
    } else {
      var response = await http
          .get(Uri.parse("${HomePage.URL}cart/get_cart/$cardToken"), headers: {
        // "Authorization": "Bearer $token",
        "Content-Language": lan,
      });

      var dataMyCardProducts = json.decode(response.body);

      log(dataMyCardProducts.toString());

      setState(() {
        cardItems = dataMyCardProducts['data']['items'].length;
        for (int i = 0; i < dataMyCardProducts['data']['items'].length; i++) {
          addOn = [];
          if (dataMyCardProducts['data']['items'][i]['cartitemaddon'] != null) {
            for (int j = 0;
                j <
                    dataMyCardProducts['data']['items'][i]['cartitemaddon']
                        .length;
                j++) {
              lan == 'en'
                  ? addOn.add(dataMyCardProducts['data']['items'][i]
                      ['cartitemaddon'][j]['addon']['name_en'])
                  : addOn.add(dataMyCardProducts['data']['items'][i]
                      ['cartitemaddon'][j]['addon']['name_ar']);
            }
          }

          allMyCardProducts.add(new Card1Model(
            dataMyCardProducts['data']['id'],
            dataMyCardProducts['data']['sub_total'],
            "${dataMyCardProducts['data']['tax']}",
            "${dataMyCardProducts['data']['total']}",
            "${dataMyCardProducts['data']['delivery_fee']}",
            "${dataMyCardProducts['data']['points_to_cash']}",
            "${dataMyCardProducts['data']['discount']}",
            dataMyCardProducts['data']['items'][i]['product_id'],
            dataMyCardProducts['data']['items'][i]['product_name'],
            dataMyCardProducts['data']['items'][i]['product_image'],
            dataMyCardProducts['data']['items'][i]['total'].toString(),
            dataMyCardProducts['data']['items'][i]['count'],
            false,
            option: dataMyCardProducts['data']['items'][i]['cartitemoption']
                        .length ==
                    0
                ? ''
                : dataMyCardProducts['data']['items'][i]['cartitemoption'][0]
                            ['optionvalue'] ==
                        null
                    ? ''
                    : lan == 'en'
                        ? dataMyCardProducts['data']['items'][i]
                            ['cartitemoption'][0]['optionvalue']['name_en']
                        : dataMyCardProducts['data']['items'][i]
                                ['cartitemoption'][0]['optionvalue']['name_ar']
                            .toString(),
            addOn: addOn,
            notes: dataMyCardProducts['data']['items'][i]['note'] == null
                ? ''
                : dataMyCardProducts['data']['items'][i]['note'],
            drinkTitle: dataMyCardProducts['data']['items'][i]['drink']!=null?lan == 'en'?dataMyCardProducts['data']['items'][i]['drink']['title_en']:
            dataMyCardProducts['data']['items'][i]['drink']['title_ar']:'',
            drinkID: dataMyCardProducts['data']['items'][i]['drink']!=null?
            dataMyCardProducts['data']['items'][i]['drink']['id'].toString():''
          ));
        }

        isIndicatorActive = false;
      });
    }
  }

  void removeProduct(int id) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isIndicatorActive = true;
    });

    print(id);
    print(cardToken);
    var respons = await http
        .post(Uri.parse("${HomePage.URL}cart/remove_product"), headers: {
      "Content-Language": lan,
      "Authorization": "Bearer $token",
    }, body: {
      "product_id": "$id",
      "cart_token": "$cardToken",
    });
    var data = json.decode(respons.body);
    print(data);
    if (data['success'] == "1") {
      displayToastMessage("${data['message']}");

      setState(() {
        isIndicatorActive = false;
        cardItems--;
        prefs.setInt("counter", counter! - 1);
      });
      if (cardItems == 0) {
        setState(() {
          cardToken = '';
          prefs.setString('cardToken', '');
          prefs.setInt("counter", 0);
        });
      }
      getMyCardProducts();
    } else {
      displayToastMessage("${data['message']}");
      setState(() {
        isIndicatorActive = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          translate('lan.saltElshraa'),
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal'),
        ),
        backgroundColor: HexColor('#40976c'),
        elevation: 5.0,
        leading: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          isHomeScreen: true,
                        )));
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: isIndicatorActive
          ? Center(
              child: Container(
              height: 100,
              width: 100,
              child: Lottie.asset('assets/images/lf20_mvihowzk.json'),
            ))
          : cardItems == 0
              ? Center(
                  child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Lottie.asset('assets/images/lf20_snkgifgm.json',
                        height: 300, width: 300, fit: BoxFit.cover),
                    Text(
                      translate('lan.saltElshraaFargaa'),
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 25,
                          color: Colors.black,
                          fontFamily: 'Tajawal'),
                    )
                  ],
                ))
              : Directionality(
                  textDirection:
                      lan == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 9,
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemCount: allMyCardProducts.length,
                            padding: EdgeInsets.fromLTRB(
                                0.0,
                                MediaQuery.of(context).size.width / 50,
                                0.0,
                                MediaQuery.of(context).size.width / 50),
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                  color: HexColor('#F2F2F2'),
                                  margin: EdgeInsets.fromLTRB(
                                      MediaQuery.of(context).size.width / 50,
                                      MediaQuery.of(context).size.width / 100,
                                      MediaQuery.of(context).size.width / 50,
                                      MediaQuery.of(context).size.width / 100),
                                  padding: EdgeInsets.fromLTRB(
                                      5,
                                      MediaQuery.of(context).size.width / 100,
                                      5,
                                      MediaQuery.of(context).size.width / 100),
                                  child: Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.25,
                                    child: ExpansionTile(
                                      iconColor: HexColor('#40976c'),
                                      textColor: HexColor('#40976c'),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${allMyCardProducts[index].productName}",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily: 'Tajawal'),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      allMyCardProducts[index]
                                                          .count++;
                                                      changeCount(
                                                              allMyCardProducts[
                                                                  index],
                                                              allMyCardProducts[
                                                                      index]
                                                                  .count)
                                                          .then((value) {
                                                        setState(() {
                                                          allMyCardProducts[
                                                                      index]
                                                                  .productPrice =
                                                              value;
                                                        });
                                                      });
                                                      ;
                                                    });
                                                  },
                                                  child: Image.asset(
                                                      'assets/images/plus.png',
                                                      height: 25,
                                                      color:
                                                          HexColor('#40976c'))),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                '${allMyCardProducts[index].count} ',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: HexColor('#40976c')),
                                              ),
                                              const SizedBox(
                                                width: 7,
                                              ),
                                              InkWell(
                                                  onTap: () {
                                                    if (allMyCardProducts[index]
                                                            .count >
                                                        1)
                                                      setState(() {
                                                        allMyCardProducts[index]
                                                            .count--;
                                                        print(allMyCardProducts[
                                                                index]
                                                            .count);
                                                        changeCount(
                                                                allMyCardProducts[
                                                                    index],
                                                                allMyCardProducts[
                                                                        index]
                                                                    .count)
                                                            .then((value) {
                                                          setState(() {
                                                            allMyCardProducts[
                                                                        index]
                                                                    .productPrice =
                                                                value;
                                                          });
                                                        });
                                                      });
                                                  },
                                                  child: Image.asset(
                                                    'assets/images/minus.png',
                                                    height: 25,
                                                    color: HexColor('#40976c'),
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7)),
                                        child: Image.network(
                                          allMyCardProducts[index].productImage,
                                          height: 50,
                                          width: 65,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, top: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            translate(
                                                                'lan.count'),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Tajawal'),
                                                          ),
                                                        ),
                                                        Text(
                                                          '${allMyCardProducts[index].count} ',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Tajawal'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Text(
                                                  //   '${allMyCardProducts[index].count} ',
                                                  //   style: TextStyle(
                                                  //       fontSize: 16,
                                                  //       fontFamily: 'Tajawal'),
                                                  // ),
                                                ],
                                              ),
                                              Divider(),
                                              allMyCardProducts[index].option!=''?
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      translate('lan.size'),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'Tajawal'),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${allMyCardProducts[index].option} ',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Tajawal'),
                                                  ),
                                                ],
                                              ):Container(),
                                              allMyCardProducts[index].option!=''?  Divider():Container(),
                                              allMyCardProducts[index].drinkTitle!=''?
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      translate('lan.drink'),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily:
                                                          'Tajawal'),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${allMyCardProducts[index].drinkTitle} ',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Tajawal'),
                                                  ),
                                                ],
                                              ):Container(),
                                              allMyCardProducts[index].drinkTitle!=''?
                                              Divider():Container(),
                                              allMyCardProducts[
                                              index]
                                                  .addOn!
                                                  .length==0?Container(): Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      translate('lan.addons'),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'Tajawal'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        itemCount:
                                                            allMyCardProducts[
                                                                    index]
                                                                .addOn!
                                                                .length,
                                                        itemBuilder:
                                                            (context, i) {
                                                          print(allMyCardProducts[
                                                                      index]
                                                                  .addOn
                                                                  .toString() +
                                                              ';ttttt');
                                                          // print(addOn);
                                                          return Text(
                                                            allMyCardProducts[
                                                                    index]
                                                                .addOn![i],
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Tajawal'),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              allMyCardProducts[
                                              index]
                                                  .addOn!
                                                  .length==0?Container():  Divider(),
                                              allMyCardProducts[index].notes==''?Container()
                                                  :Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      translate('lan.notes'),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'Tajawal'),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                    child: Text(
                                                      '${allMyCardProducts[index].notes} ',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'Tajawal'),
                                                      maxLines: 3,
                                                      textAlign: lan == "en"
                                                          ? TextAlign.right
                                                          : TextAlign.left,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              allMyCardProducts[index].notes==''?Container()  :
                                              Divider(),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      translate('lan.total'),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'Tajawal'),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                    child: Text(
                                                      '${allMyCardProducts[index].productPrice} ' +
                                                          translate('lan.rs'),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'Tajawal'),
                                                      textAlign: lan == "en"
                                                          ? TextAlign.right
                                                          : TextAlign.left,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    secondaryActions: <Widget>[
                                      new IconSlideAction(
                                        color: HexColor('#FCC747'),
                                        iconWidget: SvgPicture.asset(
                                          'assets/images/edit.svg',
                                          height: 30,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductDetails(
                                                        productID:
                                                            allMyCardProducts[
                                                                    index]
                                                                .productId,
                                                        productTotal:
                                                            allMyCardProducts[
                                                                    index]
                                                                .productPrice,
                                                        update: true,
                                                      )));
                                        },
                                      ),
                                      new IconSlideAction(
                                        color: Colors.red[800],
                                        iconWidget: Image.asset(
                                            'assets/images/delete.png',
                                            height: 30,
                                            color: Colors.white),
                                        onTap: () {
                                          removeProduct(allMyCardProducts[index]
                                              .productId);
                                        },
                                      ),
                                    ],
                                  ));
                            }),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(child: Container()),
                              Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width / 2.3,
                                child: ButtonTheme(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  height: 50,
                                  child: RaisedButton(
                                    child: Text(translate('lan.sendOrder'),
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                25,
                                            color: Colors.white,
                                            fontFamily: 'Tajawal',
                                            fontWeight: FontWeight.bold)),
                                    color: HomePage.colorGreen,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Card2()),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Expanded(child: Container()),
                              Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width / 2.3,
                                child: ButtonTheme(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  height: 50,
                                  child: RaisedButton(
                                    child: Text(translate('lan.addMore'),
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                25,
                                            color: Colors.black,
                                            fontFamily: 'Tajawal',
                                            fontWeight: FontWeight.bold)),
                                    color: Colors.white,
                                    onPressed: () {
                                      //Navigator.pop(context);
                                      //EditAyaDialoge(allSurahListD);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Expanded(child: Container()),
                            ],
                          ),
                        ),
                      ),
                      widget.fromHome != null
                          ? const SizedBox(
                              height: 100,
                            )
                          : const SizedBox(
                              height: 30,
                            ),
                    ],
                  ),
                ),
    );
  }

  Future changeCount(Card1Model product, int count) async {
    var response =
        await http.post(Uri.parse("${HomePage.URL}cart/add_product"), headers: {
      "Content-Language": lan,
      "Authorization": "Bearer $token",
    }, body: {
      "vendor_id": "$vendorID",
      "product_id": product.productId.toString(),
      "quantity": count.toString(),
      "options": product.option,
      "addons": product.addOn.toString(),
      "note": product.notes.toString(),
      "cart_token": cardToken,
          "drink_id": product.drinkID
    });
    var data = json.decode(response.body);
    print(data);
    return data['cart']['total'].toString();
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
