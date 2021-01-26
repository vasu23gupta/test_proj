import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide Coords;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/Review.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/models/vendorData.dart';
import 'package:test_proj/screens/add_review.dart';
import 'package:test_proj/screens/add_vendor.dart';
import 'package:test_proj/screens/vendor_options.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/loading.dart';
import 'package:latlong/latlong.dart';
import 'package:test_proj/services/location_service.dart';
import 'dart:async';
import 'package:map_launcher/map_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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

  Vendor vendor;
  List<Review> vendorReviews = [];
  var vendorReviewIndexToBeFetched = 0;
  //VendorData vData;
  bool loading = true;
  bool reviewsLoading = false;
  bool getNewReviews = true;
  getReviews(
    String id,
  ) async {
    setState(() {
      reviewsLoading = true;
      getNewReviews = false;
    });
    Review review = await VendorDBService.getReview(id);
    setState(() {
      vendorReviews.add(review);
      vendorReviewIndexToBeFetched = vendorReviewIndexToBeFetched + 1;
      //print(vendorReviewIndexToBeFetched);
    });
  }

  int getCurrentIndexToBeFetched() {
    return vendorReviewIndexToBeFetched;
  }

  getFiveReviews() async {
    //print(this.vendor.name);
    for (int i = 0;
        getCurrentIndexToBeFetched() < vendor.reviewIds.length && i < 5;
        i++) {
      /* setState(() {
        reviewsLoading = true;
      }); */
      //print(getCurrentIndexToBeFetched());
      await getReviews(vendor.reviewIds[getCurrentIndexToBeFetched()]);
    }
    setState(() {
      reviewsLoading = false;
    });
  }

  Future<void> getVendor() async {
    Vendor v = await VendorDBService.getVendor(vendor.id);
    // Vendor v = await _dbService.getVendor(
    //   id: vendor.id,
    //   vendor: vendor,
    //   name: vendor.name == null,
    //   tags: vendor.tags == null,
    //   description: vendor.description == null,
    //   imageIds: vendor.imageIds == null,
    //   reviewIds: vendor.reviewIds == null,
    //   coordinates: vendor.coordinates == null,
    //   stars: vendor.stars == null,
    // );
    setState(() {
      this.vendor = v;
      loading = false;
    });
  }

  ScrollController scrollController = new ScrollController();
  @override
  void initState() {
    super.initState();
    getVendor();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          getNewReviews = true;
        });
      }
    });
    //print(this.vendor.name);
    //getFiveReviews(vendorReviewIndexToBeFetched);
    // WidgetsBinding.instance.addPostFrameCallback((_) => _dbService
    //     .getVendor(
    //       id: vendor.id,
    //       vendor: vendor,
    //       name: vendor.name == null,
    //       tags: vendor.tags == null,
    //       description: vendor.description == null,
    //       imageIds: vendor.imageIds == null,
    //       reviewIds: vendor.reviewIds == null,
    //       coordinates: vendor.coordinates == null,
    //     )
    //     .then((value) => setState(() {
    //           vendor = value;
    //           loading = false;
    //         })));

    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      _dbService
          .getVendor(
            vendor.id,
          )
          .then((value) => setState(() {
                vendor = value;
                print(vendor.reviewIds);
                loading = false;
              }));
    }); */
    //if (!loading) print(this.vendor.name);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String description = "";
    //bool changed = false;
    if (!loading) {
      description = vendor.description;
      //getFiveReviews();
      /* if (vendor.reviewIds.isNotEmpty) {
        List<Review> reviews = new List<Review>();
        for (var reviewId in vendor.reviewIds) {
          print("e");
          _dbService
              .getReview(
            reviewId,
          )
              .then((value) {
            reviews.add(value);
            changed = true;
            print(value.review);
          });
        }
        if (changed) {
          setState(() {
            vendorReviews = reviews;
            changed = false;
            print(vendorReviews.length);
          });
        }
      } */
    }
    if (!reviewsLoading && !loading && getNewReviews) {
      getFiveReviews();
    }
    //print(vendorReviews.length);
    LatLng vendorLoc = widget.vendor.coordinates;
    MapController controller = new MapController();

    Marker vendorMarker = new Marker(
      //anchorPos: AnchorPos.align(AnchorAlign.center),
      width: 45.0,
      height: 45.0,
      point: vendorLoc,
      builder: (context) => IconButton(
        //alignment: Alignment.bottomRight,
        icon: Icon(Icons.circle),
        iconSize: 40.0,
        onPressed: () {},
      ),
    );
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text(vendor.name),
              actions: <Widget>[
                Provider(
                  create: (context) => vendor,
                  child: Options(vendor: vendor),
                ),
              ],
              // leading: IconButton(
              //   icon: Icon(Icons.arrow_back),
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              // ),
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
                          markers: [vendorMarker],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Description",
                    style: TextStyle(fontSize: 30, color: Colors.grey),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 20),
                  ),
                  Row(
                    children: vendor.tags
                        .map((tag) => Text(
                              tag + " ",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.blue),
                            ))
                        .toList(),
                    textDirection: TextDirection.ltr,
                  ),
                  //Divider(),
                  //photos
                  //https://pub.dev/packages/photo_view
                  Container(
                    height: 500.0,
                    child: PhotoViewGallery.builder(
                      scrollPhysics: const BouncingScrollPhysics(),
                      builder: (BuildContext context, int index) {
                        //print(index);
                        return PhotoViewGalleryPageOptions(
                          maxScale: PhotoViewComputedScale.contained * 2.0,
                          minScale: PhotoViewComputedScale.contained * 0.8,
                          imageProvider: vendor.getImage(index),
                          heroAttributes: PhotoViewHeroAttributes(
                              tag: vendor.imageIds[index]),
                        );
                      },
                      itemCount: vendor.imageIds.length,
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
                  ),
                  Text(
                    "Reviews",
                    style: TextStyle(fontSize: 30, color: Colors.grey),
                  ),
                  Text(
                    vendor.stars.toString() + " Stars",
                    style: TextStyle(fontSize: 30, color: Colors.grey),
                  ),
                  //vendor.reviewIds.length>0? RatingBarIndicator(itemBuilder: null): Container(),
                  //reviews
                  //reviewsLoading
                  //    ? Loading()
                  /* : */ Container(
                    height: 280,
                    child: ListView.builder(
                        controller: scrollController,
                        itemCount: vendorReviews.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Column(
                              children: [
                                Text(
                                  vendorReviews[index].stars.toString(),
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                                Text(
                                  vendorReviews[index].review,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                                Text(
                                  "by: ",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  vendorReviews[index].byUser,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                  /*  */
                  //Padding(
                  //       padding: const EdgeInsets.all(2.0),
                  //       child: vData.reviews[index].widget,
                  //     );
                  //   },
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  //add review button
                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                      'Add review',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddReview(
                            vendor: vendor,
                          ),
                        ),
                      );
                    },
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
                ),
              ],
            ),
          );
  }
}
