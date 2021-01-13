import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide Coords;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/models/vendorData.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/loading.dart';
import 'package:latlong/latlong.dart';
import 'package:test_proj/services/location_service.dart';
import 'dart:async';
import 'package:map_launcher/map_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class VendorDetails extends StatefulWidget {
  final Vendor vendor;
  VendorDetails({this.vendor});
  @override
  _VendorDetailsState createState() => _VendorDetailsState(vendor);
}

class _VendorDetailsState extends State<VendorDetails> {
  _VendorDetailsState(Vendor v) {
    this.vendor = v;
  }

  VendorDBService _dbService = VendorDBService();
  Vendor vendor;
  VendorData vData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _dbService.getVendorDescription(vendor).then((value) => setState(() {
              vData = value;
              loading = false;
            })));
  }

  @override
  Widget build(BuildContext context) {
    String description = "";
    // void getDescription(Vendor vendor) async {
    //   VendorDBService db = new VendorDBService();
    //   description = await db.getVendorDescription(vendor.dataId).description;
    // }

    if (!loading) description = vData.description;
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
    //List<Asset> images = widget.images;
    // Widget previewImages() {
    //   if (images.length == 0)
    //     return Container();
    //   else {
    //     return SizedBox(
    //       height: 150,
    //       child: ListView.builder(
    //         itemCount: images.length,
    //         itemBuilder: (context, index) {
    //           // String path;
    //           // FlutterAbsolutePath.getAbsolutePath(images[index].identifier)
    //           //     .then((value) => path = value);
    //           return Padding(
    //             padding: const EdgeInsets.all(8.0),
    //             child: AssetThumb(
    //               asset: images[index],
    //               width: 150,
    //               height: 150,
    //             ),
    //           );
    //         },
    //         scrollDirection: Axis.horizontal,
    //       ),
    //     );
    //   }
    // }

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
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text(vendor.name),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  //map
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
                          style: TextStyle(fontSize: 30, color: Colors.grey),
                        ),
                        Text(
                          description,
                          style: TextStyle(fontSize: 20),
                        ),
                        Row(
                          children: textTags,
                          textDirection: TextDirection.ltr,
                        ),
                        Divider(),
                        //previewImages(),
                        //photos
                        //https://pub.dev/packages/photo_view
                        Container(
                          height: 600.0,
                          child: PhotoViewGallery.builder(
                            scrollPhysics: const BouncingScrollPhysics(),
                            builder: (BuildContext context, int index) {
                              return PhotoViewGalleryPageOptions(
                                maxScale:
                                    PhotoViewComputedScale.contained * 2.0,
                                minScale:
                                    PhotoViewComputedScale.contained * 0.8,
                                imageProvider: _dbService
                                    .getVendorImage(vData.imageIDs[index]),
                                heroAttributes: PhotoViewHeroAttributes(
                                    tag: vData.imageIDs[index]),
                              );
                            },
                            itemCount: vData.imageIDs.length,
                            loadingBuilder: (context, event) => Center(
                              child: Container(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  value: event == null
                                      ? 0
                                      : event.cumulativeBytesLoaded /
                                          event.expectedTotalBytes,
                                ),
                              ),
                            ),
                            backgroundDecoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                            ),
                            //pageController: widget.pageController,
                            //onPageChanged: onPageChanged,
                          ),
                        )
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
                    heroTag: null,
                    onPressed: () {},
                    child: Icon(Icons.add),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(
                    heroTag: null,
                    onPressed: () async {
                      //final availableMaps = await MapLauncher.installedMaps;
                      //print(availableMaps);

                      await MapLauncher.showDirections(
                          mapType: MapType.google,
                          destination: Coords(vendor.coordinates.latitude,
                              vendor.coordinates.longitude));
                    },
                    child: Icon(Icons.navigation),
                  ),
                )
              ],
            ),
          );
  }
}
