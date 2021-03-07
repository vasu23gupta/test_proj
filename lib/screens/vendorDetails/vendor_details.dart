import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide Coords;
import 'package:provider/provider.dart';
import 'package:test_proj/models/Review.dart';
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
import 'package:test_proj/shared/starRating.dart';
import 'package:test_proj/shared/loginPopup.dart';
import 'package:test_proj/screens/home/home.dart';

class VendorDetails extends StatefulWidget {
  final Vendor vendor;
  VendorDetails({this.vendor});
  @override
  _VendorDetailsState createState() => _VendorDetailsState();
}

class _VendorDetailsState extends State<VendorDetails> {
  User user;
  Vendor vendor;
  List<Review> vendorReviews = [];
  var vendorReviewIndexToBeFetched = 0;
  String description = "";
  String address = '';
  bool loading = true;
  bool reviewsLoading = false;
  bool getNewReviews = true;
  Review myReview;

  Future<void> getReviews(String id) async {
    setState(() {
      reviewsLoading = true;
      getNewReviews = false;
    });
    Review review = await VendorDBService.getReviewByReviewId(id);
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
    Vendor v =
        await VendorDBService.getVendor(vendor.id, await user.getIdToken());
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
    if (v.reviewed) {
      myReview = await VendorDBService.getReviewByUserAndVendorId(
          vendor.id, await user.getIdToken());
    }
    setState(() {
      this.vendor = v;
      loading = false;
    });
  }

  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    this.vendor = widget.vendor;
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      user = Provider.of<User>(context, listen: false);
      getVendor();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void deleteReview() {
    setState(() {
      vendor.reviewed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //bool changed = false;
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        VendorOptions(vendor: vendor),
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
                          Flexible(
                            child: Text(
                              description,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Montserrat',
                                  fontSize: 38),
                            ),
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
                      ),
                    ],
                  ),
                ),
                vendor.reviewed
                    ? MyReview(
                        myReview: myReview,
                        deleteReviewFromUi: deleteReview,
                      )
                    : Container(),
                Text(
                  "Reviews:",
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
                        if (vendorReviews[index].review.isNotEmpty)
                          return ReviewTile(review: vendorReviews[index]);
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
                      'All Reviews',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {},
                  ),
                ]),
                vendor.reviewed
                    ? Container()
                    : RaisedButton(
                        color: Colors.pink[400],
                        child: Text(
                          'Add review',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (user.isAnonymous) {
                            showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return LoginPopup(
                                    to: "add a review",
                                  );
                                });
                            // } else if (!user.emailVerified) {
                            //   showDialog<void>(
                            //       context: context,
                            //       builder: (BuildContext context) {
                            //         return VerifyEmailPopup(
                            //           to: "add a review",
                            //         );
                            //       });
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

class ReviewTile extends StatelessWidget {
  final Review review;
  ReviewTile({this.review});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        children: [
          (review.stars.toDouble() >= 4)
              ? Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      side: BorderSide(width: 5, color: Colors.green)),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: <Widget>[
                            StarRating(rating: review.stars),
                            Text(
                              review.review,
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'Montserrat',
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              review.byUser,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Montserrat',
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : ((review.stars.toDouble() < 4 && review.stars.toDouble() > 2)
                  ? Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          side:
                              BorderSide(width: 5, color: Colors.amberAccent)),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: <Widget>[
                                StarRating(rating: review.stars),
                                Text(
                                  review.review,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  review.byUser,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          side: BorderSide(width: 5, color: Colors.red)),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: <Widget>[
                                StarRating(rating: review.stars),
                                Text(
                                  review.review,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  review.byUser,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
          Card(
            color: Colors.amberAccent[100],
            child: Column(
              children: <Widget>[
                StarRating(rating: review.stars),
                Text(
                  review.review == null ? '' : review.review,
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Montserrat',
                      color: Colors.black),
                ),
                Text(
                  review.byUser,
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyReview extends StatelessWidget {
  final Review myReview;
  final Function deleteReviewFromUi;
  MyReview({this.myReview, this.deleteReviewFromUi});
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Your Review:",
              style: TextStyle(
                  fontSize: 25.0,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'Edit':
                    showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return EditReviewDialogue();
                        });
                    break;
                  case 'Delete':
                    var res = await VendorDBService.deleteReview(
                        myReview.id, await user.getIdToken());
                    if (res.statusCode == 200) {
                      deleteReviewFromUi();
                    }
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Edit', 'Delete'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        ReviewTile(review: myReview)
      ],
    );
  }
}

class EditReviewDialogue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          //close button
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                child: Icon(Icons.close),
                backgroundColor: Colors.red,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                child: Text(
                  'Coming soon! Meanwhile you can delete your current review and post a new review.',
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.25,
                ),
                height: 70,
                width: 500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
