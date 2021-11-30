import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Models/Cats.dart';
import 'package:shormeh/Screens/Card/Card5OdrerStatus.dart';
import 'package:shormeh/Screens/Card/Card6TaqeemElkhdma.dart';
import 'package:shormeh/Screens/Cats/2Products.dart';
import 'package:shormeh/Screens/Cats/3ProductDetails.dart';
import 'package:shormeh/Screens/Offers/offers.dart';
import 'package:shormeh/Screens/SelectBrabche.dart';

import '../Home/HomePage.dart';

class HomeScreen extends StatefulWidget {
  int? vendorID;
  HomeScreen({this.vendorID});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // bool isIndicatorActive = true;

  List<Cats> allCats = [];
  List<String> allSliderHome = [];
  String language = '';
  DateTime? currentBackPressTime;
  bool isIndicatorActive = true;
  String? token;
  List<String> startTime = [];
  List<String> endTime = [];
  List<String> startTime12Hour = [];
  List<String> endTime12Hour = [];
  String start = '';
  String end = '';
  bool open = true;
  List<int> productId = [];
  List<int> catId = [];

  //FCM
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  String vendorName = "";
  int? vendorID;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllSliderHome();
    getDataFromSharedPref();
    getLocation();
    print(widget.vendorID);
  }

  getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    Position position = await Geolocator.getCurrentPosition();
    prefs.setDouble('lat', position.latitude);
    prefs.setDouble('long', position.longitude);
  }

  Future<void> getDataFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('branchSelected', true);

    final _vendorID = prefs.getInt('vendorID');
    int lan = prefs.getInt('translateLanguage')!;
    String _token = prefs.getString("token") ?? '';

    setState(() {
      lan == 1 ? language = 'ar' : language = 'en';
      token = _token;
      if (widget.vendorID == null)
        vendorID = _vendorID;
      else {
        vendorID = widget.vendorID;
        prefs.setInt('vendorID', widget.vendorID!);
      }
      //HomePage.cardToken = _cardToken;
    });
    getTime(vendorID!);
    fcmNotification();
    getAllCats();
  }

  //FCM
  fcmNotification() async {
    //FCM
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      isHomeScreen: true,
                    )));
      }
    });

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification android = message.notification!.android!;

      if (notification != null && android != null) {
        final order =
            message.notification!.body!.replaceAll(RegExp('[^0-9]'), '');
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                notification.title!,
                notification.body!,
                icon: 'app_icon',
              ),
            ));
        if (message.notification!.title == "تقيم الخدمة") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Card6TaqeemElkhdma(
                        vendorID: vendorID,
                        token: token,
                        orderId: order,
                      )));
        } else if (message.notification!.title == "تغير حالة الطلب") {
          showSimpleNotification(
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderStatus(
                              orderID: order.toString(),
                            )));
              },
              child: Container(
                height: 65,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Column(
                      children: [
                        Text(
                          message.notification!.title!,
                          style: TextStyle(
                              color: HomePage.colorGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          message.notification!.body!,
                          style: TextStyle(
                              color: HomePage.colorGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
              ),
            ),
            duration: Duration(seconds: 3),
            background: Colors.white,
          );
        } else
          showSimpleNotification(
            InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Offers()));
              },
              child: Container(
                height: 65,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Column(
                      children: [
                        Text(
                          message.notification!.title!,
                          style: TextStyle(
                              color: HomePage.colorGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          message.notification!.body!,
                          style: TextStyle(
                              color: HomePage.colorGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
              ),
            ),
            duration: Duration(seconds: 3),
            background: Colors.white,
          );
      }
    });

    //ديه بتفتح التطبيق وتقيم الخدمة
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final order =
          message.notification!.body!.replaceAll(RegExp('[^0-9]'), '');
      print(
          'A new onMessageOpenedApp event was published Message ${message.notification!.title} ');
      if (message.notification!.title == "تقيم الخدمة") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Card6TaqeemElkhdma(
                      vendorID: vendorID,
                      token: token,
                      orderId: order,
                    )));
      } else if (message.notification!.title == "تغير حالة الطلب") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderStatus(
                      orderID: order,
                    )));
      } else
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Offers()));
    });

    FirebaseMessaging.instance.getToken().then((value) {
      print("FIREBASE TOKEN $value");
    });
  }

  getTime(int id) async {
    final response = await http.get(
      Uri.parse("${HomePage.URL}vendors/$id/times"),
    );

    var data = json.decode(response.body);
    print(data);
    startTime.clear();
    endTime.clear();
    setState(() {
      start = '';
      end = '';
    });

    for (int i = 0; i < data.length; i++) {
      // print(DateFormat("HH:mm")
      //     .format(DateFormat.jm().parse(data[i]['end_time'])));

      setState(() {
        startTime.add(data[i]['start_time']);
        endTime.add(data[i]['end_time']);
        if (int.parse(startTime[i].substring(0, 2)) < 12)
          startTime12Hour.add(data[i]['start_time'] + ' AM');
        else if (int.parse(startTime[i].substring(0, 2)) == 12)
          startTime12Hour.add(data[i]['start_time'] + ' PM');
        else if (int.parse(startTime[i].substring(0, 2)) == 0)
          startTime12Hour.add(data[i]['start_time'] + ' AM');
        else
          startTime12Hour.add(
              (int.parse(startTime[i].substring(0, 2)) - 12).toString() +
                  startTime[i].substring(2, 5) +
                  ' PM');
        if (int.parse(endTime[i].substring(0, 2)) < 12)
          endTime12Hour.add(data[i]['end_time'] + ' AM');
        else if (int.parse(endTime[i].substring(0, 2)) == 12)
          endTime12Hour.add(data[i]['endTime'] + ' PM');
        else if (int.parse(endTime[i].substring(0, 2)) == 0)
          endTime12Hour.add(data[i]['endTime'] + ' AM');
        else
          endTime12Hour.add(
              (int.parse(endTime[i].substring(0, 2)) - 12).toString() +
                  endTime[i].substring(2, 5) +
                  ' PM');
      });

      print(startTime12Hour);
      print(endTime12Hour);
      if (int.parse(startTime[i].substring(0, 2)) <= DateTime.now().hour &&
          int.parse(endTime[i].substring(0, 2)) >= DateTime.now().hour) {
        setState(() {
          start = startTime[i];
          end = endTime[i];
        });
      }
      print(start);
    }

    print(startTime);
    print(endTime);

    if (start == '')
      setState(() {
        open = false;
      });
    else
      setState(() {
        open = true;
      });

    // for (int i = 0; i < startTime.length; i++) {
    //
    //
    // }
  }

  Future getAllSliderHome() async {
    var response = await Dio().get("${HomePage.URL}sliders");
    print(response.data);
    setState(() {
      allSliderHome = [
        response.data[0]['image_one'],
        response.data[1]['image_one'],
        response.data[2]['image_one'],
      ];
      productId = [
        response.data[0]['id'],
        response.data[1]['id'],
        response.data[2]['id'],
      ];
      catId = [
        response.data[0]['subcategory']['id'],
        response.data[1]['subcategory']['id'],
        response.data[2]['subcategory']['id'],
      ];
      isIndicatorActive = false;
    });
  }

  Future getAllCats() async {
    var response = await http.get(
        Uri.parse("${HomePage.URL}vendors/$vendorID/categories"),
        headers: {"Content-Language": language});

    var dataAllCats = json.decode(response.body);
    print(dataAllCats.toString() + 'fkfkfkfkfk');
    vendorName = dataAllCats['vendor']['name'];
    setState(() {
      vendorID = dataAllCats['vendor']['id'];
    });
    print(vendorID! + 20000);

    for (int i = 0; i < dataAllCats['categories'].length; i++) {
      allCats.add(new Cats(
          dataAllCats['categories'][i]['id'],
          dataAllCats['categories'][i]['name'],
          dataAllCats['categories'][i]['image']));
    }
    print("${allCats[1].id}");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          vendorName,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal'),
        ),
        backgroundColor: HexColor('#40976c'),
        automaticallyImplyLeading: false, // Don't show the leading button
        actions: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SelectBranche()));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                      Text(
                        translate('lan.branches2'),
                        style: TextStyle(fontSize: 16, fontFamily: 'Tajawal'),
                      )
                    ],
                  )),
            ),
          ),
        ],
        elevation: 5.0,
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            open
                ? Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        //Slider
                        Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              enlargeCenterPage: true,
                              autoPlay: true,
                              autoPlayAnimationDuration:
                                  Duration(milliseconds: 1000),
                              height: MediaQuery.of(context).size.height,
                              viewportFraction: 1.0,
                            ),
                            items: allSliderHome.map((banner) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                      onTap: () {
                                        int index =
                                            allSliderHome.indexOf(banner);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductDetails(
                                                      productID:
                                                          productId[index],
                                                      catID: catId[index],
                                                      vendor: vendorID!,
                                                    )));
                                      },
                                      child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          decoration: BoxDecoration(),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: allSliderHome.isEmpty
                                                ? Container(
                                                    color: Colors.black12,
                                                  )
                                                : FadeInImage.assetNetwork(
                                                    placeholder:
                                                        'assets/images/59529-skeleton-loader-kuhan.gif',
                                                    image: banner,
                                                    fit: BoxFit.fill,
                                                  ),
                                          )));
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        //Cats
                        allCats.isEmpty
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 100,
                                  ),
                                  Container(
                                    height: 100,
                                    width: 100,
                                    child: Lottie.asset(
                                        'assets/images/lf20_mvihowzk.json'),
                                  )
                                ],
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                itemCount: allCats.length,
                                padding: EdgeInsets.fromLTRB(
                                    0.0,
                                    MediaQuery.of(context).size.width / 50,
                                    0.0,
                                    MediaQuery.of(context).size.width / 50),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  //childAspectRatio: MediaQuery.of(context).size.width /10,
                                  mainAxisExtent:
                                      MediaQuery.of(context).size.width / 2.3,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Products(
                                                  catID: allCats[index].id,
                                                  vendorID: vendorID!,
                                                )),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        width: size.width * 0.5,
                                        height: size.height * 0.2,
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: Stack(
                                              children: [
                                                FadeInImage.assetNetwork(
                                                  placeholder:
                                                      'assets/images/59529-skeleton-loader-kuhan.gif',
                                                  image: allCats[index].image,
                                                  fit: BoxFit.fill,
                                                  width: size.width * 0.45,
                                                ),

                                                // Image(
                                                //   image: NetworkImage(
                                                //       '${allCats[index].image}'),
                                                //   fit: BoxFit.fill,
                                                //   width: size.width * 0.45,
                                                //   loadingBuilder: (BuildContext context,
                                                //       Widget child,
                                                //       ImageChunkEvent loadingProgress) {
                                                //     if (loadingProgress == null)
                                                //       return child;
                                                //     return Container(
                                                //       color: Colors.black12,
                                                //     );
                                                //   },
                                                // ),
                                                Positioned(
                                                  bottom: 0,
                                                  child: Container(
                                                    width: size.width * 0.45,
                                                    height: size.height * 0.1,
                                                    alignment: language == 'ar'
                                                        ? Alignment.bottomRight
                                                        : Alignment.bottomLeft,
                                                    padding: EdgeInsets.only(
                                                        left: 10, bottom: 12),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          new BorderRadius.only(
                                                        bottomLeft: const Radius
                                                            .circular(15.0),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(15.0),
                                                      ),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.black
                                                              .withOpacity(
                                                                  0.02),
                                                          Colors.black
                                                              .withOpacity(0.5),
                                                          Colors.black
                                                              .withOpacity(0.7),
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: Text(
                                                        allCats[index].name,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'Tajawal'),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                        const SizedBox(
                          height: 75,
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: Stack(
                      children: [
                        ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            //Slider
                            Container(
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  enlargeCenterPage: true,
                                  autoPlay: true,
                                  autoPlayAnimationDuration:
                                      Duration(milliseconds: 1000),
                                  height: MediaQuery.of(context).size.height,
                                  viewportFraction: 1.0,
                                ),
                                items: allSliderHome.map((banner) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return InkWell(
                                          onTap: () {
                                            //sliderBannerClick(allBanners,currentIndex);
                                          },
                                          child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10.0),
                                              decoration: BoxDecoration(),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: allSliderHome.isEmpty
                                                    ? Container(
                                                        color: Colors.black12,
                                                      )
                                                    : FadeInImage.assetNetwork(
                                                        placeholder:
                                                            'assets/images/59529-skeleton-loader-kuhan.gif',
                                                        image: banner,
                                                        fit: BoxFit.fill,
                                                      ),
                                                // Image.network(
                                                //         banner,
                                                //         fit: BoxFit.fill,
                                                //         loadingBuilder:
                                                //             (BuildContext context,
                                                //                 Widget child,
                                                //                 ImageChunkEvent
                                                //                     loadingProgress) {
                                                //           if (loadingProgress == null)
                                                //             return child;
                                                //           return Container(
                                                //             color: Colors.black12,
                                                //           );
                                                //         },
                                                //       ),
                                              )));
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            //Cats
                            GridView.builder(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                itemCount: allCats.length,
                                padding: EdgeInsets.fromLTRB(
                                    0.0,
                                    MediaQuery.of(context).size.width / 50,
                                    0.0,
                                    MediaQuery.of(context).size.width / 50),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  //childAspectRatio: MediaQuery.of(context).size.width /10,
                                  mainAxisExtent:
                                      MediaQuery.of(context).size.width / 2.3,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Products(
                                                  catID: allCats[index].id,
                                                  vendorID: vendorID!,
                                                )),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        width: size.width * 0.5,
                                        height: size.height * 0.2,
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: Stack(
                                              children: [
                                                FadeInImage.assetNetwork(
                                                  placeholder:
                                                      'assets/images/59529-skeleton-loader-kuhan.gif',
                                                  image: allCats[index].image,
                                                  fit: BoxFit.fill,
                                                  width: size.width * 0.45,
                                                ),

                                                // Image(
                                                //   image: NetworkImage(
                                                //       '${allCats[index].image}'),
                                                //   fit: BoxFit.fill,
                                                //   width: size.width * 0.45,
                                                //   loadingBuilder: (BuildContext context,
                                                //       Widget child,
                                                //       ImageChunkEvent loadingProgress) {
                                                //     if (loadingProgress == null)
                                                //       return child;
                                                //     return Container(
                                                //       color: Colors.black12,
                                                //     );
                                                //   },
                                                // ),
                                                Positioned(
                                                  bottom: 0,
                                                  child: Container(
                                                    width: size.width * 0.45,
                                                    height: size.height * 0.1,
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    padding: EdgeInsets.only(
                                                        left: 10, bottom: 12),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          new BorderRadius.only(
                                                        bottomLeft: const Radius
                                                            .circular(15.0),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(15.0),
                                                      ),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.black
                                                              .withOpacity(
                                                                  0.02),
                                                          Colors.black
                                                              .withOpacity(0.5),
                                                          Colors.black
                                                              .withOpacity(0.7),
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      allCats[index].name,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'Tajawal'),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.black.withOpacity(0.8),
                        ),
                        Center(
                          child: Container(
                            height: 230,
                            width: 350,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  translate('lan.branchClosed'),
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      fontFamily: 'Tajawal'),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  translate('lan.times'),
                                  style: TextStyle(
                                      color: HexColor('#40976c'),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      fontFamily: 'Tajawal'),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      translate('lan.from'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                          fontFamily: 'Tajawal'),
                                    ),
                                    Center(
                                      child: Text(
                                        startTime12Hour
                                            .toString()
                                            .replaceAll('[', '')
                                            .replaceAll(']', '')
                                            .replaceAll(',', '  - '),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                            fontFamily: 'Tajawal'),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      translate('lan.to'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                          fontFamily: 'Tajawal'),
                                    ),
                                    Center(
                                      child: Text(
                                        endTime12Hour
                                            .toString()
                                            .replaceAll('[', '')
                                            .replaceAll(']', '')
                                            .replaceAll(',', '  - '),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                            fontFamily: 'Tajawal'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SelectBranche()));
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 300,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        translate('lan.chooseBranch'),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            fontFamily: 'Tajawal'),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
