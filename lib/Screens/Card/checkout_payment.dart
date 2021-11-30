// import 'package:flutter/material.dart';
// import 'package:flutter_translate/flutter_translate.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shormeh/Screens/Card/payment_form.dart';
// import 'package:shormeh/Screens/Home/HomePage.dart';
//
// class CheckoutPayment extends StatefulWidget {
//   String? price;
//   String? cart_token;
//   String? language;
//   String? token;
//   CheckoutPayment({this.price, this.cart_token, this.language, this.token});
//   @override
//   _CheckoutPaymentState createState() => _CheckoutPaymentState();
// }
//
// class _CheckoutPaymentState extends State<CheckoutPayment> {
//   bool loading = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 widget.price! + ' ' + translate('lan.rs'),
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
//               ),
//               SizedBox(
//                 height: 40,
//               ),
//               InkWell(
//                 onTap: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => payment_form()));
//                 },
//                 child: Container(
//                   height: 70,
//                   width: MediaQuery.of(context).size.width * 0.85,
//                   decoration: BoxDecoration(
//                     color: HomePage.colorGreen,
//                     borderRadius: BorderRadius.all(Radius.circular(20)),
//                   ),
//                   child: Center(
//                       child: Text(
//                     translate('lan.submitPayment'),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 25,
//                     ),
//                   )),
//                 ),
//               )
//             ],
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
//   // getCheckoutId() async {
//   //   setState(() {
//   //     loading = true;
//   //   });
//   //   var response =
//   //       await http.post(Uri.parse("${HomePage.URL}cart/add_payment"), headers: {
//   //     "Authorization": "Bearer ${widget.token}",
//   //     "Content-Language": widget.language!,
//   //   }, body: {
//   //     "cart_token": widget.cart_token,
//   //     "payment_type": "card",
//   //   });
//   //   var data = json.decode(response.body);
//   //   print(data);
//   //
//   //   if (data['result']['description'] == 'successfully created checkout') {
//   //     setState(() {
//   //       loading = false;
//   //     });
//   //     // Navigator.push(
//   //     //     context,
//   //     //     MaterialPageRoute(
//   //     //         builder: (context) => payment_form(checkoutId: data['id'])));
//   //   }
//   // }
// }
