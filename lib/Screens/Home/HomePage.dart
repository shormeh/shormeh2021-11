import 'dart:io';

import 'package:badges/badges.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Screens/Card/Card1MyProductDetials.dart';
import 'package:shormeh/Screens/Cats/1Categories.dart';
import 'package:shormeh/Screens/Locations.dart';
import 'package:shormeh/Screens/SideBar/More.dart';
import 'package:shormeh/Screens/SideBar/MyPoints.dart';
import 'package:shormeh/Screens/user/login.dart';

class HomePage extends StatefulWidget {
  static const Color colorGreen = Color(0xff40976C);
  static const Color colorYellow = Color(0xffFCC747);
  static const Color colorGrey = Color(0xff929393);
  static const Color colorGrey2 = Color(0xfff7f7f7);
  static const Color colorBlueHint = Color(0xff748b9d);

  static const URL = "https://worldapp.site/api/";

  // static  bool islogin =false;
  // static  String name ="";
  // static  String phone ="";
  // static  String email ="";
  // static  String token ="";
  //
  // static  int vendorID =0;

  bool? isHomeScreen = false;

  HomePage({this.isHomeScreen});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLogin = false;

  // final autoSizeGroup = AutoSizeGroup();
  var _bottomNavIndex = 2;
  // int? _vendorId;
  // AnimationController _animationController;
  // Animation<double> animation;
  // CurvedAnimation curve;

  final iconList = <IconData>[
    Icons.location_on,
    Icons.local_offer,
    Icons.shopping_basket,
    Icons.menu,
  ];
  int counter = 0;
  bool menu = false;

  bool offers = false;

  bool home = true;

  bool profile = false;

  bool more = false;
  DateTime? currentBackPressTime;

  // bool _hideNavBar;
  // bool control = true;
  // DateTime currentBackPressTime;

  // PersistentTabController _controller=  PersistentTabController(initialIndex: 2);
  //
  // List<Widget> _navScreens() {
  //   return [
  //     Locations(),
  //     getPoints(),
  //     HomeScreen(),
  //     getCard(),
  //     More(),
  //   ];
  //
  // }

  // List<PersistentBottomNavBarItem> _navBarsItems() {
  //   return [
  //     PersistentBottomNavBarItem(
  //       icon: Icon(Icons.location_on),
  //       title: ("Branches"),
  //       activeColorPrimary:  HexColor('#40976c'),
  //       inactiveColorPrimary: Colors.black26,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: Icon(Icons.local_offer,),
  //       title: ("Points"),
  //       activeColorPrimary:  HexColor('#40976c'),
  //       inactiveColorPrimary: Colors.black26,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: Icon(Icons.home,color: Colors.white,),
  //       activeColorPrimary:  HexColor('#40976c'),
  //       inactiveColorPrimary: Colors.black26,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: Icon(Icons.shopping_basket),
  //       title: ("Cart"),
  //       activeColorPrimary:  HexColor('#40976c'),
  //       inactiveColorPrimary: Colors.black26,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: Icon(Icons.menu),
  //       title: ("More"),
  //       activeColorPrimary:  HexColor('#40976c'),
  //       inactiveColorPrimary: Colors.black26,
  //     ),
  //
  //   ];
  // }

  @override
  void initState() {
    super.initState();
    if (widget.isHomeScreen != null)
      setState(() {
        _bottomNavIndex = 2;
      });
    // _controller = PersistentTabController(initialIndex: 2);
    getDataFromSharedPref();
  }

  getDataFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final _isLogin = prefs.getBool('isLogin');
    final _counter = prefs.getInt('counter');

    if (_isLogin == null) {
      await prefs.setBool('isLogin', false);
    } else {
      setState(() {
        isLogin = _isLogin;
        counter = _counter ?? 0;
      });
    }
  }

  Widget getPoints() {
    if (!isLogin)
      return Login();
    else
      return MyPoints();
  }

  Widget getCard() {
    if (!isLogin)
      return Login();
    else
      return Card1();
  }

  Widget pages(int index) {
    switch (index) {
      case 0:
        return Locations();
      case 1:
        return MyPoints();
      case 2:
        return HomeScreen();
      case 3:
        return Card1(
          fromHome: true,
        );
      case 4:
        return More();
    }
    return Container();
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Double Tab To Exit");
      return Future.value(false);
    } else
      exit(0);
    return Future.value(true);
  }

  // final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: WillPopScope(
        onWillPop: () {
          if (_bottomNavIndex != 2) {
            setState(() {
              menu = false;
              offers = false;
              home = true;
              profile = false;
              more = false;
              _bottomNavIndex = 2;
            });
          } else
            onWillPop();
          return Future.value(true);
        },
        child: Scaffold(
          body: Stack(
            children: [
              pages(_bottomNavIndex),
              Align(
                alignment: Alignment.bottomCenter,
                child: CurvedNavigationBar(
                  index: _bottomNavIndex,
                  backgroundColor: Colors.transparent,
                  items: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          iconList[0],
                          size: 30,
                          color: !menu ? Colors.black26 : Colors.white,
                        ),
                        !menu
                            ? Text(
                                translate('lan.home'),
                                style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 14,
                                    fontFamily: 'Tajawal'),
                              )
                            : Container()
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          iconList[1],
                          size: 30,
                          color: !offers ? Colors.black26 : Colors.white,
                        ),
                        !offers
                            ? Text(
                                translate('lan.myPoints'),
                                style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 14,
                                    fontFamily: 'Tajawal'),
                              )
                            : Container()
                      ],
                    ),
                    Icon(
                      Icons.home,
                      size: 35,
                      color: !home ? Colors.black26 : Colors.white,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Badge(
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
                              padding: const EdgeInsets.only(
                                  top: 15.0, left: 2, right: 2),
                              child: Icon(
                                iconList[2],
                                size: 30,
                                color: !profile ? Colors.black26 : Colors.white,
                              ),
                            )),
                        !profile
                            ? Text(
                                translate('lan.orders'),
                                style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 14,
                                    fontFamily: 'Tajawal'),
                              )
                            : Container()
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          iconList[3],
                          size: 30,
                          color: !more ? Colors.black26 : Colors.white,
                        ),
                        !more
                            ? Text(
                                translate('lan.more'),
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 14,
                                  fontFamily: 'Tajawal',
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ],
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        setState(() {
                          menu = true;
                          offers = false;
                          home = false;
                          profile = false;
                          more = false;
                          _bottomNavIndex = 0;
                        });
                        break;

                      case 1:
                        setState(() {
                          menu = false;
                          offers = true;
                          home = false;
                          profile = false;
                          more = false;
                        });
                        if (!isLogin)
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        else
                          setState(() {
                            _bottomNavIndex = 1;
                          });
                        break;
                      case 2:
                        setState(() {
                          menu = false;
                          offers = false;
                          home = true;
                          profile = false;
                          more = false;
                          _bottomNavIndex = 2;
                        });
                        break;
                      case 3:
                        setState(() {
                          menu = false;
                          offers = false;
                          home = false;
                          profile = true;
                          more = false;
                        });
                        if (!isLogin) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        } else
                          setState(() {
                            _bottomNavIndex = 3;
                          });
                        break;
                      case 4:
                        setState(() {
                          menu = false;
                          offers = false;
                          home = false;
                          profile = false;
                          more = true;
                          _bottomNavIndex = 4;
                        });
                        break;
                    }
                  },
                  buttonBackgroundColor: HexColor('#40976c'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Scaffold(
//   body: WillPopScope(
//     onWillPop: (){
//       if(_controller.index!=2){
//         setState(() {
//           widget.isHomeScreen=false;
//           control=false;
//           menu = false;
//           offers = false;
//           home = true;
//           profile = false;
//           more = false;
//           _controller.index=2;
//
//         });
//         widget.isHomeScreen=true;
//       }
//       // if(_controller.index==2)
//       //   setState(() {
//       //     control=true;
//       //   });
//       if(_controller.index==2){
//         Navigator.push(context,
//             MaterialPageRoute(builder: (context)=>HomePage(isHomeScreen: true,)));
//       }
//       if(widget.isHomeScreen==true)
//         print('xxxxxxxxxxxxxxxxxxxxxxx');
//
//
//     },
//     child: PersistentTabView.custom(
//       context,
//       controller: _controller,
//       itemCount: 5,
//       screens: _navScreens(),
//       // items: _navBarsItems(),
//       confineInSafeArea: true,
//       backgroundColor: Colors.transparent,
//       handleAndroidBackButtonPress: false,
//       resizeToAvoidBottomInset: true,
//       stateManagement: true,
//
//
//
//       // navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
//       //     ? 0.0
//       //     : kBottomNavigationBarHeight,
//
//       hideNavigationBarWhenKeyboardShows: true,
//       margin: EdgeInsets.all(0.0),
//       // popActionScreens: PopActionScreensType.all,
//       bottomScreenMargin: 0.0,
//       hideNavigationBar: _hideNavBar,
//       // decoration: NavBarDecoration(
//       //     colorBehindNavBar: Colors.transparent,
//       //     borderRadius: BorderRadius.only(
//       //       topLeft:Radius.circular(10),
//       //       topRight: Radius.circular(10),
//       //     )),
//       // popAllScreensOnTapOfSelectedTab: true,
//       screenTransitionAnimation: ScreenTransitionAnimation(
//         animateTabTransition: true,
//         curve: Curves.easeInCubic,
//         duration: Duration(milliseconds: 200),
//       ),
//       customWidget: CurvedNavigationBar(
//         index: _controller.index,
//         backgroundColor: Colors.transparent,
//         items: <Widget>[
//           Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Icon(
//                 iconList[0],
//                 size: 30,
//                 color: !menu ? Colors.black26 : Colors.white,
//               ),
//               !menu
//                   ? Text(
//                 translate('lan.home'),
//                 style: TextStyle(color: Colors.black26, fontSize: 12),
//               )
//                   : Container()
//             ],
//           ),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Icon(
//                 iconList[1],
//                 size: 30,
//                 color: !offers ? Colors.black26 : Colors.white,
//               ),
//               !offers
//                   ? Text(
//                 translate('lan.myPoints'),
//                 style: TextStyle(color: Colors.black26, fontSize: 12),
//               )
//                   : Container()
//             ],
//           ),
//           Icon(
//             Icons.home,
//             size: 35,
//             color: !home ? Colors.black26 : Colors.white,
//           ),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Icon(
//                 iconList[2],
//                 size: 30,
//                 color: !profile ? Colors.black26 : Colors.white,
//               ),
//               !profile
//                   ? Text(
//                 translate('lan.orders'),
//                 style: TextStyle(color: Colors.black26, fontSize: 12),
//               )
//                   : Container()
//             ],
//           ),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Icon(
//                 iconList[3],
//                 size: 30,
//                 color: !more ? Colors.black26 : Colors.white,
//               ),
//               !more
//                   ? Text(
//                 translate('lan.more'),
//                 style: TextStyle(color: Colors.black26, fontSize: 12),
//               )
//                   : Container()
//             ],
//           ),
//         ],
//
//         onTap: (index) {
//           setState(() {
//             _controller.index = index;
//           });
//           switch (index) {
//             case 0:{
//               setState(() {
//                 menu = true;
//                 offers = false;
//                 home = false;
//                 profile = false;
//                 more = false;
//               });
//
//             }
//             break;
//
//             case 1:{
//               setState(() {
//                 menu = false;
//                 offers = true;
//                 home = false;
//                 profile = false;
//                 more = false;
//               });
//               print(context.toString()+'sklgjdbfkdhb');
//             }
//             break;
//             case 2:
//               setState(() {
//                 menu = false;
//                 offers = false;
//                 home = true;
//                 profile = false;
//                 more = false;
//               });
//               break;
//             case 3:
//               setState(() {
//                 menu = false;
//                 offers = false;
//                 home = false;
//                 profile = true;
//                 more = false;
//               });
//               break;
//             case 4:
//               setState(() {
//                 menu = false;
//                 offers = false;
//                 home = false;
//                 profile = false;
//                 more = true;
//               });
//               break;
//           }
//         },
//         buttonBackgroundColor: HexColor('#40976c'),
//
//       ),
//     ),
//   ),
// );
