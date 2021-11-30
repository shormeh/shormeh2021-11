class LocationModel {
  int id;
  String descriptionAR;
  String descriptionEN;
  String image;
  String lat;
  String lag;
  int vendor_id;
  String nameAr;
  String nameEn;
  double? rate;
  LocationModel(this.id, this.descriptionAR, this.descriptionEN, this.image,
      this.lat, this.lag, this.vendor_id, this.nameAr, this.nameEn,
      {this.rate});
}
