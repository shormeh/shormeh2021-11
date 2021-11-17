// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_translate/flutter_translate.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shormeh/Models/PaymentMethodsModel.dart';
// import 'package:http/http.dart' as http;
// import 'package:shormeh/Screens/Card/Card5OdrerStatus.dart';
// import 'package:shormeh/Screens/Home/HomePage.dart';
//
//
// class PaymentMethods extends StatefulWidget {
//   String orderID;
//
//
//   PaymentMethods({
//     Key key,
//     this.orderID,
//   }) : super(key: key);
//   @override
//   _PaymentMethodsState createState() => _PaymentMethodsState();
// }
//
// class _PaymentMethodsState extends State<PaymentMethods> {
//   List<PaymentMethodsModel> allPaymentMethods= new List<PaymentMethodsModel>();
//   bool isIndicatorActive=true;
//
//   String cardToken="";
//   String token="";
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getDataFromSharedPrfs();
//     print("Payment Methods ${widget.orderID}");
//   }
//
//   Future getDataFromSharedPrfs()async{
//     final prefs = await SharedPreferences.getInstance();
//     final _cardToken= prefs.getString("cardToken");
//     final _token= prefs.getString("token");
//     setState((){
//       cardToken=_cardToken;
//       token=_token;
//     });
//
//     print("$cardToken");
//     getPaymentMethods();
//
//   }
//
//   Future getPaymentMethods() async {
//     try{
//       var response = await http.get("${HomePage.URL}cart/payment_method",headers: {
//         "Authorization": "Bearer $token",
//       });
//       var dataMyPaymentMethods = json.decode(response.body);
//
//       setState(() {
//         print("Payment Methods${dataMyPaymentMethods}");
//         for(int i=0;i<dataMyPaymentMethods.length;i++){
//           allPaymentMethods.add(new PaymentMethodsModel(
//             dataMyPaymentMethods[i]['id'],
//             "${dataMyPaymentMethods[i]['title_en']}",
//             "${dataMyPaymentMethods[i]['title_ar']}",
//             "${dataMyPaymentMethods[i]['image']}",
//             "${dataMyPaymentMethods[i]['code']}",
//           ));
//         }
//
//         //فى اللحظة دية كل الصيدليات بكل الاقسام اتحملت
//         isIndicatorActive=false;
//       });
//     }catch(e){
//       print("WWWWW $e");
//     }
//
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(translate('lan.paymentMethods'),),
//         backgroundColor: HexColor('#40976c'),
//         centerTitle: true,
//         elevation: 5.0,
//         leading:IconButton(
//         icon: Icon(Icons.arrow_back_ios,size: MediaQuery.of(context).size.width/15,),
//       onPressed:(){
//         Navigator.pop(context);
//       },
//     ),
//
//       ),
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         color: Colors.white,
//         child:isIndicatorActive?Center(child: CircularProgressIndicator(),):
//         ListView.builder(
//             shrinkWrap : true,
//             physics: ScrollPhysics(),
//             itemCount: allPaymentMethods.length,
//             padding: EdgeInsets.fromLTRB(0.0,MediaQuery.of(context).size.width/50,0.0,MediaQuery.of(context).size.width/50),
//
//             itemBuilder: (BuildContext context, int index) {
//               return InkWell(
//                 onTap: (){
//                   SendPaymentMethode(context,allPaymentMethods[index].code);
//                 },
//                 child: Container(
//                   width: MediaQuery.of(context).size.width/7,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.all(Radius.circular(15)),
//                     color: HomePage.colorGrey,
//
//                   ),
//                   margin: EdgeInsets.all(
//                       MediaQuery.of(context).size.width/20,),
//                   child: Column(
//                     children: [
//                       Container(
//                         child: Image(
//                           image: NetworkImage('${allPaymentMethods[index].image}'),
//                           fit: BoxFit.fill,
//                         ),
//                       ),
//                       SizedBox(height: MediaQuery.of(context).size.width/20,),
//                       Text("${allPaymentMethods[index].title_en}")
//                     ],
//                   ),),
//               );
//             })
//       ),
//     );
//   }
//
//   Future SendPaymentMethode(BuildContext context, String code) async {
//     print("SendPaymentMethode");
//
//       var response = await http.post("${HomePage.URL}cart/add_payment",headers: {
//         "Authorization": "Bearer $token"
//       },body: {
//         "cart_token": cardToken,
//           "payment_type": "$code",
//       });
//       var dataOrder = json.decode(response.body);
//
//       print("$dataOrder");
//
//       if("${dataOrder['success']}"=="1"){
//         confirm();
//       }
//
//
//   }
//
//   void confirm() async{
//     var response = await http.post("${HomePage.URL}cart/confirm",headers: {
//       "Authorization": "Bearer $token"
//     },body: {
//       'cart_token':'$cardToken',
//     });
//     var dataOrderAfterCoupon = json.decode(response.body);
//     setPrfs("${dataOrderAfterCoupon['order']['id']}");
//   }
//
//   setPrfs(String id)async{
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("cardToken","");
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => OrderStatus(orderID: id)),
//     );
//
//   }
//
//   void displayToastMessage(var toastMessage) {
//     Fluttertoast.showToast(
//         msg: toastMessage.toString(),
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         textColor: Colors.white,
//         fontSize: 16.0);
//   }
// }
