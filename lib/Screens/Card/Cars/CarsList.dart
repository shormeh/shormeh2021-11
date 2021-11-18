import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/Car.dart';
import 'package:shormeh/Models/CardModel1.dart';
import 'package:shormeh/Screens/Card/Card3OrderDetails.dart';
import 'package:shormeh/Screens/Card/Cars/AddCar.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class CarsList extends StatefulWidget {
  bool? added;
  CarsList({this.added});
  @override
  _CarsListState createState() => _CarsListState();
}

class _CarsListState extends State<CarsList> {
  bool isIndicatorActive = true;
  bool isChoosed = false;

  List<CarModel> allCarsModel = [];
  List<Card1Model> allMyCardProducts = [];

  String cardToken = "";
  String token = "";
  String? method;
  String? lan;
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
      cardToken = _cardToken!;
      token = _token!;
      _translateLanguage == 0 ? lan = 'en' : lan = 'ar';
    });
    getMyCars();
  }

  Future getMyCars() async {
    try {
      var response =
          await http.get(Uri.parse("${HomePage.URL}customer/cars"), headers: {
        "Authorization": "Bearer $token",
      });
      var dataMyCars = json.decode(response.body);

      setState(() {
        print("ZZZZZZ${dataMyCars}");
        for (int i = 0; i < dataMyCars.length; i++) {
          allCarsModel.add(new CarModel(
              dataMyCars[i]['id'],
              "${dataMyCars[i]['car_model']}",
              "${dataMyCars[i]['plate_number']}",
              "${dataMyCars[i]['car_color']}",
              false));
        }

        //فى اللحظة دية كل الصيدليات بكل الاقسام اتحملت
        isIndicatorActive = false;
      });
    } catch (e) {
      print("WWWWW $e");
    }
  }

  onBackPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          centerTitle: true,
          elevation: 5.0,
          backgroundColor: HexColor('#40976c'),
          title: Text(
            translate('lan.myCars'),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
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
              isIndicatorActive
                  ? Center(
                      child: Container(
                      height: 80,
                      width: 80,
                      child: Lottie.asset('assets/images/lf20_mvihowzk.json'),
                    ))
                  : Column(
                      children: [
                        Expanded(
                          flex: 9,
                          child: allCarsModel.length == 0
                              ? Center(
                                  child: Lottie.asset(
                                      'assets/images/lf20_hntom2e3.json',
                                      height: 150,
                                      width: 150),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  itemCount: allCarsModel.length,
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
                                          isChoosed = true;
                                          method =
                                              allCarsModel[index].car_model;
                                          allCarsModel.forEach((element) {
                                            element.isChoosed = false;
                                          });
                                          allCarsModel[index].isChoosed = true;
                                        });
                                        print(allCarsModel[index].id);
                                        if (isChoosed)
                                          setCatAndGetMyCardProducts(
                                              allCarsModel[index].id);
                                      },
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: double.infinity,
                                            height: 55,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1.0,
                                                  color: allCarsModel[index]
                                                          .isChoosed
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
                                                  value: allCarsModel[index]
                                                      .car_model,
                                                  groupValue: method,
                                                  onChanged: (value) {
                                                    setCatAndGetMyCardProducts(
                                                        allCarsModel[index].id);
                                                    setState(() {
                                                      isChoosed = true;
                                                      method =
                                                          allCarsModel[index]
                                                              .car_model;
                                                      allCarsModel
                                                          .forEach((element) {
                                                        element.isChoosed =
                                                            false;
                                                      });
                                                      allCarsModel[index]
                                                          .isChoosed = true;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  allCarsModel[index].car_model,
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                        ),
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.4,
                          margin: EdgeInsets.all(
                              MediaQuery.of(context).size.width / 30),
                          child: ButtonTheme(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0)),
                            height: MediaQuery.of(context).size.width / 8,
                            child: RaisedButton(
                              child: Text(translate('lan.addCar'),
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              25,
                                      color: Colors.white)),
                              color: HomePage.colorGreen,
                              onPressed: () {
                                //Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddCar()),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
              isChoosed
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
        ));
  }

  Future setCatAndGetMyCardProducts(int idCar) async {
    var response =
        await http.post(Uri.parse("${HomePage.URL}cart/choose_car"), headers: {
      'Authorization': 'Bearer $token',
      "Content-Language": lan!,
    }, body: {
      'car_id': '$idCar',
      'cart_token': "$cardToken",
    });

    var dataOrderDetails = json.decode(response.body);

    log("${dataOrderDetails}");

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              OrderDetails(dataOrderDetails: dataOrderDetails)),
    );
    setState(() {
      isChoosed = false;
    });
  }
}
