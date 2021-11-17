import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Screens/Card/Card6TaqeemElkhdma.dart';
import 'package:shormeh/Screens/Cats/1Categories.dart';
import 'package:shormeh/Screens/Home/getLocation.dart';
import 'package:shormeh/Screens/SelectBrabche.dart';

import 'Screens/Card/Card2MyAllProductsDetails.dart';
import 'Screens/Card/Card5OdrerStatus.dart';
import 'Screens/Home/HomePage.dart';
import 'Screens/Splash.dart';

void main() async {
  HttpOverrides.global = new MyHttpOverrides();
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'ar', supportedLocales: ['en', 'ar']);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  // runApp(Phoenix(child: MyApp()));
  runApp(LocalizedApp(delegate, MyApp()));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  int _translateLanguage = 0;
  bool? gotLocation;
  bool? gotBranch;
  Locale? _locale;
  String lan = 'en';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getDataFromSharedPref();
  }

  Future<void> _getDataFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();

    final _gotLocation = prefs.getBool('getLocation');
    final _branchSelected = prefs.getBool('branchSelected');
    setState(() {
      gotLocation = _gotLocation;
      gotBranch = _branchSelected;
    });
    _translateLanguage = prefs.getInt('translateLanguage') ?? 0;
    prefs.setInt('translateLanguage', _translateLanguage);
    setState(() {
      _translateLanguage == 0 ? lan = 'en' : lan = 'ar';
    });

    print(_translateLanguage);
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  Widget getHome() {
    if (gotLocation == null)
      return GetLocation();
    else if (gotLocation != null && gotBranch == null)
      return SelectBranche();
    else if (gotBranch!)
      return HomePage();
    else
      return Container();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    var localizationDelegate = LocalizedApp.of(context).delegate;
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 2)),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LocalizationProvider(
              state: LocalizationProvider.of(context).state,
              child: OverlaySupport.global(
                child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(
                      primaryColor: HomePage.colorGreen,
                      accentColor: HomePage.colorGreen,
                      cursorColor: HomePage.colorGreen,
                      fontFamily: 'Tajawal',
                      //primarySwatch: HomePage.colorBlue,
                    ),
                    routes: <String, WidgetBuilder>{
                      '/home': (BuildContext context) => new HomePage(),
                      '/orderMethod': (BuildContext c) => new Card2(),
                      '/message': (BuildContext context) => new OrderStatus(),
                      '/taqeem': (BuildContext context) =>
                          new Card6TaqeemElkhdma(),
                      '/selectBranche': (BuildContext context) =>
                          new SelectBranche(),
                      '/myApp': (BuildContext context) => new MyApp(),
                    },
                    localizationsDelegates: [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      localizationDelegate
                    ],
                    localeResolutionCallback: (locale, supportedLocales) {
                      for (var supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode ==
                                locale!.languageCode &&
                            supportedLocale.countryCode == locale.countryCode) {
                          return supportedLocale;
                        }
                      }
                      return supportedLocales.first;
                    },
                    supportedLocales: localizationDelegate.supportedLocales,
                    locale: _locale ?? Locale(lan),
                    // supportedLocales: [Locale('en'),Locale('ar')],
                    //  //
                    //   locale: _locale,
                    home: Splash()),
              ));
        } else {
          // Loading is done, return the app:
          return LocalizationProvider(
              state: LocalizationProvider.of(context).state,
              child: OverlaySupport.global(
                  child: MaterialApp(
                title: 'شورمية',
                routes: <String, WidgetBuilder>{
                  '/home': (BuildContext context) => new HomePage(),
                  '/orderMethod': (BuildContext c) => new Card2(),
                  '/message': (BuildContext context) => new OrderStatus(),
                  '/taqeem': (BuildContext context) => new Card6TaqeemElkhdma(),
                  '/selectBranche': (BuildContext context) =>
                      new SelectBranche(),
                  '/myApp': (BuildContext context) => new MyApp(),
                  '/categories': (BuildContext context) => new HomeScreen(),
                },
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  localizationDelegate
                ],
                supportedLocales: localizationDelegate.supportedLocales,
                locale: _locale ?? Locale(lan),
                home: getHome(),
                debugShowCheckedModeBanner: false,
                localeResolutionCallback: (locale, supportedLocales) {
                  for (var supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale!.languageCode &&
                        supportedLocale.countryCode == locale.countryCode) {
                      return supportedLocale;
                    }
                  }
                  return supportedLocales.first;
                },
                theme: ThemeData(
                  primaryColor: HomePage.colorGreen,
                  accentColor: HomePage.colorGreen,
                  cursorColor: HomePage.colorGreen,
                  fontFamily: 'Tajawal',
                  //primarySwatch: HomePage.colorBlue,
                ),
              )));
        }
      },
    );
  }
}
