import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/models/vendorData.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/loading.dart';
import 'package:latlong/latlong.dart';
import 'package:test_proj/services/location_service.dart';
import 'dart:async';

class VendorDetails extends StatefulWidget {
  final Vendor vendor;
  final VendorData vd;
  final List<Asset> images;
  //final String vendorID;
  VendorDetails({this.vendor, this.vd, this.images});
  @override
  _VendorDetailsState createState() => _VendorDetailsState();
}

class _VendorDetailsState extends State<VendorDetails> {
  // Future<void> loadVendor() async {
  //   Vendor vd = await VendorDatabaseService(id: vid).vendor;
  //   setState(() {
  //     loading = false;
  //     this.vendor = vd;
  //   });
  // }

  // final String vid;
  // _VendorDetailsState({this.vid});

  //Future<void> loadVendor() async {
  //   //print(widget.vendorID);
  //   Vendor vd = await VendorDBService().getVendor(widget.vendorID);
  //   setState(() {
  //     loading = false;
  //     this.vendor = vd;
  //     //print(vendor.coordinates);
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   loadVendor();
  // }

  //bool loading = false;

  @override
  Widget build(BuildContext context) {
    String description = "";
    // void getDescription(Vendor vendor) async {
    //   VendorDBService db = new VendorDBService();
    //   description = await db.getVendorDescription(vendor.dataId).description;
    // }
    VendorData vData = widget.vd;
    description = vData.description;
    Vendor vendor = widget.vendor;
    LatLng vendorLoc = widget.vendor.coordinates;
    List<String> tags = vendor.tags;
    List<Text> textTags = tags
        .map((tag) => Text(
              tag,
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ))
        .toList();
    //getDescription(vendor).whenComplete(() => setState);
    //Future<String> vendorDescription = getDescription(vendor);
    MapController controller = new MapController();
    List<Asset> images = widget.images;
    Widget previewImages() {
      if (images.length == 0)
        return Container();
      else {
        return SizedBox(
          height: 150,
          child: ListView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              // String path;
              // FlutterAbsolutePath.getAbsolutePath(images[index].identifier)
              //     .then((value) => path = value);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: AssetThumb(
                  asset: images[index],
                  width: 150,
                  height: 150,
                ),
              );
            },
            scrollDirection: Axis.horizontal,
          ),
        );
      }
    }

    Marker vendorMarker = new Marker(
      //anchorPos: AnchorPos.align(AnchorAlign.center),
      width: 45.0,
      height: 45.0,
      point: vendorLoc,
      builder: (context) => IconButton(
        //alignment: Alignment.bottomRight,
        icon: Icon(Icons.circle),
        iconSize: 40.0,
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => VendorDetails(
          //       vendor: vendor,
          //     ),
          //   ),
          // );
        },
      ),
    );
    List<Marker> vendorMarkers = new List();
    vendorMarkers.add(vendorMarker);
    return Scaffold(
      appBar: AppBar(
        title: Text(vendor.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 300.0,
              //width: 350.0,
              child: new FlutterMap(
                mapController: controller,
                options: new MapOptions(
                  zoom: 18.45,
                  center: vendorLoc,
                ),
                layers: [
                  new TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  new MarkerLayerOptions(
                    markers: vendorMarkers,
                  ),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: TextStyle(fontSize: 30),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  Row(
                    children: textTags,
                    textDirection: TextDirection.ltr,
                  ),
                  Divider(),
                  //previewImages(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () async {},
              child: Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }
}
