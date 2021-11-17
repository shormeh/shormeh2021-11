class LocationModel {
  int id;
  String email;
  String phone;
  String image;
  String lat;
  String lag;
  int vendor_id;
  String nameAr;
  String nameEn;
  double? rate;
  LocationModel(this.id, this.email, this.phone, this.image, this.lat, this.lag,
      this.vendor_id, this.nameAr, this.nameEn,
      {this.rate});
}
