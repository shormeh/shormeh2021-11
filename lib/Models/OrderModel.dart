import 'package:shormeh/Models/OrderModel2.dart';

class OrderModel {
  int? id;
  String? uuid;
  String? status;
  String? nameEn;
  String? sub_total;
  String? discount;
  String? tax;
  String? total;
  List<OrderModel2>? items;
  String? vendor;
  int? statusId;
  int? vendorID;

  OrderModel(
      {this.id,
      this.uuid,
      this.status,
      this.nameEn,
      this.sub_total,
      this.discount,
      this.tax,
      this.total,
      this.items,
      this.vendor,
      this.statusId,
      this.vendorID});
}
