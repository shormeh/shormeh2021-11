// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
//
//
// class ExcelentRequest extends StatefulWidget {
//   @override
//   _ExcelentRequestState createState() => _ExcelentRequestState();
// }
//
// class _ExcelentRequestState extends State<ExcelentRequest> {
//   final Completer<WebViewController> _controller =
//   Completer<WebViewController>();
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         child:
//         WebView(
//           initialUrl: 'https://docs.google.com/forms/d/17_03jn8Km-Ko0ELu2DnNHtqco3HvSodh3tVyVdUp7uM/prefill',
//           javascriptMode: JavascriptMode.unrestricted,
//           onWebViewCreated: (WebViewController webViewController) {
//             _controller.complete(webViewController);
//           },
//           javascriptChannels: <JavascriptChannel>[
//             _toasterJavascriptChannel(context),
//           ].toSet(),
//           navigationDelegate: (NavigationRequest request) {
//             if (request.url.startsWith('https://www.youtube.com/')) {
//               print('blocking navigation to $request}');
//               return NavigationDecision.prevent;
//             }
//             print('allowing navigation to $request');
//             return NavigationDecision.navigate;
//           },
//           onPageStarted: (String url) {
//             print('Page started loading: $url');
//           },
//           onPageFinished: (String url) {
//             setState(() {
//              // isWebLoaded=true;
//             });
//             print('Page finished loading: $url');
//           },
//           gestureNavigationEnabled: true,
//
//         ),
//       ),
//     );
//   }
//   JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
//     return JavascriptChannel(
//         name: 'Toaster',
//         onMessageReceived: (JavascriptMessage message) {
//           // ignore: deprecated_member_use
//           Scaffold.of(context).showSnackBar(
//             SnackBar(content: Text(message.message)),
//           );
//         });
//   }
// }
