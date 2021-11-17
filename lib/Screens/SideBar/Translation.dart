import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

import '../../main.dart';


class Translate extends StatefulWidget {
  @override
  _TranslateState createState() => _TranslateState();
}

class _TranslateState extends State<Translate> {

  int translateLanguage=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPref();
  }
  Future<void> getDataFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final _translateLanguage = prefs.getInt('translateLanguage');
    if(_translateLanguage==null){
      await prefs.setInt('translateLanguage',0);
    }else{
      setState(() {
        translateLanguage=_translateLanguage;
      });
    }

  }

  serTranslateLanguage()async{
    final prefs = await SharedPreferences.getInstance();

    if(translateLanguage==0){
      await prefs.setInt('translateLanguage',1);
      setState(() {
        translateLanguage=1;
        MyApp.setLocale(context, Locale('ar'));
      });
    }else{

      await prefs.setInt('translateLanguage',0);
      setState(() {
        translateLanguage=0;
        MyApp.setLocale(context, Locale('en'));
      });
    }
  }

  onBackPressed(BuildContext context) {Navigator.of(context).pop();}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor:  HexColor('#40976c'),
        centerTitle: true,
        title: Text(translate('lan.language')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed:()=>onBackPressed(context),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.width/10),
        child: ListView(
          children: [

            // Arabic
            InkWell(
              onTap:(){
                serTranslateLanguage();
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/30,MediaQuery.of(context).size.width/50,MediaQuery.of(context).size.width/30,MediaQuery.of(context).size.width/50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("عربى",style: TextStyle(fontSize: MediaQuery.of(context).size.width/22.5),),
                    Expanded(child: Container()),
                    SizedBox(width: MediaQuery.of(context).size.width/30,),
                    Visibility(
                        visible: translateLanguage==1?true:false,
                        child: Container(child: Icon(Icons.done,size: MediaQuery.of(context).size.width/15,color: HomePage.colorGreen),padding: EdgeInsets.only(top:MediaQuery.of(context).size.width/50),))
                  ],),
              ),
            ),
            Divider(),
            // English
            InkWell(
              onTap:(){
                serTranslateLanguage();
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/30,MediaQuery.of(context).size.width/50,MediaQuery.of(context).size.width/30,MediaQuery.of(context).size.width/50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("English",style: TextStyle(fontSize: MediaQuery.of(context).size.width/22.5),),
                    Expanded(child: Container()),
                    SizedBox(width: MediaQuery.of(context).size.width/30,),
                    Visibility(
                        visible: translateLanguage==0?true:false,
                        child: Container(child: Icon(Icons.done,size: MediaQuery.of(context).size.width/15,color: HomePage.colorGreen),padding: EdgeInsets.only(top:MediaQuery.of(context).size.width/50),))
                  ],),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
