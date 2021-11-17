import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class ConditionsAndRules extends StatefulWidget {
  @override
  _ConditionsAndRulesState createState() => _ConditionsAndRulesState();
}

class _ConditionsAndRulesState extends State<ConditionsAndRules> {
  Color colorGreen = Color(0xff119546);
  onBackPressed(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  String? terms;
  bool circularIndicatorActive = true;
  bool loading = false;
  int lan = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrfs();
    getTerms();
  }

  Future getDataFromSharedPrfs() async {
    final prefs = await SharedPreferences.getInstance();
    int lan1 = prefs.getInt('translateLanguage')!;
    setState(() {
      lan = lan1;
    });
  }

  Future getTerms() async {
    setState(() {
      loading = true;
    });
    var response = await http.get(Uri.parse("${HomePage.URL}terms"));
    setState(() {
      terms = response.body.toString();
      loading = false;
    });
  }

  void displayToastMessage(var toastMessage) {
    Fluttertoast.showToast(
        msg: toastMessage.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: colorGreen,
        textColor: Colors.white,
        fontSize: 16.0);
    // _goToHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            translate('lan.terms'),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: HexColor('#40976c'),
          elevation: 5.0,
        ),
        body: loading
            ? Center(
                child: Container(
                height: 100,
                width: 100,
                child: Lottie.asset('assets/images/lf20_mvihowzk.json'),
              ))
            : Row(
                mainAxisAlignment:
                    lan == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: SingleChildScrollView(
                      child: Html(
                        data: terms,
                      ),
                    ),
                  ),
                ],
              ));
  }
}
