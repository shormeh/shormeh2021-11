// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class Ready_UI extends StatefulWidget {
//   @override
//   _Ready_UIState createState() => _Ready_UIState();
// }
//
// String _checkoutid = '';
// String _resultText = '';
//
// class _Ready_UIState extends State<Ready_UI> {
//   static const platform = const MethodChannel('Hyperpay.demo.fultter/channel');
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('READY UI'),
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Center(
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   RaisedButton(
//                     child: Text('Credit Card'),
//                     onPressed: () {},
//                     padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
//                   ),
//                   SizedBox(height: 15),
//                   RaisedButton(
//                     child: Text('Mada'),
//                     onPressed: () {},
//                     padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
//                   ),
//                   SizedBox(
//                     height: 15,
//                   ),
//                   if (Platform.isIOS)
//                     RaisedButton(
//                       child: Text('APPLEPAY'),
//                       onPressed: () {},
//                       padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
//                       color: Colors.black,
//                       textColor: Colors.white,
//                     ),
//                   SizedBox(height: 35),
//                   Text(
//                     _resultText,
//                     style: TextStyle(color: Colors.green, fontSize: 20),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
