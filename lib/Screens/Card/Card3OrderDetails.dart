import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/CardModel1.dart';
import 'package:shormeh/Models/PaymentMethodsModel.dart';
import 'package:shormeh/Screens/Card/Card5OdrerStatus.dart';
import 'package:shormeh/Screens/Card/checkout_payment.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class OrderDetails extends StatefulWidget {
  var dataOrderDetails;

  OrderDetails({
    this.dataOrderDetails,
  });

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final couponCtrl = TextEditingController();
  List<PaymentMethodsModel> allPaymentMethods = [];

  List<Card1Model> allMyCardProducts = [];
  bool isIndicatorActive = false;
  String cardToken = "";
  String token = "";
  int? method;
  String code = '';
  String lan = '';
  bool loading = false;
  double? discount;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();
    getPaymentMethods();
  }

  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    final _cardToken = prefs.getString("cardToken");
    final _token = prefs.getString("token");
    final _translateLanguage = prefs.getInt('translateLanguage');
    setState(() {
      _translateLanguage == 0 ? lan = 'en' : lan = 'ar';
      cardToken = _cardToken!;
      token = _token!;
    });
    print(token);
    getData();
  }

  getData() {
    allMyCardProducts = [];
    setState(() {
      for (int i = 0;
          i < widget.dataOrderDetails['cart']['items'].length;
          i++) {
        allMyCardProducts.add(new Card1Model(
            widget.dataOrderDetails['cart']['id'],
            widget.dataOrderDetails['cart']['sub_total'],
            "${widget.dataOrderDetails['cart']['tax']}",
            "${widget.dataOrderDetails['cart']['total']}",
            "${widget.dataOrderDetails['cart']['delivery_fee']}",
            "${widget.dataOrderDetails['cart']['points_to_cash']}",
            "${widget.dataOrderDetails['cart']['discount']}",
            widget.dataOrderDetails['cart']['items'][i]['product_id'],
            widget.dataOrderDetails['cart']['items'][i]['product_name'],
            widget.dataOrderDetails['cart']['items'][i]['product_image'],
            widget.dataOrderDetails['cart']['items'][i]['total'].toString(),
            widget.dataOrderDetails['cart']['items'][i]['count'],
            false));
      }
      // discount =widget.dataOrderDetails['cart']['discount'].floor();
    });
  }

  Future getPaymentMethods() async {
    try {
      var response = await http
          .get(Uri.parse("${HomePage.URL}cart/payment_method"), headers: {
        "Authorization": "Bearer $token",
      });
      var dataMyPaymentMethods = json.decode(response.body);

      setState(() {
        print("Payment Methods${dataMyPaymentMethods}");
        for (int i = 0; i < dataMyPaymentMethods.length; i++) {
          allPaymentMethods.add(new PaymentMethodsModel(
            dataMyPaymentMethods[i]['id'],
            "${dataMyPaymentMethods[i]['title_en']}",
            "${dataMyPaymentMethods[i]['title_ar']}",
            "${dataMyPaymentMethods[i]['image']}",
            "${dataMyPaymentMethods[i]['code']}",
          ));
        }
        print(dataMyPaymentMethods[0]['image']);
        //فى اللحظة دية كل الصيدليات بكل الاقسام اتحملت
      });
    } catch (e) {
      print("WWWWW $e");
    }
  }

  Future SendPaymentMethode(BuildContext context, String code) async {
    if (widget.dataOrderDetails['message'] != null &&
        widget.dataOrderDetails['message'] == 'Address added Successfully.') {
      if (widget.dataOrderDetails['cart']['delivery_fee'] != '0') {
        var response = await http
            .post(Uri.parse("${HomePage.URL}cart/add_payment"), headers: {
          "Authorization": "Bearer $token",
          "Content-Language": lan,
        }, body: {
          "cart_token": cardToken,
          "payment_type": "$code",
        });
        var dataOrder = json.decode(response.body);

        print("$dataOrder");

        if ("${dataOrder['success']}" == "1") {
          confirm();
        }
      } else
        displayToastMessage(translate('lan.weCanNot'));
      setState(() {
        isIndicatorActive = false;
      });
    } else {
      var response = await http
          .post(Uri.parse("${HomePage.URL}cart/add_payment"), headers: {
        "Authorization": "Bearer $token",
        "Content-Language": lan,
      }, body: {
        "cart_token": cardToken,
        "payment_type": "$code",
      });
      var dataOrder = json.decode(response.body);

      print('kdguauyba' + dataOrder.toString());

      if ("${dataOrder['success']}" == "1") {
        confirm();
      }
    }
  }

  void confirm() async {
    (cardToken);
    var response =
        await http.post(Uri.parse("${HomePage.URL}cart/confirm"), headers: {
      "Authorization": "Bearer $token",
      "Content-Language": lan,
    }, body: {
      'cart_token': '$cardToken',
    });
    var dataOrderAfterCoupon = json.decode(response.body);
    log(dataOrderAfterCoupon.toString());

    if (dataOrderAfterCoupon['success'] == "1") {
      displayToastMessage(" ${dataOrderAfterCoupon['message']}");
      setPrfs("${dataOrderAfterCoupon['order']['id']}");
      setState(() {
        isIndicatorActive = false;
      });
    } else {
      displayToastMessage(" ${dataOrderAfterCoupon['message']}");
      setState(() {
        isIndicatorActive = false;
      });
    }
  }

  setPrfs(String id) async {
    print(id);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("cardToken", "");
    prefs.setInt("counter", 0);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => OrderStatus(
                orderID: id,
                backToMyOrders: true,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          translate('lan.tanfeezAltalb'),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: HexColor('#40976c'),
        elevation: 5.0,
      ),
      body: Directionality(
          textDirection: lan == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: loading
              ? Center(
                  child: Container(
                  height: 100,
                  width: 100,
                  child: Lottie.asset('assets/images/lf20_mvihowzk.json'),
                ))
              : Stack(
                  children: [
                    ListView(
                      shrinkWrap: true,
                      children: [
                        ListView.builder(
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
                                margin: EdgeInsets.fromLTRB(
                                    MediaQuery.of(context).size.width / 50,
                                    MediaQuery.of(context).size.width / 100,
                                    MediaQuery.of(context).size.width / 50,
                                    MediaQuery.of(context).size.width / 100),
                                padding: EdgeInsets.fromLTRB(
                                    MediaQuery.of(context).size.width / 50,
                                    MediaQuery.of(context).size.width / 100,
                                    MediaQuery.of(context).size.width / 50,
                                    MediaQuery.of(context).size.width / 100),
                                decoration: new BoxDecoration(
                                  color: Color(0xfff7f7f7),
                                  borderRadius: new BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Image.network(
                                        '${allMyCardProducts[index].productImage}',
                                        width:
                                            MediaQuery.of(context).size.width /
                                                7,
                                        height:
                                            MediaQuery.of(context).size.width /
                                                7,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    //Name
                                    Expanded(
                                      child: Container(
                                          padding: EdgeInsets.all(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  30),
                                          child: Text(
                                            "${allMyCardProducts[index].productName}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    25),
                                          )),
                                    ),

                                    //Price & Count
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "${allMyCardProducts[index].productPrice}" +
                                                  ' ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          30),
                                            ),
                                            Text(
                                              translate('lan.rs'),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          30),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              translate('lan.count') + ' : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          30),
                                            ),
                                            Text(
                                              "${allMyCardProducts[index].count}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          30),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }),
                        const SizedBox(
                          height: 50,
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemCount: allPaymentMethods.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    method = allPaymentMethods[index].id;
                                    code = allPaymentMethods[index].code;
                                  });
                                  // SendPaymentMethode(
                                  //
                                  //    context, allPaymentMethods[index].code);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1.0,
                                          color: HexColor('#40976c')),
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
                                        Radio<int>(
                                          value: allPaymentMethods[index].id,
                                          groupValue: method,
                                          onChanged: (value) {
                                            setState(() {
                                              method = value;
                                              code =
                                                  allPaymentMethods[index].code;
                                            });
                                          },
                                        ),
                                        Image.network(
                                          allPaymentMethods[index].image,
                                          height: 40,
                                          width: 60,
                                          fit: BoxFit.cover,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          lan == 'ar'
                                              ? allPaymentMethods[index]
                                                  .title_ar
                                              : allPaymentMethods[index]
                                                  .title_en,
                                          style: TextStyle(fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        const SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListView(
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            children: [
                              //Delivery Fees قيمة التوصيل
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, bottom: 2),
                                child: Row(
                                  children: [
                                    Text(
                                      translate('lan.deliveryFee'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                    ),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Text(
                                      "${allMyCardProducts[0].delivery_fee}" +
                                          ' ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                    ),
                                    Text(
                                      translate('lan.rs'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                    ),
                                  ],
                                ),
                              ),
                              //tax القيمة المضافة
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, bottom: 2),
                                child: Row(
                                  children: [
                                    Text(
                                      translate('lan.tax'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                    ),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Text(
                                      "${allMyCardProducts[0].tax}" + ' ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                    ),
                                    Text(
                                      translate('lan.rs'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                    ),
                                  ],
                                ),
                              ),
                              //discount كوبون الخصم
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      translate('lan.discound2') + ' ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                    ),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Text(
                                      widget.dataOrderDetails['cart']
                                                  ['discount'] ==
                                              null
                                          ? ' 0 '
                                          : widget.dataOrderDetails['cart']
                                                      ['discount']
                                                  .toString() +
                                              ' ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                    ),
                                    Text(
                                      translate('lan.rs'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                    ),
                                  ],
                                ),
                              ),

                              //sub_total
                              widget.dataOrderDetails['cart']['discount'] !=
                                      null
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8, bottom: 2),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              translate('lan.subTotal'),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          30),
                                            ),
                                          ),
                                          Text(
                                            "${allMyCardProducts[0].subTotal}" +
                                                ' ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    30),
                                          ),
                                          Text(
                                            translate('lan.rs'),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    30),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),

                              //total
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, bottom: 2),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        translate('lan.total'),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                30),
                                      ),
                                    ),
                                    Text(
                                      "${allMyCardProducts[0].total}" + ' ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                    ),
                                    Text(
                                      translate('lan.rs'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                height: 20,
                              ),
                              widget.dataOrderDetails['cart']['discount'] ==
                                      null
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          //Send Coupon Button
                                          Expanded(
                                            child: Text(
                                              translate('lan.saveOn'),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Container(
                                            child: ButtonTheme(
                                              shape: new RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          10.0)),
                                              child: RaisedButton(
                                                  child: Text(
                                                      translate(
                                                          'lan.senCoupoun'),
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white)),
                                                  color: HomePage.colorGreen,
                                                  onPressed: () {
                                                    if (widget.dataOrderDetails[
                                                                'cart']
                                                            ['discount'] ==
                                                        null)
                                                      showModalBottomSheet(
                                                          context: context,
                                                          backgroundColor:
                                                              Colors.white,
                                                          isScrollControlled:
                                                              true,
                                                          builder: (context) {
                                                            return Directionality(
                                                              textDirection: lan ==
                                                                      'ar'
                                                                  ? TextDirection
                                                                      .rtl
                                                                  : TextDirection
                                                                      .ltr,
                                                              child: Container(
                                                                  padding: EdgeInsets.only(
                                                                      bottom: MediaQuery.of(
                                                                              context)
                                                                          .viewInsets
                                                                          .bottom),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius.circular(
                                                                          MediaQuery.of(context).size.width /
                                                                              25),
                                                                      topRight: Radius.circular(
                                                                          MediaQuery.of(context).size.width /
                                                                              25),
                                                                    ),
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      //ايقونة النزول
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(10.0),
                                                                        child:
                                                                            Align(
                                                                          alignment: lan == 'ar'
                                                                              ? Alignment.topLeft
                                                                              : Alignment.topRight,
                                                                          child:
                                                                              CircleAvatar(
                                                                            child:
                                                                                GestureDetector(
                                                                              onTap: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: Icon(
                                                                                Icons.expand_more,
                                                                                size: MediaQuery.of(context).size.width / 10,
                                                                                color: HomePage.colorGreen,
                                                                              ),
                                                                            ),
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            radius:
                                                                                MediaQuery.of(context).size.width / 25,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            left:
                                                                                10.0,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Text(
                                                                          translate(
                                                                              'lan.useCo'),
                                                                          style: TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            50,
                                                                        width: double
                                                                            .infinity,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(10.0),
                                                                          child:
                                                                              TextFormField(
                                                                            controller:
                                                                                couponCtrl,
                                                                            decoration:
                                                                                new InputDecoration(
                                                                              contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                                                              hintText: translate('lan.enterCo'),
                                                                              enabledBorder: UnderlineInputBorder(
                                                                                borderSide: BorderSide(color: HexColor('#40976c')),
                                                                                //  when the TextFormField in unfocused
                                                                              ),
                                                                              focusedBorder: UnderlineInputBorder(
                                                                                borderSide: BorderSide(color: HexColor('#40976c')),
                                                                                //  when the TextFormField in focused
                                                                              ),
                                                                            ),
                                                                            cursorColor:
                                                                                HexColor('#40976c'),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            25,
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            50,
                                                                        width: double
                                                                            .infinity,
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              30,
                                                                              5,
                                                                              30,
                                                                              5),
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                50,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: HexColor('#40976c'),
                                                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                            ),
                                                                            child:
                                                                                InkWell(
                                                                              onTap: () {
                                                                                if (couponCtrl.text.isEmpty) {
                                                                                  displayToastMessage(translate('lan.addCoupon'));
                                                                                } else {
                                                                                  sendCouponDiscound();
                                                                                }
                                                                              },
                                                                              child: Center(
                                                                                child: Text(
                                                                                  translate('lan.senCoupoun'),
                                                                                  style: TextStyle(color: Colors.white),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    ],
                                                                  )),
                                                            );
                                                          });
                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 45,
                                margin: new EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.25,
                                    right: MediaQuery.of(context).size.width *
                                        0.25),
                                child: ButtonTheme(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  child: RaisedButton(
                                      child: Text(translate('lan.sendOrder'),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)),
                                      color: HomePage.colorGreen,
                                      onPressed: () {
                                        if (code == 'card') {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CheckoutPayment(
                                                        price:
                                                            allMyCardProducts[0]
                                                                .total
                                                                .toString(),
                                                        cart_token: cardToken,
                                                        token: token,
                                                        language: lan,
                                                      )));
                                        } else {
                                          if (method != null) {
                                            setState(() {
                                              isIndicatorActive = true;
                                            });
                                            SendPaymentMethode(context, code);
                                          } else
                                            displayToastMessage(
                                                translate('lan.addPayment'));
                                          //Navigator.pop(context);
                                        }
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 70,
                        )
                      ],
                    ),
                    isIndicatorActive
                        ? Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: Colors.white.withOpacity(0.6),
                            child: Center(
                                child: Container(
                              height: 100,
                              width: 100,
                              child: Lottie.asset(
                                  'assets/images/lf20_mvihowzk.json'),
                            )),
                          )
                        : Container()
                  ],
                )),
    );
  }

  Future sendCouponDiscound() async {
    Navigator.pop(context);
    setState(() {
      loading = true;
    });
    var response =
        await http.post(Uri.parse("${HomePage.URL}cart/add_coupon"), headers: {
      "Authorization": "Bearer $token",
      "Content-Language": lan,
    }, body: {
      'code': '${couponCtrl.text}',
      'cart_token': '$cardToken',
    });
    var dataOrderAfterCoupon = json.decode(response.body);
    log(dataOrderAfterCoupon.toString());
    if (dataOrderAfterCoupon['success'] == "1") {
      getDataFromSharedPrfs();
      setState(() {
        widget.dataOrderDetails['cart']['discount'] =
            dataOrderAfterCoupon['cart']['discount'];
        widget.dataOrderDetails['cart']['total'] =
            dataOrderAfterCoupon['cart']['total'];
        widget.dataOrderDetails['cart']['sub_total'] =
            dataOrderAfterCoupon['cart']['sub_total'];
      });
      displayToastMessage(dataOrderAfterCoupon['message']);
      setState(() {
        loading = false;
      });
    } else {
      displayToastMessage("${dataOrderAfterCoupon['message']}");
      setState(() {
        loading = false;
      });
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
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        duration: Duration(seconds: 3),
        background: HomePage.colorYellow);
  }
}
