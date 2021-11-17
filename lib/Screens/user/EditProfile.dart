// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:market/main.dart';
// import 'package:market/screens/home.dart';
// import 'package:market/screens/user/ResetPassword.dart';
// import 'package:market/screens/user/login.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:image/image.dart' as Img;
// import 'package:http/http.dart' as http;
//
// class EditProfile extends StatefulWidget {
//   @override
//   _EditProfileState createState() => _EditProfileState();
// }
//
// class _EditProfileState extends State<EditProfile> {
//
//
//   bool enable=true;
//   bool circularIndicatorActive=false;
//   static GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   //الاسم 1
//   final nameCtrl = TextEditingController();
//
//   //الايميل 2
//   final emailCtrl = TextEditingController();
//
//   //الموبايل 3
//   final phoneCtrl = TextEditingController();
//
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     setUserData();
//   }
//   void setUserData() {
//     nameCtrl.text=HomePage.name;
//     emailCtrl.text=HomePage.email;
//     phoneCtrl.text=HomePage.phone;
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: new Text(
//           'تعديل بياناتى',
//           style: TextStyle(color: Colors.black),
//         ),
//         iconTheme: IconThemeData(
//           color: Colors.black, //change your color here
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//       ),
//       body: circularIndicatorActive
//           ? Center(
//         child: CircularProgressIndicator(),
//       ): Form(
//         key: formKey,
//         child: Container(
//           padding: EdgeInsets.all(MediaQuery.of(context).size.width/30),
//           child: ListView(
//             children: <Widget>[
//               // Logo Image
//               new Container(
//                 width:  MediaQuery.of(context).size.width/2,
//                 height:  MediaQuery.of(context).size.width/2,
//                 decoration: new BoxDecoration(
//                   image: new DecorationImage(
//                     image: AssetImage('assets/images/logo.png'),
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ),
//               //الاسم
//               new TextFormField(
//                 controller: nameCtrl,
//                 style: TextStyle(fontSize: MediaQuery.of(context).size.width/25),
//                 textInputAction: TextInputAction.done,
//                 decoration: new InputDecoration(
//                   icon: Icon(
//                     Icons.person,
//                     color: HomePage.colorIcon,
//                   ),
//                   enabledBorder: new UnderlineInputBorder(
//                       borderSide:
//                       new BorderSide(color: HomePage.colorHintAndUnderline)),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: HomePage.colorHintAndUnderline),
//                   ),
//                   labelStyle: new TextStyle(color: HomePage.colorHintAndUnderline),
//                   labelText:"الاسم",
//                   hintText: "الاسم",
//                 ),
//                 cursorColor: HomePage.colorHintAndUnderline,
//
//               ),
//
//               new TextFormField(
//                 controller: emailCtrl,
//                 keyboardType: TextInputType.emailAddress,
//                 style: TextStyle(fontSize: MediaQuery.of(context).size.width/25,fontFamily:'Cairo'),
//                 decoration: new InputDecoration(
//                   icon: Icon(
//                     Icons.email,
//                     color: HomePage.colorIcon,
//                   ),
//                   hintText: "البريد الالكترونى",
//                   labelText: "البريد الالكترونى",
//                   enabledBorder: new UnderlineInputBorder(
//                       borderSide:
//                       new BorderSide(color: HomePage.colorHintAndUnderline)),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: HomePage.colorHintAndUnderline),
//                   ),
//                   labelStyle: new TextStyle(color: HomePage.colorHintAndUnderline),
//                 ),
//                 cursorColor: HomePage.colorHintAndUnderline,
//
//               ),
//               //Phone
//               new TextFormField(
//                 controller: phoneCtrl,
//                 keyboardType: TextInputType.phone,
//                 style: TextStyle(fontSize: MediaQuery.of(context).size.width/25,fontFamily:'Cairo'),
//                 decoration: new InputDecoration(
//                   icon: Icon(
//                     Icons.phone,
//                     color: HomePage.colorIcon,
//                   ),
//                   enabledBorder: new UnderlineInputBorder(
//                       borderSide:
//                       new BorderSide(color: HomePage.colorHintAndUnderline)),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: HomePage.colorHintAndUnderline),
//                   ),
//                   labelStyle: new TextStyle(color: HomePage.colorHintAndUnderline),
//                   hintText: "رقم الموبايل",
//                   labelText: "رقم الموبايل",
//                 ),
//                 cursorColor: HomePage.colorHintAndUnderline,
//               ),
//
//               //تعديل كلمة المرور وحفظ
//               SizedBox(height: MediaQuery.of(context).size.width/10,),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   ButtonTheme(
//                     shape: new RoundedRectangleBorder(
//                         borderRadius: new BorderRadius.circular(10.0)),
//                     minWidth: 10.0,
//                     height: MediaQuery.of(context).size.width/7,
//                     child: RaisedButton(
//                       child: Text(
//                           "تعديل كلمة المرور",
//                           style:TextStyle(fontSize: MediaQuery.of(context).size.width/20,color: Colors.white)
//
//                       ),
//                       color:   HomePage.colorGreen,
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => ResetPassword(),
//                             ));
//                       },
//                     ),
//                   ),
//                   SizedBox(width: MediaQuery.of(context).size.width/10),
//                   ButtonTheme(
//                     shape: new RoundedRectangleBorder(
//                         borderRadius: new BorderRadius.circular(10.0)),
//                     minWidth: 10.0,
//                     height: MediaQuery.of(context).size.width/7,
//                     child: RaisedButton(
//                       child: Text(
//                           "حفظ",
//                           style:TextStyle(fontSize: MediaQuery.of(context).size.width/20,color: Colors.white)
//
//                       ),
//                       color: HomePage.colorGreen,
//                       onPressed: () {
//                         if(enable){
//                           SendDataToServer(context);
//                         }else{
//                           displayToastMessage("الرجاء الانتظار يتم الان تعديل بيناتك");
//
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: MediaQuery.of(context).size.width/20,),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future SendDataToServer(BuildContext context) async {
//        setState(() {
//           enable=false;
//       });
//
//
//          var response = await http.post("${HomePage.URL}user_api/edit_profile",body: {
//            "key": "1234567890",
//            "token_id": HomePage.token,
//            "name": "${nameCtrl.text}",
//            "phone": phoneCtrl.text,
//            "email": emailCtrl.text,
//          });
//          var datauser = json.decode(response.body);
//          if (datauser['status']) {
//            setState(() {
//              enable=true;
//            });
//            displayToastMessage(datauser['message']);
//            HomePage.name="${datauser['result']['customer_info']['name']}";
//            HomePage.email="${datauser['result']['customer_info']['email'].toString()}";
//            HomePage.phone="${datauser['result']['customer_info']['phone'].toString()}";
//
//            Navigator.of(context)
//                .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
//
//          } else {
//            setState(() {
//              enable=true;
//            });
//            displayToastMessage(datauser['message'].toString());
//          }
//
//
//   }
//
//   void displayToastMessage(var toastMessage) {
//     Fluttertoast.showToast(
//         msg: toastMessage.toString(),
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIos: 1,
//         backgroundColor: HomePage.colorGreen,
//         textColor: Colors.white,
//         fontSize: 16.0
//     );
//     // _goToHome();
//   }
//
//
//
// }
