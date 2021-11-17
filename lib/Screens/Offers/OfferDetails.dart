import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shormeh/Screens/Home/HomePage.dart';

class OfferDetails extends StatefulWidget {
  int? id;
  String? description;
  String? image;

  OfferDetails({
    this.id,
    this.description,
    this.image,
  });

  @override
  _OfferDetailsState createState() => _OfferDetailsState();
}

class _OfferDetailsState extends State<OfferDetails> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: HexColor('#40976c'),
        title: Text(
          translate('lan.offerDetails'),
        ),
        elevation: 5.0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width / 30,
              MediaQuery.of(context).size.width / 50,
              MediaQuery.of(context).size.width / 30,
              MediaQuery.of(context).size.width / 50,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: HomePage.colorGreen, spreadRadius: 0.0),
              ],
            ),
            child: widget.image == ''
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 4.5,
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.fill,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 4.5,
                      image: NetworkImage(widget.image!),
                      fit: BoxFit.fill,
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
            child: Text(
              "${widget.description}",
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width / 30),
            ),
          ),
        ],
      ),
    );
  }

  onBackPressed(BuildContext context) {}

  goToHome(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }
}
