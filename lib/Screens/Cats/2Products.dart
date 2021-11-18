import 'dart:convert';
import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/ProductsModel.dart';
import 'package:shormeh/Screens/Card/Card1MyProductDetials.dart';
import 'package:shormeh/Screens/Cats/3ProductDetails.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';
import 'package:shormeh/Screens/user/login.dart';

class Products extends StatefulWidget {
  int? catID;
  int? vendorID;

  Products({
    this.catID,
    this.vendorID,
  });
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final scrollController = ScrollController();

  bool isIndicatorActive = true;

  List<ProductsModel> allSubCats = [];

  bool isHome = true;
  final PagingController<int, ProductsModel> _pagingController =
      PagingController(firstPageKey: 0);

  int? translationLanguage;

  String subCatName = "";
  String lan = '';
  String token = '';
  int currentPage = 1;
  int? vendor;
  bool? isLogin;
// bool isLoadingVertical = false;
  int increment = 0;
  int? counter;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.vendorID);
    getDataFromSharedPref();
    _pagingController.addPageRequestListener((pageKey) {
      getAllSubCats(pageKey);
    });
  }

  Future<void> getDataFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final _isLogin = prefs.getBool('isLogin');
    final _vendorID = prefs.getInt('vendorID');
    final _translateLanguage = prefs.getInt('translateLanguage');
    final _token = prefs.getString("token") ?? '';
    final _counter = prefs.getInt("counter") ?? 0;
    setState(() {
      counter = _counter;
      isLogin = _isLogin ?? false;
      token = _token;
      vendor = _vendorID;
    });

    setState(() {
      translationLanguage = _translateLanguage;
      _translateLanguage == 0 ? lan = 'en' : lan = 'ar';
    });
    print(lan);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void toggle(ProductsModel product) async {
    var respons = await http
        .post(Uri.parse("${HomePage.URL}customer/favourite/toggle"), headers: {
      "Authorization": "Bearer $token",
    }, body: {
      "product_id": product.id.toString(),
    });
  }

  Future getAllSubCats(int pageKey) async {
    final prefs = await SharedPreferences.getInstance();
    final _token = prefs.getString("token");
    Uri url = Uri.parse(
      "${HomePage.URL}vendors/${widget.vendorID}/${widget.catID}/products?page=$currentPage",
    );

    var response = await http.get(url, headers: {
      "Content-Language": lan,
      "Authorization": "Bearer $_token",
    });
    var dataAllSubCats;
    dataAllSubCats = json.decode(response.body);

    final isLastPage = dataAllSubCats['data'].length < 5;
    log(response.body);
    for (int i = 0; i < dataAllSubCats['data'].length; i++) {
      allSubCats.add(new ProductsModel(
        dataAllSubCats['data'][i]['id'],
        dataAllSubCats['data'][i]['image_one'],
        dataAllSubCats['data'][i]['name'],
        dataAllSubCats['data'][i]['price'],
        dataAllSubCats['data'][i]['in_favourite'],
      ));
    }
    if (isLastPage) {
      _pagingController.appendLastPage(allSubCats.sublist(increment), 'no');
    } else {
      var nextPageKey = pageKey + dataAllSubCats['data'].length;
      _pagingController.appendPage(allSubCats, nextPageKey.toInt(), 'no');
    }
    setState(() {
      increment = increment + 5;
      currentPage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(token);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          translate('lan.appName'),
        ),
        backgroundColor: HexColor('#40976c'),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Card1()))
                  .then((value) {
                setState(() {
                  getDataFromSharedPref();
                });
              });
            },
            child: Row(
              children: [
                Container(width: 55, child: Text(translate('lan.finishOrder'))),
                Padding(
                  padding: const EdgeInsets.only(right: 9.0, left: 9),
                  child: Badge(
                      position: BadgePosition.topStart(),
                      badgeColor: HomePage.colorYellow,
                      badgeContent: Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          counter.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 15.0, left: 2, right: 2),
                        child: Icon(
                          Icons.shopping_cart,
                          size: 28,
                        ),
                      )),
                ),
              ],
            ),
          ),
        ],
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return HomePage(
                    isHomeScreen: true,
                  );
                },
              ),
              (_) => false,
            );
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        elevation: 5.0,
      ),
      body: WillPopScope(
        onWillPop: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return HomePage(
                  isHomeScreen: true,
                );
              },
            ),
            (_) => false,
          );
          return Future.value(true);
        },
        child: PagedListView<int, ProductsModel>(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<ProductsModel>(
              firstPageProgressIndicatorBuilder: (_) => Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 4.5,
                        margin: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width / 30,
                          MediaQuery.of(context).size.width / 50,
                          MediaQuery.of(context).size.width / 30,
                          MediaQuery.of(context).size.width / 50,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            'assets/images/59529-skeleton-loader-kuhan.gif',
                            fit: BoxFit.fill,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 4.5,
                        margin: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width / 30,
                          MediaQuery.of(context).size.width / 50,
                          MediaQuery.of(context).size.width / 30,
                          MediaQuery.of(context).size.width / 50,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            'assets/images/59529-skeleton-loader-kuhan.gif',
                            fit: BoxFit.fill,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 4.5,
                        margin: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width / 30,
                          MediaQuery.of(context).size.width / 50,
                          MediaQuery.of(context).size.width / 30,
                          MediaQuery.of(context).size.width / 50,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            'assets/images/59529-skeleton-loader-kuhan.gif',
                            fit: BoxFit.fill,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
              newPageProgressIndicatorBuilder: (_) => Center(
                      child: CircularProgressIndicator(
                    color: HexColor('#40976c'),
                  )),
              itemBuilder: (context, item, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductDetails(
                                productID:
                                    _pagingController.itemList![index].id,
                                vendor: vendor!,
                                token: token,
                                catID: widget.catID!,
                              )),
                    );
                  },
                  child: Container(
                      height: MediaQuery.of(context).size.height / 4.5,
                      margin: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width / 30,
                        MediaQuery.of(context).size.width / 50,
                        MediaQuery.of(context).size.width / 30,
                        MediaQuery.of(context).size.width / 50,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: FadeInImage.assetNetwork(
                              placeholder:
                                  'assets/images/59529-skeleton-loader-kuhan.gif',
                              image:
                                  "${_pagingController.itemList![index].image}",
                              fit: BoxFit.fill,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: GestureDetector(
                              onTap: () {
                                print(isLogin.toString() + 'hhhhkkkk');
                                if (isLogin != false) {
                                  setState(() {
                                    allSubCats[index].liked == 1
                                        ? allSubCats[index].liked = 0
                                        : allSubCats[index].liked = 1;
                                  });
                                  toggle(allSubCats[index]);
                                } else
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()));
                              },
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Colors.black.withOpacity(0.6)),
                                  child: Center(
                                    child: Icon(
                                      _pagingController
                                                  .itemList![index].liked ==
                                              1
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border,
                                      color: HomePage.colorYellow,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            child: Container(
                              width: size.width,
                              height: size.height / 9,
                              decoration: BoxDecoration(
                                borderRadius: new BorderRadius.only(
                                  bottomLeft: const Radius.circular(10.0),
                                  bottomRight: const Radius.circular(10.0),
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.02),
                                    Colors.black.withOpacity(0.5),
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            alignment: Alignment.bottomCenter,
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width / 3),
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 20,
                                ),
                                Expanded(
                                  child: Text(
                                      _pagingController
                                          .itemList![index].mainName,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis)),
                                ),
                                Row(
                                  children: [
                                    _pagingController.itemList![index].price ==
                                            "0.00"
                                        ? Text(
                                            translate('lan.priceChoice'),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                                color: HomePage.colorYellow),
                                          )
                                        : Text(
                                            "${_pagingController.itemList![index].price}" +
                                                ' ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    25,
                                                color: HomePage.colorYellow),
                                          ),
                                    _pagingController.itemList![index].price ==
                                            "0.00"
                                        ? Container()
                                        : Text(
                                            translate('lan.rs'),
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    25,
                                                fontWeight: FontWeight.bold,
                                                color: HomePage.colorYellow),
                                          ),
                                  ],
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 20,
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                );
              }),
        ),
      ),
    );
  }
}
