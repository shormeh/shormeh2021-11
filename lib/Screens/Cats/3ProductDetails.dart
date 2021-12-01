import 'dart:convert';
import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/Addon.dart';
import 'package:shormeh/Models/Options.dart';
import 'package:shormeh/Models/ProductDetailsModel.dart';
import 'package:shormeh/Models/Slider.dart';
import 'package:shormeh/Models/drinkes.dart';
import 'package:shormeh/Screens/Card/Card1MyProductDetials.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';
import 'package:shormeh/Screens/SideBar/favorites_screen.dart';
import 'package:shormeh/Screens/user/login.dart';

import '2Products.dart';

class ProductDetails extends StatefulWidget {
  int? productID;
  String? productTotal;
  int? vendor;
  String? token;
  int? catID;
  bool? update;
  bool? favorite;

  ProductDetails(
      {this.productID,
      this.productTotal,
      this.vendor,
      this.token,
      this.catID,
      this.update,
      this.favorite});

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  ProductDetailsModel productDetailsModel =
      new ProductDetailsModel(0, "", "", "", "", "", "", 0, '', 0);
  bool isIndicatorActive = true;
  List<SliderModel> allSliderImagesProduct = [];
  List<AddonModel> allAddons = [];
  List<OptionsModel> allOptions = [];
  List<Drinks> allDrinks = [];
  TextEditingController tECNotes = new TextEditingController();
  List<String> images = [];
  String lan = '';

  int portinsNum = 1;

  String cardToken = "";

  bool? isLogin;
  int? vendorID;
  int translationLanguage = 0;
  double totalAddOns = 0.0;
  double totalOptions = 0.0;
  double total = 0.0;
  String token = '';
  bool loading = false;
  int? counter;
  int? drinkID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();
  }

  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    final _translateLanguage = prefs.getInt('translateLanguage');
    final _cardToken = prefs.getString("cardToken");
    final _vendorID = prefs.getInt("vendorID");
    final _isLogin = prefs.getBool("isLogin");
    final _token = prefs.getString("token") ?? '';
    final _counter = prefs.getInt("counter");

    print(_token);
    setState(() {
      token = _token;
      vendorID = _vendorID;
      _translateLanguage == 0 ? lan = 'en' : lan = 'ar';
      _counter == null ? counter = 0 : counter = _counter;
      translationLanguage = _translateLanguage!;
    });
    print(vendorID.toString() + 'hhhh');
    if (_cardToken != null) {
      setState(() {
        cardToken = _cardToken;
      });
      getProductDetails();
    } else {
      getProductDetails();
    }

    if (_isLogin == null) {
      setState(() {
        isLogin = false;
      });
    } else {
      setState(() {
        isLogin = _isLogin;
      });
    }

    print(token.toString() + 'jjjjjj');
  }

  Future getProductDetails() async {
    var response = await http.get(
        Uri.parse("${HomePage.URL}products/${widget.productID}/details"),
        headers: {
          "Content-Language": lan,
          "Authorization": "Bearer ${widget.token}"
        });

    var dataProductDetails = json.decode(response.body);
    log(dataProductDetails.toString());

    setState(() {
      //allSubCats.add(new ProductsModel(dataAllSubCats[i]['id'],dataAllSubCats[i]['category']['image'],dataAllSubCats[i]['name'],dataAllSubCats[i]['category']['translations'][0]['name'],dataAllSubCats[i]['category']['translations'][1]['name']));
      productDetailsModel = ProductDetailsModel(
        dataProductDetails['id'],
        dataProductDetails['image_one'],
        dataProductDetails['name'] ?? '',
        dataProductDetails['translations'][0]['name'] ?? '',
        dataProductDetails['translations'][1]['name'] ?? '',
        dataProductDetails['description'] ?? '',
        dataProductDetails['price'],
        dataProductDetails['in_favourite'],
        dataProductDetails['allergens'] ?? '',
        dataProductDetails['calories'] ?? 0,
      );

      //Addons
      for (int i = 0; i < dataProductDetails['addon'].length; i++) {
        allAddons.add(new AddonModel(
            dataProductDetails['addon'][i]["id"],
            dataProductDetails['addon'][i]["name_ar"],
            dataProductDetails['addon'][i]["name_en"],
            dataProductDetails['addon'][i]["price"]));
      }
      //Options
      for (int i = 0; i < dataProductDetails['options'].length; i++) {
        allOptions.add(new OptionsModel(
            dataProductDetails['options'][i]["id"],
            dataProductDetails['options'][i]["text"],
            dataProductDetails['options'][i]["text_ar"],
            dataProductDetails['options'][i]["price"]));
      }
      for (int i = 0; i < dataProductDetails['drinks'].length; i++) {
        allDrinks.add(new Drinks(
          id: dataProductDetails['drinks'][i]["id"],
          titleAR: dataProductDetails['drinks'][i]["title_ar"],
          titleEN: dataProductDetails['drinks'][i]["title_en"],
        ));
      }

      totalOptions = double.parse(dataProductDetails['price']);
      //Slider
      images.add(dataProductDetails['image_one']);
      if (dataProductDetails['image_two'] != null)
        images.add(dataProductDetails['image_two']);
      if (dataProductDetails['image_three'] != null)
        images.add(dataProductDetails['image_three']);

      isIndicatorActive = false;
    });
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
      if (counter == 1) {
        SendDataToServer(token: '');
        setState(() {
          prefs.setString('cardToken', '');
          cardToken = '';
        });
      } else
        SendDataToServer();

      setState(() {
        prefs.setInt("counter", counter! - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          translate('lan.appName'),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: HexColor('#40976c'),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Card1()));
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
        elevation: 5.0,
      ),
      body: Directionality(
        textDirection:
            translationLanguage == 1 ? TextDirection.rtl : TextDirection.ltr,
        child: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 10,
                ),

                //Slider
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 210,
                      child: images.length == 0
                          ? Image.asset(
                              'assets/images/59529-skeleton-loader-kuhan.gif',
                              fit: BoxFit.fill,
                              width: double.infinity,
                            )
                          : images.length == 1
                              ? Image.network(images[0])
                              : CarouselSlider(
                                  options: CarouselOptions(
                                    enlargeCenterPage: true,
                                    autoPlay: true,
                                    autoPlayAnimationDuration:
                                        Duration(milliseconds: 1000),
                                    height: MediaQuery.of(context).size.height,
                                    viewportFraction: 1.0,
                                  ),
                                  items: images.map((e) {
                                    return InkWell(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              'assets/images/59529-skeleton-loader-kuhan.gif',
                                          image: e,
                                          fit: BoxFit.fill,
                                          width: double.infinity,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                    ),

                    //Body
                    Container(
                      margin: EdgeInsets.all(
                          MediaQuery.of(context).size.width / 50),
                      alignment: Alignment.center,
                      child: Text(
                        translationLanguage == 0
                            ? "${productDetailsModel.nameEn}"
                            : "${productDetailsModel.nameAr}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width / 25),
                      ),
                    ),
                    productDetailsModel.description == 'null'
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(50, 5, 50, 5),
                            child: Text(
                              "${productDetailsModel.description}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 25),
                            ),
                          ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Image.asset(
                                      'assets/images/calories.png',
                                      height: 25,
                                      width: 25,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    translate('lan.calories'),
                                    style: TextStyle(
                                        color: HomePage.colorGreen,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(productDetailsModel.calories.toString()),
                            ],
                          ),
                          Spacer(),
                          productDetailsModel.allergens.toString() == '' ||
                                  productDetailsModel.allergens.toString() ==
                                      'null'
                              ? Container()
                              : Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(translate('lan.allergens'),
                                            style: TextStyle(
                                                color: HomePage.colorGreen,
                                                fontWeight: FontWeight.bold)),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Image.asset(
                                            'assets/images/allergy-advise.png',
                                            height: 25,
                                            width: 25,
                                            color: HomePage.colorGreen,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                    Text(productDetailsModel.allergens
                                        .toString()),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        total != 0.0 ||
                                ((totalOptions + totalAddOns) * portinsNum) !=
                                    0.0
                            ? Text(
                                widget.productTotal == null
                                    ? portinsNum == 1
                                        ? ((totalOptions + totalAddOns) *
                                                portinsNum)
                                            .toString()
                                        : "$total"
                                    : widget.productTotal!,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 20,
                                    color: HexColor('#40976c')),
                              )
                            : Text(
                                translate('lan.priceChoice'),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 20,
                                    color: HexColor('#40976c')),
                              ),
                        total != 0.0 ||
                                ((totalOptions + totalAddOns) * portinsNum) !=
                                    0.0
                            ? Text(
                                ' ' + translate('lan.rs'),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 20,
                                    color: HexColor('#40976c')),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),

                //Options
                allOptions.length > 0
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              translate('lan.customYourOptions'),
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 25,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '[' + translate('lan.chooseOne') + ']',
                              style: TextStyle(color: HexColor('#40976c')),
                            )
                          ],
                        ),
                      )
                    : Container(),
                ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: allOptions.length,
                    padding: EdgeInsets.fromLTRB(
                        0.0,
                        MediaQuery.of(context).size.width / 50,
                        0.0,
                        MediaQuery.of(context).size.width / 50),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            // total =    total + double.parse(allOptions[index].price);
                            if (allOptions[index].isSelected == false) {
                              allOptions[index].isSelected = true;
                              totalOptions =
                                  double.parse(allOptions[index].price);
                              widget.productTotal = null;
                              total =
                                  ((totalOptions + totalAddOns) * portinsNum);
                              for (int i = 0; i < allOptions.length; i++) {
                                if (i != index) {
                                  allOptions[i].isSelected = false;
                                }
                              }
                            } else if (allOptions[index].isSelected == true) {
                              for (int i = 0; i < allOptions.length; i++) {
                                allOptions[i].isSelected = false;
                              }
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: 50,
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
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width / 50),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                        child: Text(
                                      translationLanguage == 0
                                          ? "${allOptions[index].text}"
                                          : "${allOptions[index].text_ar}",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              25),
                                    )),
                                  ),
                                  Text(
                                    "${allOptions[index].price}" + ' ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                30,
                                        color: HexColor('#40976c')),
                                  ),
                                  Text(
                                    translate('lan.rs'),
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                30,
                                        fontWeight: FontWeight.bold,
                                        color: HexColor('#40976c')),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, bottom: 5),
                                    child: SvgPicture.asset(
                                      'assets/images/comment.svg',
                                      height: 20,
                                      width: 20,
                                      color: allOptions[index].isSelected
                                          ? Colors.green[600]
                                          : Colors.black12,
                                    ),
                                  )
                                ],
                              )),
                        ),
                      );
                    }),

                //Addons
                allAddons.length > 0
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              translate('lan.customYourOrder'),
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 25,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '[' + translate('lan.optional') + ']',
                              style: TextStyle(color: HexColor('#40976c')),
                            )
                          ],
                        ),
                      )
                    : Container(),
                ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: allAddons.length,
                    padding: EdgeInsets.fromLTRB(
                        0.0,
                        MediaQuery.of(context).size.width / 50,
                        0.0,
                        MediaQuery.of(context).size.width / 50),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          print(allAddons[index].price.toString() + 'hhhhh');

                          setState(() {
                            // total =    total + double.parse(allOptions[index].price);
                            if (allAddons[index].isSelected == false) {
                              allAddons[index].isSelected = true;
                              widget.productTotal = null;
                              totalAddOns = totalAddOns +
                                  double.parse(allAddons[index].price);
                              total =
                                  ((totalOptions + totalAddOns) * portinsNum);
                            } else {
                              allAddons[index].isSelected = false;
                              totalAddOns = totalAddOns -
                                  double.parse(allAddons[index].price);
                              total =
                                  ((totalOptions + totalAddOns) * portinsNum);
                            }
                          });
                          print(total.toString() + 'jjjjjjj');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: 50,
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
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        translationLanguage == 0
                                            ? "${allAddons[index].nameEn}"
                                            : "${allAddons[index].nameAr}",
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                24),
                                      ),
                                    ),
                                    allAddons[index].price.toString() == "0.00"
                                        ? Container()
                                        : Text(
                                            "${allAddons[index].price}" + ' ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    30,
                                                color: HexColor('#40976c')),
                                          ),
                                    allAddons[index].price.toString() == "0.00"
                                        ? Container()
                                        : Text(
                                            translate('lan.rs'),
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    30,
                                                fontWeight: FontWeight.bold,
                                                color: HexColor('#40976c')),
                                          ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 0, 5, 5),
                                      child: SvgPicture.asset(
                                        'assets/images/comment.svg',
                                        height: 20,
                                        width: 20,
                                        color: allAddons[index].isSelected
                                            ? HexColor('#40976c')
                                            : Colors.black12,
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        ),
                      );
                    }),

                const SizedBox(
                  height: 10,
                ),
                allDrinks.length > 0
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          translate('lan.chooseDrink'),
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 25,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
                allDrinks.length > 0
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: allDrinks.length,
                        padding: EdgeInsets.fromLTRB(
                            0.0,
                            MediaQuery.of(context).size.width / 50,
                            0.0,
                            MediaQuery.of(context).size.width / 50),
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                // total =    total + double.parse(allOptions[index].price);
                                if (allDrinks[index].isSelected == false) {
                                  allDrinks[index].isSelected = true;
                                  drinkID = allDrinks[index].id;
                                  for (int i = 0; i < allDrinks.length; i++) {
                                    if (i != index) {
                                      allDrinks[i].isSelected = false;
                                    }
                                  }
                                } else if (allDrinks[index].isSelected ==
                                    true) {
                                  for (int i = 0; i < allDrinks.length; i++) {
                                    allDrinks[i].isSelected = false;
                                  }
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  height: 50,
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
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width / 50),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                            child: Text(
                                          translationLanguage == 0
                                              ? "${allDrinks[index].titleEN}"
                                              : "${allDrinks[index].titleAR}",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  25),
                                        )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 5, bottom: 5),
                                        child: SvgPicture.asset(
                                          'assets/images/comment.svg',
                                          height: 20,
                                          width: 20,
                                          color: allDrinks[index].isSelected
                                              ? Colors.green[600]
                                              : Colors.black12,
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          );
                        })
                    : Container(),

                const SizedBox(
                  height: 10,
                ),
                //Notes
                Container(
                  margin: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width / 30,
                    0,
                    MediaQuery.of(context).size.width / 30,
                    0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        translate('lan.notes') + ' ',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 25,
                            fontWeight: FontWeight.bold),
                      ),
                      Text('[' + translate('lan.optional') + ']',
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 30,
                              color: HomePage.colorGrey)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                        borderRadius: new BorderRadius.circular(20),
                        border: Border.all(color: HexColor('#DDDDDD'))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          controller: tECNotes,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          decoration: InputDecoration.collapsed(
                            hintText: translate('lan.leftYourNotes'),
                            hintStyle: TextStyle(color: Colors.black),
                          )),
                    ),
                  ),
                ),

                //Portions

                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      translate('lan.numOfOrders'),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (portinsNum > 1)
                          setState(() {
                            portinsNum--;
                            total = (totalAddOns + totalOptions) * portinsNum;
                            widget.productTotal = null;
                          });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: HexColor('#40976C'),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '-',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Container(
                      width: 50,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: HexColor('#40976C'),
                          )),
                      child: Center(
                        child: Text(
                          portinsNum.toString(),
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          portinsNum++;
                          total = (totalAddOns + totalOptions) * portinsNum;
                          widget.productTotal = null;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: HexColor('#40976C'),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '+',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                //Submit
                InkWell(
                  onTap: () {
                    if (widget.update != null)
                      removeProduct(widget.productID!);
                    else
                      SendDataToServer();
                  },
                  // showCupertinoModalBottomSheet(
                  // expand: false,
                  // context: context,
                  // backgroundColor: Colors.white.withOpacity(0.7),
                  // builder: (context) {
                  //   return StatefulBuilder(builder:
                  //       (BuildContext context, StateSetter setState) {
                  //     FocusScope.of(context).unfocus();
                  //     return Container(
                  //         height: 150,
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.only(
                  //             topLeft: Radius.circular(
                  //                 MediaQuery.of(context).size.width / 25),
                  //             topRight: Radius.circular(
                  //                 MediaQuery.of(context).size.width / 25),
                  //           ),
                  //         ),
                  //         child: Column(
                  //           //mainAxisSize: MainAxisSize.min,
                  //           //mainAxisAlignment: MainAxisAlignment.end,
                  //           children: <Widget>[
                  //             //ايقونة النزول
                  //             Container(
                  //               child: Row(
                  //                 children: <Widget>[
                  //                   Expanded(
                  //                     child: Container(),
                  //                   ),
                  //                   Container(
                  //                     child: CircleAvatar(
                  //                       child: GestureDetector(
                  //                         onTap: () {
                  //                           Navigator.of(context).pop();
                  //                         },
                  //                         child: Icon(
                  //                           Icons.expand_more,
                  //                           size: MediaQuery.of(context)
                  //                               .size
                  //                               .width /
                  //                               10,
                  //                           color: HomePage.colorGreen,
                  //                         ),
                  //                       ),
                  //                       backgroundColor: Colors.transparent,
                  //                       radius: MediaQuery.of(context)
                  //                           .size
                  //                           .width /
                  //                           25,
                  //                     ),
                  //                   ),
                  //                   SizedBox(
                  //                     width: MediaQuery.of(context)
                  //                         .size
                  //                         .width /
                  //                         20,
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //             Container(
                  //                 decoration: BoxDecoration(
                  //                   borderRadius:
                  //                   BorderRadius.circular(15.0),
                  //                 ),
                  //                 padding: EdgeInsets.all(
                  //                     MediaQuery.of(context).size.width /
                  //                         35),
                  //                 child: Container(
                  //                   margin: new EdgeInsets.only(
                  //                       left: MediaQuery.of(context)
                  //                           .size
                  //                           .width /
                  //                           15,
                  //                       right: MediaQuery.of(context)
                  //                           .size
                  //                           .width /
                  //                           15),
                  //                   child: ButtonTheme(
                  //                     shape: new RoundedRectangleBorder(
                  //                         borderRadius:
                  //                         new BorderRadius.circular(
                  //                             10.0)),
                  //                     minWidth: 500.0,
                  //                     height: MediaQuery.of(context)
                  //                         .size
                  //                         .width /
                  //                         8,
                  //                     child: RaisedButton(
                  //                       child: Text(
                  //                           translate(
                  //                               'lan.etmamElshraa'),
                  //                           style: TextStyle(
                  //                               fontSize: MediaQuery.of(
                  //                                   context)
                  //                                   .size
                  //                                   .width /
                  //                                   20,
                  //                               color: Colors.white)),
                  //                       color: HomePage.colorGreen,
                  //                       onPressed: () {
                  //                         Navigator.pop(context);
                  //                         SendDataToServer(context);
                  //                       },
                  //                     ),
                  //                   ),
                  //                 ))
                  //           ],
                  //         ));
                  //   });
                  // }),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: HomePage.colorGreen),
                      margin: EdgeInsets.all(
                          MediaQuery.of(context).size.width / 15),
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width / 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              child: Text(
                            translate('lan.addToCard'),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width / 24),
                          )),
                          // Expanded(child: Container()),
                          // Container(
                          //     child: Text("${AppLocalizations.of(context).rs} ",style: TextStyle(color:HomePage.colorYellow,fontSize: MediaQuery.of(context).size.width/25,fontWeight: FontWeight.bold),)),
                        ],
                      )),
                ),
                const SizedBox(
                  height: 30,
                )
              ],
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

  Future SendDataToServer({String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    var listOptions = [];
    for (int i = 0; i < allOptions.length; i++) {
      if (allOptions[i].isSelected) {
        listOptions.add(allOptions[i].id);
      }
    }

    if (allOptions.length > 0) {
      if (listOptions.length == 0) {
        displayToastMessage(translate('lan.pleaseChooseSize'));
        return;
      }
    }
    if (allDrinks.length > 0) {
      if (drinkID == null) {
        displayToastMessage(translate('lan.chooseDrinkPlz'));
        return;
      }
    }

    var listAddons = [];
    for (int i = 0; i < allAddons.length; i++) {
      if (allAddons[i].isSelected) {
        listAddons.add(allAddons[i].id);
        print(allAddons[i].nameEn);
      }
    }

    //
    // print(token.toString()+'hhhhhhh');
    // print(vendorID);
    // print(productDetailsModel.id);
    // print(portinsNum);
    // print(listOptions);
    // print(listAddons);

    if (productDetailsModel.mainName != '') {
      setState(() {
        loading = true;
      });
      print(drinkID);
      if (cardToken == "" || cardToken.toString() == "null") {
        prefs.setInt('counter', 1);
        setState(() {
          prefs.setInt('counter', 1);
          counter = 1;
        });

        var response = await http
            .post(Uri.parse("${HomePage.URL}cart/add_product"), headers: {
          "Content-Language": lan,
          "Authorization": "Bearer $token",
        }, body: {
          "vendor_id": "$vendorID",
          "product_id": "${productDetailsModel.id}",
          "quantity": "$portinsNum",
          "options": "$listOptions",
          "addons": "$listAddons",
          "note": "${tECNotes.text}",
          "drink_id": drinkID == null ? '' : drinkID.toString()
        });
        var dataOrder = json.decode(response.body);
        log(dataOrder.toString());
        if ("${dataOrder['success']}" == "1") {
          saveDataInSharedPref(context, dataOrder['cart']['token']);
        } else {
          displayToastMessage(dataOrder['message']);
          setState(() {
            loading = false;
          });
        }
      } else {
        print('CarToken' + cardToken.toString());
        var response = await http
            .post(Uri.parse("${HomePage.URL}cart/add_product"), headers: {
          "Content-Language": lan,
          "Authorization": "Bearer $token",
        }, body: {
          "vendor_id": "$vendorID",
          "product_id": "${productDetailsModel.id}",
          "quantity": "$portinsNum",
          "options": "$listOptions",
          "addons": "$listAddons",
          "note": "${tECNotes.text}",
          "cart_token": cardToken,
          "drink_id": drinkID == null ? '' : drinkID.toString()
        });
        log(response.body.toString());
        var dataOrder = json.decode(response.body);

        if ("${dataOrder['success']}" == "1") {
          setState(() {
            prefs.setInt('counter', dataOrder['cart']['items_count']);
            counter = dataOrder['cart']['items_count'];
          });
          displayToastMessage(translate('lan.addedSuccessfully'));
          goToMyCard();
        } else {
          displayToastMessage(dataOrder['message']);
          setState(() {
            loading = false;
          });
        }
      }
    }
  }

  void saveDataInSharedPref(BuildContext context, cardTokenP) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cardToken', cardTokenP);
    setState(() {
      cardToken = cardTokenP;
    });
    goToMyCard();
  }

  goToMyCard() {
    if (isLogin!) {
      if (widget.update != null) {
        displayToastMessage(translate('lan.updated'));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Card1()));
      } else if (widget.favorite != null) {
        displayToastMessage(translate('lan.addedSuccessfully'));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => FavoritesScreen()));
      } else {
        displayToastMessage(translate('lan.addedSuccessfully'));
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Products(
                      vendorID: vendorID,
                      catID: widget.catID,
                    )));
      }
    } else {
      displayToastMessage(translate('lan.signInToAddProduct'));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  goToHome(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
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
      duration: Duration(seconds: 2),
      background: HomePage.colorYellow,
      position: NotificationPosition.bottom,
    );
  }
}
