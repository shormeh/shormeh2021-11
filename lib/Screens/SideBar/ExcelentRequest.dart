// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_translate/flutter_translate.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class ExcellentRequest extends StatefulWidget {
//   @override
//   ExcellentRequestState createState() => ExcellentRequestState();
// }
//
// class ExcellentRequestState extends State<ExcellentRequest> {
//   @override
//   void initState() {
//     super.initState();
//     // Enable hybrid composition.
//     if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//     _launchURL('https://forms.gle/XSB8ecJX7sjiBFTS9');
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           translate('lan.excelentRequest'),
//           style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Tajawal'),
//         ),
//         backgroundColor: HexColor('#40976c'),
//         elevation: 5.0,
//         leading: InkWell(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Icon(
//             Icons.arrow_back_ios,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: WebView(
//         initialUrl: 'https://forms.gle/XSB8ecJX7sjiBFTS9',
//         javascriptMode: JavascriptMode.unrestricted,
//         onWebResourceError: (WebResourceError webviewerrr) {
//           print("Handle your Error Page here");
//         },
//       ),
//     );
//   }
// }
