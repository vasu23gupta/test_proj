import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide Coords;
import 'package:provider/provider.dart';
import 'package:test_proj/models/Review.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/vendorDetails/add_review.dart';
import 'package:test_proj/screens/vendorDetails/full_screen_image.dart';
import 'package:test_proj/screens/vendorDetails/vendor_options.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/shared/loading.dart';
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
  User _user;
  Vendor _vendor;
  List<Review> _vendorReviews = [];
  int _vendorReviewIndexToBeFetched = 0;
  bool _loading = true;
  bool _reviewsLoading = false;
  bool _getNewReviews = true;
  Review _myReview;
  //var _brightness;
  //bool _darkModeOn;
  ScrollController _scrollController = ScrollController();
  double _h;
  double _w;
  MapController _controller = MapController();

  Marker _vendorMarker() => Marker(
      width: 45.0,
      height: 45.0,
      point: _vendor.coordinates,
      builder: (context) => pinMarker);

  Future<void> _getReviews(String id) async {
    setState(() {
      _reviewsLoading = true;
      _getNewReviews = false;
    });
    Review review = await VendorDBService.getReviewByReviewId(id);
    setState(() {
      if (review.review != null) _vendorReviews.add(review);
      _vendorReviewIndexToBeFetched += 1;
    });
  }

  Future<void> _getFiveReviews() async {
    for (int i = 0;
        _vendorReviewIndexToBeFetched < _vendor.reviewIds.length && i < 5;
        i++)
      await _getReviews(_vendor.reviewIds[_vendorReviewIndexToBeFetched]);
    setState(() => _reviewsLoading = false);
  }

  Future<void> _getVendor() async {
    Vendor v =
        await VendorDBService.getVendor(_vendor.id, await _user.getIdToken());
    if (v.reviewed)
      _myReview = await VendorDBService.getReviewByUserAndVendorId(
          _vendor.id, await _user.getIdToken());
    setState(() {
      this._vendor = v;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    this._vendor = widget.vendor;
    //_brightness = SchedulerBinding.instance.window.platformBrightness;
    //_darkModeOn = _brightness == Brightness.dark;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent)
        setState(() => _getNewReviews = true);
    });
    _user = Provider.of<User>(context, listen: false);
    _getVendor();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _deleteReviewFromUi() => setState(() => _vendor.reviewed = false);

  @override
  Widget build(BuildContext context) {
    _h = MediaQuery.of(context).size.height;
    _w = MediaQuery.of(context).size.width;
    if (!_reviewsLoading && !_loading && _getNewReviews) _getFiveReviews();
    return _loading
        ? Loading()
        : Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        _buildGallery(),
                        _buildTopRow(),
                      ],
                    ),
                    //name description address rating tags
                    _buildTextDetails(),
                    //map
                    SizedBox(
                      height: _h * 0.37,
                      child: Stack(
                        children: <Widget>[
                          _buildMap(),
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: _buildMapFAB(),
                          ),
                        ],
                      ),
                    ),
                    _vendor.reviewed
                        ? MyReview(
                            myReview: _myReview,
                            deleteReviewFromUi: _deleteReviewFromUi,
                            w: _w)
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Reviews:",
                        style: TextStyle(
                            fontSize: 25.0,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ),
                    _buildReviewsContainer(),
                    //add review button
                    _vendor.reviewed ? Container() : _buildAddReviewBtn(),
                  ],
                ),
              ),
            ),
          );
  }

  Container _buildReviewsContainer() => Container(
        height: _h * 0.37,
        child: ListView.builder(
            controller: _scrollController,
            itemCount: _vendorReviews.length,
            itemBuilder: (context, index) =>
                _vendorReviews[index].review.isNotEmpty
                    ? ReviewTile(review: _vendorReviews[index], w: _w)
                    : Container()),
      );

  Padding _buildAddReviewBtn() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: BS(_w * 0.02, _h * 0.05),
          child: Text('Add review', style: TextStyle(color: Colors.white)),
          onPressed: () async {
            if (_user.isAnonymous)
              showDialog<void>(
                  context: context,
                  builder: (_) => LoginPopup(to: "add a review"));
            //DONT DELETE
            else if (!_user.emailVerified) {
              await _user.reload();
              if (!_user.emailVerified)
                showDialog<void>(
                    context: context,
                    builder: (_) => VerifyEmailPopup(to: "add a review"));
              else
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddReview(vendor: _vendor)));
            } else
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddReview(vendor: _vendor)));
          },
        ),
      );

  Container _buildTextDetails() => Container(
        padding: EdgeInsets.only(left: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //name
            Text(
              (_vendor.name),
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontSize: _w * 0.13,
                  fontWeight: FontWeight.bold),
            ),
            //description
            Text(
              _vendor.description,
              style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Montserrat',
                  fontSize: _w * 0.06),
            ),
            //address
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
              child: Text(
                _vendor.address,
                style: TextStyle(
                    color: Colors.green[200],
                    fontFamily: 'Montserrat',
                    fontSize: _w * 0.05,
                    fontWeight: FontWeight.bold),
              ),
            ),
            //rating
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              child: Row(
                children: <Widget>[
                  Text(
                    _vendor.stars.toString(),
                    style: TextStyle(
                        fontSize: _w * 0.07,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 0, 2),
                    child: StarRating(rating: _vendor.stars, size: _w * 0.07),
                  ),
                ],
              ),
            ),
            //tags
            Wrap(
              children: _vendor.tags
                  .map((tag) => Padding(
                        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
                        child: Chip(
                          backgroundColor:
                              Theme.of(context).chipTheme.backgroundColor,
                          label: Text(tag, style: TextStyle(fontSize: 20)),
                        ),
                      ))
                  .toList(),
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      );

  FlutterMap _buildMap() => FlutterMap(
        mapController: _controller,
        options: MapOptions(
          nePanBoundary: HardcoreMath.toBounds(_vendor.coordinates).northEast,
          swPanBoundary: HardcoreMath.toBounds(_vendor.coordinates).southWest,
          zoom: 18.45,
          center: _vendor.coordinates,
        ),
        layers: [
          TileLayerOptions(
              urlTemplate:
                  "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style=main&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}",
              additionalOptions: {
                'subscriptionKey':
                    '6QKwOYYBryorrSaUj2ZqHEdWd3b4Ey_8ZFo6VOj_7xw',
                //'theme': _darkModeOn ? 'dark' : 'main'
              }),
          MarkerLayerOptions(markers: [_vendorMarker()]),
        ],
      );

  FloatingActionButton _buildMapFAB() => FloatingActionButton(
        onPressed: () async => await MapLauncher.showDirections(
            mapType: MapType.google,
            destination: Coords(
                _vendor.coordinates.latitude, _vendor.coordinates.longitude)),
        child: Icon(Icons.navigation),
      );

  Row _buildTopRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(),
          ),
          VendorOptions(vendor: _vendor),
        ],
      );

  Container _buildGallery() => Container(
        height: _h * 0.37,
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) =>
              PhotoViewGalleryPageOptions(
            onTapDown: (context, details, controllerValue) =>
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => FullScreenImage(
                        imageIDs: _vendor.imageIds, index: index))),
            maxScale: PhotoViewComputedScale.contained * 2.0,
            minScale: PhotoViewComputedScale.contained * 0.8,
            imageProvider:
                VendorDBService.getVendorImage(_vendor.imageIds[index]),
            heroAttributes:
                PhotoViewHeroAttributes(tag: _vendor.imageIds[index]),
          ),
          itemCount: _vendor.imageIds.length,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes,
              ),
            ),
          ),
          backgroundDecoration:
              BoxDecoration(color: Theme.of(context).canvasColor),
        ),
      );
}

class ReviewTile extends StatelessWidget {
  final Review review;
  final double w;
  ReviewTile({this.review, this.w});
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
                StarRating(rating: review.stars, size: w * 0.06),
                Text(review.review == null ? "" : review.review,
                    style: TextStyle(
                      fontSize: w * 0.06,
                      fontFamily: 'Montserrat',
                      color: Colors.black,
                    )),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(review.byUser,
                        style: TextStyle(
                          fontSize: w * 0.03,
                          fontFamily: 'Montserrat',
                          color: Colors.grey,
                        )),
                  )
                ])
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class MyReview extends StatelessWidget {
  final double w;
  final Review myReview;
  final Function deleteReviewFromUi;
  MyReview({this.myReview, this.deleteReviewFromUi, this.w});
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
        ReviewTile(
          review: myReview,
          w: w,
        )
      ],
    );
  }
}

class EditReviewDialogue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        clipBehavior: Clip.none,
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
