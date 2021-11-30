class Card1Model {
  int id;
  int subTotal;
  String tax;
  String total;
  String delivery_fee;
  String points_to_cash;
  String discount;
  List<String>? addOn;
  String? option;
  String? notes;
  int productId;
  String productName;
  String productImage;
  String productPrice;
  int count;
  bool isSelected;
  int? liked;
  String? drinkTitle;
  String? drinkID;

  Card1Model(
      this.id,
      this.subTotal,
      this.tax,
      this.total,
      this.delivery_fee,
      this.points_to_cash,
      this.discount,
      this.productId,
      this.productName,
      this.productImage,
      this.productPrice,
      this.count,
      this.isSelected,
      {this.addOn,
      this.option,
      this.notes,
      this.liked,
      this.drinkTitle,
      this.drinkID});
}
