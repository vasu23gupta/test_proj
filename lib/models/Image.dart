import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

class IMage {
  String id;
  Image img;
  IMage({this.id, this.img});
  factory IMage.fromJson(Map<String, dynamic> json) {
    ImageProvider provider = MemoryImage(base64Decode(json['data']));
    return IMage(
        img: Image(
      image: provider,
    ));
  }
}
