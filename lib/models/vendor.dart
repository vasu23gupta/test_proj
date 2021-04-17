import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:test_proj/services/database.dart';
import 'Review.dart';

class Vendor {
  String id;
  String name;
  LatLng coordinates;
  List<String> tags;
  List<NetworkImage> networkImages;
  List<String> imageIds;
  String description;
  List<String> reviewIds = [];
  List<Review> reviews;
  double stars = 0;
  String address;
  DateTime createdOn;
  bool reported;
  bool reviewed;
  List<Asset> assetImages = [];

  Vendor({
    this.id,
    this.coordinates,
    this.name,
    this.tags,
    this.description,
    this.imageIds,
    this.reviewIds,
    this.stars,
    this.createdOn,
    this.address,
    this.reported,
    this.reviewed,
  }) {
    this.networkImages = this.imageIds == null ? null : List(imageIds.length);
  }

  Vendor.fromJsonCoords(Map<String, dynamic> json) {
    List<String> temp = [];

    for (var item in json['tags']) temp.add(item.toString());
    this.tags = temp;
    this.id = json['_id'];
    this.coordinates = LatLng(json['location']['coordinates'][1].toDouble(),
        json['location']['coordinates'][0].toDouble());
  }

  factory Vendor.fromJsonSearch(Map<String, dynamic> json) {
    List<String> temp = [];
    List<String> temp2 = [];
    for (var item in json['tags']) temp.add(item.toString());
    for (var item in json['images']) temp2.add(item.toString());
    return Vendor(
      id: json['_id'],
      name: json['name'],
      tags: temp,
      stars: json['rating'] * 1.0,
      coordinates: new LatLng(json['location']['coordinates'][1].toDouble(),
          json['location']['coordinates'][0].toDouble()),
      createdOn: DateTime.parse(json['createdAt']),
      imageIds: temp2,
    );
  }

  factory Vendor.fromJson(Map<String, dynamic> json) {
    List<String> temp = [];
    List<String> temp2 = [];
    List<String> temp3 = [];
    for (var item in json['tags']) temp.add(item.toString());
    for (var item in json['images']) temp2.add(item.toString());
    for (var item in json['reviews']) temp3.add(item);
    return Vendor(
      id: json['_id'],
      name: json['name'],
      coordinates: new LatLng(json['location']['coordinates'][1].toDouble(),
          json['location']['coordinates'][0].toDouble()),
      description: json['description'],
      tags: temp,
      imageIds: temp2,
      reviewIds: temp3,
      stars: json['rating'].toDouble(),
      address: json['address'],
      reported: json['reported'],
      reviewed: json['reviewed'],
    );
  }

  CachedNetworkImageProvider getImageFomId(String imageId) =>
      VendorDBService.getVendorImage(imageId);

  @override
  bool operator ==(other) => (other is Vendor && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
