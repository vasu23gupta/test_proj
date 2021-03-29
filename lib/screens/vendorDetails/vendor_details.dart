import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart' hide Coords;
import 'package:provider/provider.dart';
import 'package:test_proj/models/Review.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/vendorDetails/add_review.dart';
import 'package:test_proj/screens/vendorDetails/full_screen_image.dart';
import 'package:test_proj/screens/vendorDetails/vendor_options.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:test_proj/shared/loading.dart';
import 'package:latlong/latlong.dart';
import 'dart:async';
import 'package:map_launcher/map_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:test_proj/shared/starRating.dart';
import 'package:test_proj/shared/loginPopup.dart';

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
  var _brightness;
  bool _darkModeOn;
  ScrollController scrollController = ScrollController();
  int index;

  Future<void> getReviews(String id) async {
    setState(() {
      reviewsLoading = true;
      getNewReviews = false;
    });
    Review review = await VendorDBService.getReviewByReviewId(id);
    setState(() {
      if (review.review != null) vendorReviews.add(review);
      vendorReviewIndexToBeFetched += 1;
    });
  }

  Future<void> getFiveReviews() async {
    for (int i = 0;
        vendorReviewIndexToBeFetched < vendor.reviewIds.length && i < 5;
        i++) await getReviews(vendor.reviewIds[vendorReviewIndexToBeFetched]);
    setState(() => reviewsLoading = false);
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
    if (v.reviewed)
      myReview = await VendorDBService.getReviewByUserAndVendorId(
          vendor.id, await user.getIdToken());

    setState(() {
      this.vendor = v;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    this.vendor = widget.vendor;
    _brightness = SchedulerBinding.instance.window.platformBrightness;
    _darkModeOn = _brightness == Brightness.dark;
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent)
        setState(() => getNewReviews = true);
    });
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

  void deleteReviewFromUi() => setState(() => vendor.reviewed = false);

  @override
  Widget build(BuildContext context) {
    if (!loading) {
      description = vendor.description;
      address = vendor.address;
    }
    if (!reviewsLoading && !loading && getNewReviews) getFiveReviews();
    LatLng vendorLoc = widget.vendor.coordinates;
    MapController controller = MapController();
    Marker vendorMarker = Marker(
      width: 45.0,
      height: 45.0,
      point: vendorLoc,
      builder: (context) => Icon(
        Icons.circle,
        size: 40,
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
                      child: PhotoViewGallery.builder(
                        scrollPhysics: const BouncingScrollPhysics(),
                        builder: (BuildContext context, int index) =>
                            PhotoViewGalleryPageOptions(
                          onTapDown: (context, details, controllerValue) =>
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => FullScreenImage(
                                        imageIDs: vendor.imageIds,
                                        index: index,
                                      ))),
                          maxScale: PhotoViewComputedScale.contained * 2.0,
                          minScale: PhotoViewComputedScale.contained * 0.8,
                          imageProvider: VendorDBService.getVendorImage(
                              vendor.imageIds[index]),
                          heroAttributes: PhotoViewHeroAttributes(
                              tag: vendor.imageIds[index]),
                        ),
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
                        backgroundDecoration:
                            BoxDecoration(color: Theme.of(context).canvasColor),

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
                //name description address rating tags
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //name
                      Text(
                        (vendor.name),
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                      //description
                      Text(
                        description,
                        style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Montserrat',
                            fontSize: 38),
                      ),
                      //address
                      Text(
                        address,
                        style: TextStyle(
                            color: Colors.green[200],
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      //rating
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
                      //tags
                      Row(
                        children: vendor.tags
                            .map(
                              (tag) => Chip(
                                backgroundColor:
                                    Theme.of(context).chipTheme.backgroundColor,
                                label: Text(
                                  tag,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            )
                            .toList(),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
                //map
                SizedBox(
                  height: 300.0,
                  child: Stack(
                    children: <Widget>[
                      FlutterMap(
                        mapController: controller,
                        options: MapOptions(
                          nePanBoundary:
                              HardcoreMath.toBounds(vendorLoc).northEast,
                          swPanBoundary:
                              HardcoreMath.toBounds(vendorLoc).southWest,
                          zoom: 18.45,
                          center: vendorLoc,
                        ),
                        layers: [
                          TileLayerOptions(
                              urlTemplate:
                                  "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style={theme}&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}",
                              additionalOptions: {
                                'subscriptionKey':
                                    '6QKwOYYBryorrSaUj2ZqHEdWd3b4Ey_8ZFo6VOj_7xw',
                                'theme': _darkModeOn ? 'dark' : 'main'
                              }),
                          MarkerLayerOptions(markers: [vendorMarker]),
                        ],
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: FloatingActionButton(
                          onPressed: () async =>
                              await MapLauncher.showDirections(
                                  mapType: MapType.google,
                                  destination: Coords(
                                      vendor.coordinates.latitude,
                                      vendor.coordinates.longitude)),
                          child: Icon(Icons.navigation),
                        ),
                      ),
                    ],
                  ),
                ),
                vendor.reviewed
                    ? MyReview(
                        myReview: myReview,
                        deleteReviewFromUi: deleteReviewFromUi,
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
                Container(
                  padding: EdgeInsets.only(left: 20),
                  height: 280,
                  child: ListView.builder(
                      controller: scrollController,
                      itemCount: vendorReviews.length,
                      itemBuilder: (context, index) =>
                          vendorReviews[index].review.isNotEmpty
                              ? ReviewTile(review: vendorReviews[index])
                              : Container()),
                ),
                SizedBox(height: 20),
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
                        child: Text('Add review',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          if (user.isAnonymous)
                            showDialog<void>(
                                context: context,
                                builder: (_) => LoginPopup(to: "add a review"));
                          //DONT DELETE
                          // else if (!user.emailVerified) {
                          //   await user.reload();
                          //   if (!user.emailVerified)
                          //     showDialog<void>(
                          //         context: context,
                          //         builder: (_) =>
                          //             VerifyEmailPopup(to: "add a review"));
                          //   else
                          //     Navigator.of(context).push(MaterialPageRoute(
                          //         builder: (_) => AddReview(vendor: vendor)));
                          // }
                          else
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AddReview(vendor: vendor)));
                        },
                      ),
              ],
            ),
          );
  }
}

class ReviewTile extends StatelessWidget {
  final Review review;
  ReviewTile({this.review});
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        side: BorderSide(
          width: 5,
          color: review.stars > 4
              ? Colors.green[900]
              : review.stars > 3
                  ? Colors.green[300]
                  : review.stars > 2
                      ? Colors.yellow
                      : review.stars > 1
                          ? Colors.orange
                          : Colors.red,
        ),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                StarRating(rating: review.stars),
                Text(
                  review.review == null ? "" : review.review,
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
    ));
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
                        context: context, builder: (_) => EditReviewDialogue());
                    break;
                  case 'Delete':
                    var res = await VendorDBService.deleteReview(
                        myReview.id, await user.getIdToken());
                    if (res.statusCode == 200) deleteReviewFromUi();
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Edit', 'Delete'}
                    .map((String choice) => PopupMenuItem<String>(
                        value: choice, child: Text(choice)))
                    .toList();
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
              onTap: () => Navigator.of(context).pop(),
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
