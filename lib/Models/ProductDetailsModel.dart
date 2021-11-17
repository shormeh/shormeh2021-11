class ProductDetailsModel {
  int id;
  String image;
  String mainName;
  String nameAr;
  String nameEn;
  String description;
  String price;
  int liked;
  int calories;
  String allergens;

  ProductDetailsModel(
      this.id,
      this.image,
      this.mainName,
      this.nameAr,
      this.nameEn,
      this.description,
      this.price,
      this.liked,
      this.allergens,
      this.calories);
}
