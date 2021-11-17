

class ProductsModel{
  int id;
  String image;
  String mainName;
  String price;
  int liked;



  ProductsModel(this.id, this.image,this.mainName,this.price,this.liked);


  factory ProductsModel.fromJson(Map<String, dynamic> json) => ProductsModel(
    json['id'],
    json["image_one"],
    json["name"],
    json["price"],
    json["in_favourite"]

  );
}


