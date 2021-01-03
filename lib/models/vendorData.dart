class VendorData {
  String id;
  List<String> images;

  VendorData({this.id, this.images});

  factory VendorData.fromJson(Map<String, dynamic> json) {
    List<String> temp = [];
    for (var item in json['images']) {
      temp.add(item.toString());
    }
    return VendorData(
      id: json['_id'],
      images: temp,
    );
  }
}
