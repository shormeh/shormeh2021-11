import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/OrderModel.dart';
import 'package:shormeh/Models/OrderModel2.dart';
import 'package:shormeh/Screens/Card/Card5OdrerStatus.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  List<OrderModel> allOrders = [];
  int statusID = 0;

  bool isIndicatorActive = true;
  String lan = '';
  String cardToken = "";
  String token = "";
  int? vendorID;
  List<int> allAddons = [];
  List<int> allOptions = [];
  int portinsNum = 1;
  String tECNotes = '';
  int? orders;
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
    final _translateLanguage = prefs.getInt('translateLanguage');

    setState(() {
      token = _token!;
      _translateLanguage == 0 ? lan = 'en' : lan = 'ar';
      cardToken = _cardToken!;
    });

    print("$token");
    getMyOrders();
  }

  Future getMyOrders() async {
    var response = await http.get(Uri.parse("${HomePage.URL}customer/orders"),
        headers: {"Authorization": "Bearer $token", "Content-Language": lan});
    var data = json.decode(response.body);
    log(data.toString());
    setState(() {
      for (int i = 0; i < data['orders'].length; i++) {
        allOrders.add(new OrderModel(
          id: data['orders'][i]['id'],
          uuid: "${data['orders'][i]['uuid']}",
          status: "${data['orders'][i]['status']['name']}",
          nameEn: "${data['orders'][i]['status']['name_en']}",
          statusId: data['orders'][i]['status_id'],
          sub_total: "${data['orders'][i]['sub_total']}",
          discount: "${data['orders'][i]['cart']['discount']}",
          tax: "${data['orders'][i]['cart']['tax']}",
          total: "${data['orders'][i]['cart']['total']}",
          items: (data['orders'][i]['cart']['items'] as List)
              .map((order) => OrderModel2.fromJson(order))
              .toList(),
          vendor: "${data['orders'][i]['cart']['vendor']['name']}",
          vendorID: data['orders'][i]['cart']['vendor_id'],
        ));
      }

      isIndicatorActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        elevation: 5.0,
        backgroundColor: HexColor('#40976c'),
        title: Text(
          translate('lan.myOrders'),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
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
          : allOrders.isEmpty
              ? Column(
                  children: [
                    Container(
                      height: 400,
                      width: 500,
                      child: Lottie.asset('assets/images/lf20_0ymizna7.json'),
                    ),
                    Text(translate('lan.ordersEmpty')),
                  ],
                )
              : Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allOrders.length,
                      itemBuilder: (
                        _,
                        index,
                      ) {
                        return Container(
                          margin: EdgeInsets.all(
                              MediaQuery.of(context).size.width / 50),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            color: Color(0xfff7f7f7),
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xfff7f7f7), spreadRadius: 0.0),
                            ],
                          ),
                          child: ExpansionTile(
                            iconColor: HexColor('#40976c'),
                            collapsedIconColor: HexColor('#40976c'),
                            leading: Container(
                                child: CircleAvatar(
                              child: Icon(
                                Icons.done,
                                size: MediaQuery.of(context).size.width / 20,
                                color: Colors.white,
                              ),
                              backgroundColor: Color(0xff748b9d),
                              radius: MediaQuery.of(context).size.width / 30,
                            )),
                            title: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => OrderStatus(
                                                  orderID:
                                                      "${allOrders[index].id}",
                                                  backToMyOrders: true,
                                                )),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${allOrders[index].vendor}',
                                          style: TextStyle(
                                              fontSize: sWidth / 30,
                                              color: Color(0xff748b9d)),
                                        ),
                                        Text(
                                          translate('lan.orderNo') +
                                              ' ' +
                                              allOrders[index].id.toString(),
                                          style: TextStyle(
                                              fontSize: sWidth / 30,
                                              color: HomePage.colorGreen),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // allOrders[index].statusId==8?

                                // : Container(),

                                // : Container(),
                              ],
                            ),
                            subtitle: Text(
                              lan == "ar"
                                  ? '${allOrders[index].status}'
                                  : '${allOrders[index].nameEn}',
                              style: TextStyle(
                                  fontSize: sWidth / 30,
                                  color: Color(0xff748b9d)),
                            ),
                            children: [
                              //المنتجات
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: allOrders[index].items!.length,
                                  itemBuilder: (_, index2) {
                                    return Container(
                                      margin: EdgeInsets.fromLTRB(
                                          MediaQuery.of(context).size.width /
                                              50,
                                          MediaQuery.of(context).size.width /
                                              100,
                                          MediaQuery.of(context).size.width /
                                              50,
                                          MediaQuery.of(context).size.width /
                                              100),
                                      padding: EdgeInsets.fromLTRB(
                                          MediaQuery.of(context).size.width /
                                              50,
                                          MediaQuery.of(context).size.width /
                                              100,
                                          MediaQuery.of(context).size.width /
                                              50,
                                          MediaQuery.of(context).size.width /
                                              100),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          children: <Widget>[
                                            //image
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              child: Image(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    7,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    7,
                                                image: NetworkImage(
                                                    allOrders[index]
                                                        .items![index2]
                                                        .product_image!
                                                    // '${allOrdersProducts[index2].product_image
                                                    ),
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
                                                    "${allOrders[index].items![index2].product_name}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                  )),
                                            ),

                                            //Price & Count
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${allOrders[index].items![index2].productTotal}" +
                                                          ' ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              30),
                                                    ),
                                                    Text(
                                                      translate('lan.rs'),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              30),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      translate('lan.count') +
                                                          ' : ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              30),
                                                    ),
                                                    Text(
                                                      "${allOrders[index].items![index2].productCount}",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              30),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),

                              //tax القيمة المضافة
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                child: Row(
                                  children: [
                                    Text(
                                      translate('lan.tax') + ' ',
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
                                      "${allOrders[index].tax}",
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
                                    const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                child: Row(
                                  children: [
                                    Text(
                                      translate('lan.discound') + ' ',
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
                                      "${allOrders[index].discount}" == 'null'
                                          ? '0'
                                          : "${allOrders[index].discount}",
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

                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                child: Row(
                                  children: [
                                    Text(
                                      translate('lan.total') + ' ',
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
                                      "${allOrders[index].total}",
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
                                height: 3,
                              ),
                              //   InkWell(
                              //     onTap: (){
                              //       if(allOrders[index].items.length ==1) {
                              //         if (cardToken == null || cardToken == '') {
                              //           sendDataToServer(
                              //             productID: allOrders[index].items[0]
                              //                 .productID,
                              //             vendorID: allOrders[index].vendorID,
                              //             notes: allOrders[index].items[0].note,
                              //             quantity: allOrders[index].items[0]
                              //                 .quantity,
                              //             addOns: allOrders[index].items[0].addons,
                              //             options: allOrders[index].items[0].options,
                              //           );
                              //         }
                              //
                              //         else
                              //             haveCard(
                              //               productID: allOrders[index].items[0]
                              //                   .productID,
                              //               vendorID: allOrders[index].vendorID,
                              //               notes: allOrders[index].items[0].note,
                              //               quantity: allOrders[index].items[0]
                              //                   .quantity,
                              //               addOns: allOrders[index].items[0].addons,
                              //               options: allOrders[index].items[0]
                              //                   .options,
                              //               token: cardToken
                              //             );
                              //       }
                              //       else {
                              //         if (cardToken == null || cardToken == '') {
                              //           sendDataToServer(
                              //             productID: allOrders[index].items[0]
                              //                 .productID,
                              //             vendorID: allOrders[index].vendorID,
                              //             notes: allOrders[index].items[0].note,
                              //             quantity: allOrders[index].items[0]
                              //                 .quantity,
                              //             addOns: allOrders[index].items[0].addons,
                              //             options: allOrders[index].items[0].options,
                              //           );
                              //           for (int i = 1; i <=
                              //               allOrders[index].items.length+1; i++)
                              //             haveCard(
                              //                 productID: allOrders[index].items[i]
                              //                     .productID,
                              //                 vendorID: allOrders[index].vendorID,
                              //                 notes: allOrders[index].items[i].note,
                              //                 quantity: allOrders[index].items[i]
                              //                     .quantity,
                              //                 addOns: allOrders[index].items[i]
                              //                     .addons,
                              //                 options: allOrders[index].items[i]
                              //                     .options,
                              //                 token: cardToken
                              //             );
                              //         }
                              //       }
                              //     },
                              //     child: Container(
                              //       width: 200,
                              //       height: 40,
                              //       decoration: BoxDecoration(
                              //         color: HomePage.colorGreen,
                              //         borderRadius: new BorderRadius.all(Radius.circular(10),),
                              //
                              //       ),
                              //       child: Center(
                              //         child: Text(translate('lan.reorder'),style: TextStyle(color: Colors.white),),
                              //       ),
                              //     ),
                              //   ),
                              // const  SizedBox(height: 10,),
                            ],
                          ),
                        );
                      }),
                ),
    );
  }

  // Future sendDataToServer({ int vendorID,
  //   int productID,
  //   int quantity,
  //   List<int> options,
  //   List<int> addOns,
  //   String notes,
  // }   ) async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //
  //     print(vendorID);print(productID);print(quantity);print(options);
  //     print(addOns);
  //    var response = await http.post("${HomePage.URL}cart/add_product",
  //         body: {
  //           "vendor_id": "$vendorID",
  //           "product_id": "$productID",
  //           "quantity": "$quantity",
  //           "options":options.toString(),
  //           "addons": addOns.toString(),
  //           "note": notes??'',
  //         });
  //
  //     var dataOrder = json.decode(response.body);
  //     displayToastMessage("${dataOrder['message']}");
  //     prefs.setInt('counter', 1);
  //     if ("${dataOrder['success']}" == "1") {
  //       setState(() {
  //         cardToken =dataOrder['cart']['token'];
  //       });
  //       print("LLLLLLLLLLLLLLLLL ${dataOrder['cart']['token']}");
  //       saveDataInSharedPref( dataOrder['cart']['token']);
  //     }
  // }
  //
  // haveCard({ int vendorID,
  //   int productID,
  //   int quantity,
  //   List<int> options,
  //   List<int> addOns,
  //   String notes,
  //   String token
  // }  )async{
  //   final prefs = await SharedPreferences.getInstance();
  //  var response = await http.post("${HomePage.URL}cart/add_product",
  //       headers: {
  //         "Authorization": "Bearer $token",
  //       }, body: {
  //         "vendor_id": "$vendorID",
  //         "product_id": "$productID",
  //         "quantity": "$quantity",
  //         "cart_token": cardToken,
  //         "options":options.toString(),
  //         "addons": addOns.toString(),
  //         "note": notes??'',
  //
  //
  //       });
  //
  //   var dataOrder = json.decode(response.body);
  //   prefs.setInt('counter',  dataOrder['cart']['items_count']);
  //   log(dataOrder.toString());
  //
  //
  // }

  void saveDataInSharedPref(cardTokenP) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('cardToken', cardTokenP);
    setState(() {
      cardToken = cardTokenP;
    });
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
