import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:shormeh/Screens/Home/HomePage.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  bool isIndicatorActive = true;

  String about = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAboutUs();
  }

  Future getAboutUs() async {
    var response = await http.get(Uri.parse("${HomePage.URL}settings/website"));

    var data = json.decode(response.body);
    print("$data");
    setState(() {
      about = data["about"];
      //فى اللحظة دية كل الصيدليات بكل الاقسام اتحملت
      isIndicatorActive = false;
    });
    //  }
  }

  onBackPressed(BuildContext context) async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPressed(context),
      child: Scaffold(
        appBar: new AppBar(
          backgroundColor: HexColor('#40976c'),
          title: Text(translate('lan.aboutUs')),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () => onBackPressed(context),
          ),
        ),
        body: isIndicatorActive
            ? Center(child: CircularProgressIndicator())
            : Container(
                margin: EdgeInsets.all(MediaQuery.of(context).size.width / 20),
                child: Text(
                  "$about",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 25,
                      fontWeight: FontWeight.normal),
                )),
      ),
    );
  }
}
