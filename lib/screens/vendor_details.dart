import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/loading.dart';

class VendorDetails extends StatefulWidget {
  final String vendorID;
  VendorDetails({this.vendorID});
  @override
  _VendorDetailsState createState() => _VendorDetailsState(vid: vendorID);
}

class _VendorDetailsState extends State<VendorDetails> {
  Future<void> loadVendor() async {
    Vendor vd = await VendorDatabaseService(id: vid).vendor;
    setState(() {
      loading = false;
      this.vendor = vd;
    });
  }

  final String vid;
  _VendorDetailsState({this.vid});
  bool loading = true;
  Vendor vendor;
  @override
  Widget build(BuildContext context) {
    loadVendor();
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text(vendor.name),
            ),
          );
  }
}
