// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// import 'package:http/http.dart' as http;
// import 'package:shormeh/Screens/Home/HomePage.dart';
// import 'package:shormeh/Screens/SelectBrabche.dart';
//
// import 'login.dart';
//
// class VerifyPhone extends StatefulWidget {
//   @override
//   _VerifyPhoneState createState() => _VerifyPhoneState();
// }
//
// class _VerifyPhoneState extends State<VerifyPhone> {
//   bool enable=true;
//   bool circularIndicatorActive=false;
//
//
//   final phoneCtrl = TextEditingController();
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//
//   }
//
//   onBackPressed(BuildContext context) {
//     Navigator.of(context).pop();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: ()=>onBackPressed(context),
//         child:Scaffold(
//           appBar: PreferredSize(
//               preferredSize: Size.fromHeight(0.0), // here the desired height
//               child: AppBar(
//               )
//           ),
//           body: new Container(
//               decoration: new BoxDecoration(
//                 image: new DecorationImage(
//                   image: AssetImage('assets/images/loginBackground.png'),
//                   fit: BoxFit.fill,
//                 ),
//               ),
//               child: new Column(children: <Widget>[
//                 //Logo Image
//                 SizedBox(height: MediaQuery.of(context).size.height/20,),
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(width: MediaQuery.of(context).size.width/10,),
//                       Container(
//                         alignment: Alignment.center,
//                         child: InkWell(
//                           onTap:(){
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (context) => SelectBranche()),
//                             );
//                           },
//                           child: Container(
//                               alignment: Alignment.center,
//                               width: MediaQuery.of(context).size.width/8,
//                               height: MediaQuery.of(context).size.width/8,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(30.0),
//                                 ),
//                                 color: HomePage.colorYellow,
//                                 boxShadow: [
//                                   //BoxShadow(color: HomePage.colorBlue, spreadRadius: 1.5),
//                                 ],
//                               ),
//                               child: Icon(Icons.arrow_back,color: Colors.white,size: MediaQuery.of(context).size.width/15,)
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: MediaQuery.of(context).size.width/15,),
//                       Container(
//                         alignment: Alignment.centerLeft,
//                         child: Text("Forget Password",
//                             style:TextStyle(fontSize:  MediaQuery.of(context).size.width/18,
//                               color: Colors.white,fontWeight: FontWeight.bold,
//                             )
//                         ),),
//                       Expanded(child: Container()),
//
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height/10,),
//
//
//                 Container(
//                   width: MediaQuery.of(context).size.width/3,
//                   height: MediaQuery.of(context).size.width/3,
//                   decoration: new BoxDecoration(
//                     image: new DecorationImage(
//                       image: AssetImage('assets/images/logo.png'),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.width/15),
//
//                 //الموبايل
//                 Container(
//                   padding: new EdgeInsets.only(left: MediaQuery.of(context).size.width/15, right: MediaQuery.of(context).size.width/15),
//
//                   child: TextFormField(
//                     enabled: enable,
//                     controller: phoneCtrl,
//                     keyboardType: TextInputType.phone,
//
//                     decoration: new InputDecoration(
//                       icon:Icon(Icons.phone),
//                       enabledBorder: new UnderlineInputBorder(
//                           borderSide:
//                           new BorderSide(color: HomePage.colorGrey)),
//                       focusedBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(color: HomePage.colorGrey),
//                       ),
//                       labelStyle: new TextStyle(color: HomePage.colorGrey),
//                       hintText: "Phone Number",
//                       labelText: "Phone Number",
//
//                     ),
//                     cursorColor: HomePage.colorGrey,
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.width/20),
//
//                 //Submit
//                 Container(
//                   margin: new EdgeInsets.only(left: MediaQuery.of(context).size.width/15, right: MediaQuery.of(context).size.width/15),
//                   child: ButtonTheme(
//                     shape: new RoundedRectangleBorder(
//                         borderRadius: new BorderRadius.circular(10.0)),
//                     minWidth: 500.0,
//                     height: MediaQuery.of(context).size.width/8,
//                     child: RaisedButton(
//                       child: Text(
//                           "Send",
//                           style:TextStyle(fontSize:  MediaQuery.of(context).size.width/20,color: Colors.white)
//                       ),
//                       color: HomePage.colorGreen,
//                       onPressed: () {
//                         if(enable){
//                           //getFirebaseToken();
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: new EdgeInsets.only(top:  MediaQuery.of(context).size.width/20),
//                 ),
//
//               ])),
//         )
//     );
//   }
//
//   Future SendDataToServer(BuildContext context) async {
//
//
//     setState(() {
//       enable=false;
//     });
//     var response = await http.post("${HomePage.URL}user_api/register",body: {
//       "key": "1234567890",
//       "phone": phoneCtrl.text,
//
//     });
//     var datauser = json.decode(response.body);
//     if (datauser['status']) {
//       setState(() {
//         enable=true;
//       });
//       displayToastMessage(datauser['message']);
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(builder: (context) => Login(fromMyAccount: false,)),
//       // );
//     } else {
//       setState(() {
//         enable=true;
//       });
//       displayToastMessage(datauser['message'].toString());
//     }
//
//
//   }
//
//   void displayToastMessage(var toastMessage) {
//     Fluttertoast.showToast(
//         msg: toastMessage.toString(),
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 3,
//         textColor: Colors.white,
//         fontSize: 16.0
//     );
//     // _goToHome();
//   }
//
// }
