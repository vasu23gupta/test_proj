import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide Coords;
import 'package:provider/provider.dart';
import 'package:test_proj/models/Review.dart';
import 'package:test_proj/models/customUser.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/vendorDetails/add_review.dart';
import 'package:test_proj/screens/vendorDetails/vendor_options.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/loading.dart';
import 'package:latlong/latlong.dart';
import 'dart:async';
import 'package:map_launcher/map_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:test_proj/shared/starrating.dart';
import 'package:test_proj/shared/loginPopup.dart';

class VendorDetails extends StatefulWidget {
  final Vendor vendor;
  VendorDetails({this.vendor});
  @override
  _VendorDetailsState createState() => _VendorDetailsState();
}

class _VendorDetailsState extends State<VendorDetails> {
  Vendor vendor;
  List<Review> vendorReviews = [];
  var vendorReviewIndexToBeFetched = 0;
  String description = "";
  String address = '';
  bool loading = true;
  bool reviewsLoading = false;
  bool getNewReviews = true;

  Future<void> getReviews(String id) async {
    setState(() {
      reviewsLoading = true;
      getNewReviews = false;
    });
    Review review = await VendorDBService.getReview(id);
    setState(() {
      if (review.review != null) vendorReviews.add(review);
      vendorReviewIndexToBeFetched += 1;
      //print(vendorReviewIndexToBeFetched);
    });
  }

  int index;

  int getCurrentIndexToBeFetched() {
    return vendorReviewIndexToBeFetched;
  }

  Future<void> getFiveReviews() async {
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
    this.vendor = widget.vendor;
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
    //bool changed = false;
    final user = Provider.of<CustomUser>(context);
    if (!loading) {
      description = vendor.description;
      address = vendor.address;
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
            body: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      height: 300.0,
                      //print(index);
                      child: PhotoViewGallery.builder(
                        scrollPhysics: const BouncingScrollPhysics(),
                        builder: (BuildContext context, int index) {
                          return PhotoViewGalleryPageOptions(
                            maxScale: PhotoViewComputedScale.contained * 2.0,
                            minScale: PhotoViewComputedScale.contained * 0.8,
                            imageProvider: VendorDBService.getVendorImage(
                                vendor.imageIds[index]),
                            heroAttributes: PhotoViewHeroAttributes(
                                tag: vendor.imageIds[index]),
                          );
                          /* decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(vendor.imageIds[index]),
                              fit: BoxFit.cover)),*/
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          color: Colors.black,
                          onPressed: () {},
                        ),
                        Options(vendor: vendor),
                      ],
                    ),
                  ],
                ),

                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        (vendor.name),
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: <Widget>[
                          Text(
                            description,
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Montserrat',
                                fontSize: 38),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              address,
                              style: TextStyle(
                                  color: Colors.green[200],
                                  fontFamily: 'Montserrat',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(Icons.location_on),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            vendor.stars.toString(),
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          StarRating(rating: vendor.stars),
                        ],
                      ),
                      /*  Row(
                          children: vendor.tags
                              .map((tag) => Text(
                                    tag + " ",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.blue),
                                  ))
                              .toList(),
                          textDirection: TextDirection.ltr,
                        ),*/
                    ],
                  ),
                ),

                SizedBox(
                  height: 300.0,
                  //width: 350.0,
                  child: Stack(
                    children: <Widget>[
                      new FlutterMap(
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
                      FloatingActionButton(
                        onPressed: () async {
                          //final availableMaps = await MapLauncher.installedMaps;
                          //print(availableMaps);

                          await MapLauncher.showDirections(
                              mapType: MapType.google,
                              destination: Coords(vendor.coordinates.latitude,
                                  vendor.coordinates.longitude));
                        },
                        child: Icon(Icons.navigation),
                      )
                    ],
                  ),
                ),

                Text(
                  "Reviews",
                  style: TextStyle(
                      fontSize: 25.0,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                //vendor.reviewIds.length>0? RatingBarIndicator(itemBuilder: null): Container(),
                //reviews
                //reviewsLoading
                //    ? Loading()
                /* : */ Container(
                  padding: EdgeInsets.only(left: 20),
                  height: 280,
                  child: ListView.builder(
                      controller: scrollController,
                      itemCount: vendorReviews.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Column(
                            children: [
                              Card(
                                  color: Colors.amberAccent[100],
                                  child: Column(
                                    children: <Widget>[
                                      StarRating(
                                          rating: vendorReviews[index].stars),
                                      Text(
                                        vendorReviews[index].review,
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontFamily: 'Montserrat',
                                            color: Colors.black),
                                      ),
                                      Text(
                                        vendorReviews[index].byUser,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Montserrat',
                                            color: Colors.grey),
                                      ),
                                    ],
                                  )),

                              /* StarRating(
                                        rating: vendorReviews[index].stars),*/
                              /* ListTileTheme(
                                      dense: true,
                                      style: ListTileStyle.drawer,
                                      tileColor: Colors.amberAccent[50],
                                      child: ListTile(
                                        selected: false,
                                        title: Text(
                                          vendorReviews[index].review,
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontFamily: 'Montserrat',
                                              color: Colors.black),
                                        ),
                                        subtitle: Text(
                                          vendorReviews[index].byUser,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Montserrat',
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ),*/
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
                Row(children: <Widget>[
                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                      'Add review',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (user.isAnon) {
                        showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return LoginPopup(
                                to: "add a review",
                              );
                            });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddReview(
                              vendor: vendor,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                      'All Reviews',
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
                ]),
              ],
            ),
          );
  }

/* SizedBox(
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
                  ),*/
}
