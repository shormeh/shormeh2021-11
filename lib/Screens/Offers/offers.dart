import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/OffersModel.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';
import 'package:shormeh/Screens/Offers/OfferDetails.dart';

class Offers extends StatefulWidget {
  @override
  _OffersState createState() => _OffersState();
}

class _OffersState extends State<Offers> {
  List<OffersModel> allOffers = [];

  bool isIndicatorActive = false;

  final PagingController<int, OffersModel> _pagingController =
      PagingController(firstPageKey: 0);

  String token = "";
  int currentPage = 1;
  int increment = 0;
  int translationLanguage = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();
    _pagingController.addPageRequestListener((pageKey) {
      getAllOffers(pageKey);
    });
  }

  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    final _translateLanguage = prefs.getInt('translateLanguage');

    final _cardToken = prefs.getString("cardToken");
    final _token = prefs.getString("token");
    setState(() {
      token = _token!;
      translationLanguage = _translateLanguage!;
    });

    print("$token");
  }

  // Future getAllOffers() async {
  //   var response =
  //   await http.get("${HomePage.URL}customer/notifications",headers: {
  //     "Authorization": "Bearer $token",
  //   });
  //
  //   var data = json.decode(response.body);
  //   log(data['data'][1].toString());
  //
  //   setState(() {
  //     for(int i=0;i<data['data'].length;i++){
  //       allOffers.add(new OffersModel(
  //         data['data'][i]['id'],
  //         data['data'][i]['title'],
  //         data['data'][i]['description'],
  //         data['data'][i]['image']
  //       ));
  //     }
  //     //فى اللحظة دية كل الصيدليات بكل الاقسام اتحملت
  //     isIndicatorActive=false;
  //   });
  //
  // }

  Future getAllOffers(int pageKey) async {
    final prefs = await SharedPreferences.getInstance();
    final _token = prefs.getString("token");
    var response = await http
        .get(Uri.parse("${HomePage.URL}customer/notifications"), headers: {
      "Authorization": "Bearer $token",
    });
    var dataAllSubCats = json.decode(response.body);

    final isLastPage = dataAllSubCats['data'].length < 3;
    print(response.body);
    for (int i = 0; i < dataAllSubCats['data'].length; i++) {
      allOffers.add(new OffersModel(
          dataAllSubCats['data'][i]['id'],
          dataAllSubCats['data'][i]['title'],
          dataAllSubCats['data'][i]['description'],
          dataAllSubCats['data'][i]['image']));
    }
    if (isLastPage) {
      _pagingController.appendLastPage(allOffers.sublist(increment), 'no');
    } else {
      final nextPageKey = pageKey + dataAllSubCats['products']['data'].length;
      _pagingController.appendPage(allOffers, nextPageKey.toInt(), 'no');
    }
    setState(() {
      increment = increment + 3;
      currentPage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor('#40976c'),
          title: Text(translate('lan.offers')),
          elevation: 5.0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          child: isIndicatorActive
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : PagedListView<int, OffersModel>(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<OffersModel>(
                      noItemsFoundIndicatorBuilder: (_) {
                        return Column(
                          children: [
                            Container(
                              height: 400,
                              width: 500,
                              child: Lottie.asset(
                                  'assets/images/lf20_f8ya7rj2.json'),
                            ),
                            Text(translate('lan.offersEmpty')),
                          ],
                        );
                      },
                      firstPageProgressIndicatorBuilder: (_) => Column(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height / 4.5,
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
                                height:
                                    MediaQuery.of(context).size.height / 4.5,
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
                                height:
                                    MediaQuery.of(context).size.height / 4.5,
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
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OfferDetails(
                                        id: allOffers[index].id,
                                        description:
                                            allOffers[index].description,
                                        image: allOffers[index].image,
                                      )),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 2.0,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: HomePage.colorGreen,
                                            spreadRadius: 0.0),
                                      ],
                                    ),
                                    child: allOffers[index].image == ''
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: Image(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  4.5,
                                              image: AssetImage(
                                                  'assets/images/logo.png'),
                                              fit: BoxFit.fill,
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: FadeInImage.assetNetwork(
                                              placeholder:
                                                  'assets/images/59529-skeleton-loader-kuhan.gif',
                                              image:
                                                  "${allOffers[index].image}",
                                              fit: BoxFit.fill,
                                              width: double.infinity,
                                            ),
                                          ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(
                                      MediaQuery.of(context).size.width / 30,
                                      MediaQuery.of(context).size.width / 50,
                                      MediaQuery.of(context).size.width / 30,
                                      MediaQuery.of(context).size.width / 50,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 200,
                                              child: Text(
                                                "${allOffers[index].title}",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 200,
                                                  child: Text(
                                                    "${allOffers[index].description}",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Container(
                                                  child: Text(
                                                    translate('lan.more') +
                                                        '...',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            25,
                                                        color: HomePage
                                                            .colorGreen),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Row(
                                            //   children: [
                                            //     Container(
                                            //       width: translationLanguage == 1
                                            //           ? MediaQuery.of(context)
                                            //                   .size
                                            //                   .width /
                                            //               1.3
                                            //           : 0.0,
                                            //     ),
                                            //     Container(
                                            //       child: Text(
                                            //
                                            //         style: TextStyle(
                                            //             fontWeight: FontWeight.bold,
                                            //             fontSize:
                                            //                 MediaQuery.of(context)
                                            //                         .size
                                            //                         .width /
                                            //                     25,
                                            //             color: HomePage.colorGreen),
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
        ));
  }
}
