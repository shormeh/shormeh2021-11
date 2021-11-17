import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/ProductsModel.dart';
import 'package:shormeh/Screens/Cats/3ProductDetails.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ProductsModel> allSubCats = [];
  bool isIndicatorActive = true;
  String token = '';
  String lan = '';
  int? vendor;

  Future getMyProducts() async {
    allSubCats.clear();
    var response = await http.get(
      Uri.parse("${HomePage.URL}customer/favourite/list"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Language": lan,
      },
    );
    var dataMyCardProducts = json.decode(response.body);
    log(dataMyCardProducts.toString());

    setState(() {
      isIndicatorActive = false;
      for (int i = 0; i < dataMyCardProducts.length; i++) {
        allSubCats.add(new ProductsModel(
          dataMyCardProducts[i]['product_id'],
          dataMyCardProducts[i]['product']['image_one'],
          dataMyCardProducts[i]['product']['name'],
          dataMyCardProducts[i]['product']['price'],
          1,
        ));
      }
    });
  }

  void removeProduct(int id) async {
    setState(() {
      isIndicatorActive = true;
    });

    var respons = await http
        .post(Uri.parse("${HomePage.URL}customer/favourite/toggle"), headers: {
      "Authorization": "Bearer $token",
    }, body: {
      "product_id": "$id",
    });
    var data = json.decode(respons.body);
    print(data);
    if (data['success'] == "1") {
      getMyProducts();
    }
  }

  Future<void> getDataFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final _translateLanguage = prefs.getInt('translateLanguage');
    final _token = prefs.getString("token");
    final _vendor = prefs.getInt("vendorID");

    setState(() {
      _translateLanguage == 0 ? lan = 'en' : lan = 'ar';
      token = _token!;
      vendor = _vendor;
    });
    getMyProducts();
  }

  @override
  void initState() {
    getDataFromSharedPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            translate('lan.favourite'),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: HexColor('#40976c'),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios),
          ),
          elevation: 5.0,
        ),
        body: isIndicatorActive
            ? Center(
                child: Container(
                height: 100,
                width: 100,
                child: Lottie.asset('assets/images/lf20_mvihowzk.json'),
              ))
            : allSubCats.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                        ),
                        Container(
                          height: 150,
                          width: 150,
                          child:
                              Lottie.asset('assets/images/lf20_mhrb2ucd.json'),
                        ),
                        Text(translate('lan.favouritesEmpty')),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: allSubCats.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetails(
                                  productID: allSubCats[index].id,
                                  vendor: vendor,
                                  token: token,
                                  favorite: true,
                                  // catID: widget.catID,
                                ),
                              ));
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
                                    image: "${allSubCats[index].image}",
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onTap: () {
                                      removeProduct(allSubCats[index].id);
                                    },
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            color:
                                                Colors.black.withOpacity(0.6)),
                                        child: Center(
                                          child: Icon(
                                            Icons.favorite_rounded,
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
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 9,
                                    decoration: BoxDecoration(
                                      borderRadius: new BorderRadius.only(
                                        bottomLeft: const Radius.circular(10.0),
                                        bottomRight:
                                            const Radius.circular(10.0),
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
                                      top: MediaQuery.of(context).size.width /
                                          3),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                20,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.8,
                                        child: Text(allSubCats[index].mainName,
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    25,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Expanded(child: Container()),
                                      Row(
                                        children: [
                                          Text(
                                            "${allSubCats[index].price}" + ' ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    25,
                                                color: HomePage.colorYellow),
                                          ),
                                          Text(
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
                                        width:
                                            MediaQuery.of(context).size.width /
                                                20,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )),
                      );
                    }));
  }
}
