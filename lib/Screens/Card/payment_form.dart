// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_translate/flutter_translate.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shormeh/Screens/Home/HomePage.dart';
//
// class payment_form extends StatefulWidget {
//   @override
//   _payment_formState createState() => _payment_formState();
// }
//
// class _payment_formState extends State<payment_form> {
//   final _cardNumberText = TextEditingController();
//   final _cardHolderText = TextEditingController();
//   final _expiryMonthText = TextEditingController();
//   final _expiryYearText = TextEditingController();
//   final _CVVText = TextEditingController();
//   final _STCPAYText = TextEditingController();
//
//   String _text = "";
//
//   // String type = "";
//
//   bool visa = false;
//   bool master = false;
//   bool mada = false;
//   bool apple = false;
//   String type = 'credit';
//   final _formKey = GlobalKey<FormState>();
//   bool loading = false;
//
//   @override
//   void dispose() async {
//     // Clean up the controller when the widget is disposed.
//     _cardNumberText.dispose();
//     _cardHolderText.dispose();
//     _expiryMonthText.dispose();
//     _expiryYearText.dispose();
//     _CVVText.dispose();
//     _STCPAYText.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: HomePage.colorGreen,
//         title: Text(translate('lan.paymentData')),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: SingleChildScrollView(
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       translate('lan.choosePayment'),
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 10),
//                     Row(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             setState(() {
//                               visa = false;
//                               master = true;
//                               mada = false;
//                               apple = false;
//                               type = 'credit';
//                             });
//                           },
//                           child: Card(
//                             color: master ? Colors.white : HexColor('#DCDCDC'),
//                             elevation: 3,
//                             child: Container(
//                               height: 60,
//                               width: 80,
//                               child: Image.asset(
//                                   'assets/images/1156750_finance_mastercard_payment_icon.png'),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 5,
//                         ),
//                         InkWell(
//                           onTap: () {
//                             setState(() {
//                               visa = true;
//                               master = false;
//                               mada = false;
//                               apple = false;
//                             });
//                           },
//                           child: Card(
//                             color: visa ? Colors.white : HexColor('#DCDCDC'),
//                             elevation: 3,
//                             child: Container(
//                               height: 60,
//                               width: 80,
//                               child: Image.asset('assets/images/visa.png'),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 5,
//                         ),
//                         InkWell(
//                           onTap: () {
//                             setState(() {
//                               visa = false;
//                               master = false;
//                               mada = true;
//                               apple = false;
//                               type = 'mada';
//                             });
//                           },
//                           child: Card(
//                             color: mada ? Colors.white : HexColor('#DCDCDC'),
//                             elevation: 3,
//                             child: Container(
//                               height: 60,
//                               width: 80,
//                               child:
//                                   SvgPicture.asset('assets/images/Mada-01.svg'),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 5,
//                         ),
//                         InkWell(
//                           onTap: () {
//                             setState(() {
//                               visa = false;
//                               master = false;
//                               mada = false;
//                               apple = true;
//                               type = 'APPLEPAY';
//                             });
//                           },
//                           child: Card(
//                             color: apple ? Colors.white : HexColor('#DCDCDC'),
//                             elevation: 3,
//                             child: Container(
//                               height: 60,
//                               width: 80,
//                               child: Center(
//                                 child: FaIcon(
//                                   FontAwesomeIcons.applePay,
//                                   size: 40,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     TextFormField(
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: HomePage.colorGreen,
//                           ),
//                         ),
//                         labelStyle: TextStyle(color: HomePage.colorGreen),
//                         labelText: 'Card Number',
//                         counter: Offstage(),
//                       ),
//                       controller: _cardNumberText,
//                       cursorColor: HomePage.colorGreen,
//                       maxLength: 16,
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return translate('lan.fieldRequired');
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 10),
//                     TextFormField(
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: HomePage.colorGreen,
//                           ),
//                         ),
//                         labelStyle: TextStyle(color: HomePage.colorGreen),
//                         labelText: 'Holder Name',
//                         counter: Offstage(),
//                       ),
//                       cursorColor: HomePage.colorGreen,
//                       controller: _cardHolderText,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return translate('lan.fieldRequired');
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 10),
//                     Row(
//                       children: <Widget>[
//                         Expanded(
//                           child: TextFormField(
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: HomePage.colorGreen,
//                                 ),
//                               ),
//                               labelStyle: TextStyle(color: HomePage.colorGreen),
//                               labelText: 'Expiry Month',
//                               counter: Offstage(),
//                             ),
//                             cursorColor: HomePage.colorGreen,
//                             controller: _expiryMonthText,
//                             keyboardType: TextInputType.number,
//                             maxLength: 2,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return translate('lan.fieldRequired');
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         Expanded(
//                           child: TextFormField(
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: HomePage.colorGreen,
//                                 ),
//                               ),
//                               labelStyle: TextStyle(color: HomePage.colorGreen),
//                               labelText: 'Expiry Year',
//                               hintText: "ex : 2027",
//                               counter: Offstage(),
//                             ),
//                             cursorColor: HomePage.colorGreen,
//                             controller: _expiryYearText,
//                             keyboardType: TextInputType.number,
//                             maxLength: 4,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return translate('lan.fieldRequired');
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10),
//                     TextFormField(
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: HomePage.colorGreen,
//                           ),
//                         ),
//                         labelStyle: TextStyle(color: HomePage.colorGreen),
//                         labelText: 'CVV',
//                         counter: Offstage(),
//                       ),
//                       cursorColor: HomePage.colorGreen,
//                       controller: _CVVText,
//                       keyboardType: TextInputType.number,
//                       maxLength: 3,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return translate('lan.fieldRequired');
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 30),
//                     Center(
//                       child: InkWell(
//                         onTap: () {},
//                         child: Container(
//                           height: 50,
//                           width: 200,
//                           decoration: BoxDecoration(
//                               color: HomePage.colorGreen,
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(20))),
//                           child: Center(
//                             child: Text(
//                               translate('lan.pay1'),
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 20),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // RaisedButton(
//                     //   child: Text('PAY'),
//                     //   onPressed: _pay,
//                     //   padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
//                     // ),
//                     SizedBox(height: 10),
//                     // if (Platform.isIOS)
//                     //   RaisedButton(
//                     //     child: Text('APPLEPAY'),
//                     //     onPressed: _APPLEpay,
//                     //     padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
//                     //     color: Colors.black,
//                     //     textColor: Colors.white,
//                     //   ),
//
//                     // SizedBox(height: 15),
//                     // TextFormField(
//                     //   decoration: InputDecoration(
//                     //     border: OutlineInputBorder(),
//                     //     labelText: 'STCPAY Number',
//                     //     hintText: "05xxxxxxxx",
//                     //     counter: Offstage(),
//                     //   ),
//                     //   controller: _STCPAYText,
//                     //   keyboardType: TextInputType.number,
//                     //   maxLength: 10,
//                     // ),
//                     // RaisedButton(
//                     //   child: Text('STCPAY'),
//                     //   onPressed: _STCPAYpay,
//                     //   padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
//                     // ),
//                     // SizedBox(height: 35),
//                     // Text(
//                     //   _resultText,
//                     //   style: TextStyle(color: Colors.green, fontSize: 20),
//                     // ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           loading
//               ? Container(
//                   height: double.infinity,
//                   width: double.infinity,
//                   color: Colors.white.withOpacity(0.6),
//                   child: Center(
//                     child: Container(
//                       height: 100,
//                       width: 100,
//                       child: Lottie.asset(
//                         'assets/images/lf20_mvihowzk.json',
//                         fit: BoxFit.fill,
//                         height: 100,
//                         width: 100,
//                       ),
//                     ),
//                   ),
//                 )
//               : Container()
//         ],
//       ),
//     );
//   }
//
//   void _showDialog() {
//     // flutter defined function
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         // return object of type Dialog
//         return AlertDialog(
//           title: new Text("Alert!"),
//           content: new Text("Please fill all fields"),
//           actions: <Widget>[
//             // usually buttons at the bottom of the dialog
//             new FlatButton(
//               child: new Text("Close"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
