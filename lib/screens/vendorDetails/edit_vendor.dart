import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/vendorDetails/vendor_details.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/hindi_profanity.dart';
import 'package:test_proj/shared/loading.dart';
import 'package:latlong/latlong.dart';

class EditVendor extends StatefulWidget {
  final Vendor vendor;
  EditVendor({this.vendor});
  @override
  _EditVendorState createState() => _EditVendorState();
}

class _EditVendorState extends State<EditVendor> {
  String description = '';
  String name = '';
  String address = '';
  List<Asset> images = []; // when creating new vendor
  List<NetworkImage> netImages = [];
  MapController controller = MapController();
  List<String> imageIds = [];
  final _formKey = GlobalKey<FormState>();
  bool loading = true;
  List<Marker> markers = [];
  LatLng vendorLatLng;
  String error = '';
  List<String> tags = [];
  TextEditingController addTagController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  LatLng userLoc;
  List<String> imageIdsToBeRemoved = [];
  final bool editing = true;
  Vendor vendor;
  List<String> suggestions = [];
  List<String> allTags = [];
  Widget tagsSuggestionsOverlay;
  Container emptyContainer = Container();
  final filter = ProfanityFilter.filterAdditionally(hindiProfanity);
  LocationService _locSer = LocationService();
  String loadingText;
  LatLngBounds _mapBounds;

  Future<void> loadAssets() async {
    List<Asset> resultList = [];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
      for (int i = 0; i < resultList.length; i++) {}
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() => images = resultList);
  }

  @override
  void initState() {
    super.initState();
    allTags.addAll(FILTERS.keys);
    addressController.text = address;
    tagsSuggestionsOverlay = emptyContainer;
    if (widget.vendor != null) {
      //editing = true;
      vendor = widget.vendor;
      name = vendor.name;
      tags = vendor.tags;
      description = vendor.description;
      imageIds = List<String>.from(vendor.imageIds);
      netImages = List<NetworkImage>.from(vendor.images);
      _putMarkerOnMap(vendor.coordinates);
    }
    getLocation();
  }

  Future getLocation() async {
    var ld = await _locSer.getLocation();
    userLoc = LatLng(ld.latitude, ld.longitude);
    if (userLoc == null) {
      setState(() =>
          loadingText = "You need to enable your location to add a vendor.");
    } else {
      _mapBounds = HardcoreMath.toBounds(userLoc);
      if (vendor.coordinates.longitude < _mapBounds.east &&
          vendor.coordinates.longitude > _mapBounds.west &&
          vendor.coordinates.latitude < _mapBounds.north &&
          vendor.coordinates.latitude > _mapBounds.south) {
        setState(() => loading = false);
      } else {
        print(vendor.coordinates.longitude < _mapBounds.east);
        print(vendor.coordinates.longitude > _mapBounds.west);
        print(vendor.coordinates.latitude < _mapBounds.north);
        print(vendor.coordinates.latitude > _mapBounds.south);
        setState(
            () => loadingText = "You must be close to the vendor to edit it.");
      }
    }
  }

  Future<void> _putMarkerOnMap(LatLng point) async {
    String address =
        await VendorDBService.getAddress(point.latitude, point.longitude);
    setState(
      () {
        vendor.coordinates = point;
        addressController.text = address;
        markers.add(Marker(
          width: 45.0,
          height: 45.0,
          point: point,
          builder: (context) => Icon(Icons.location_on, size: 40),
        ));
      },
    );
  }

  Widget previewImages() {
    if (netImages.length == 0 && images.length == 0)
      return Container();
    else {
      //print(netImages.length);
      return SizedBox(
        height: 150,
        child: ListView.builder(
          itemCount: editing ? netImages.length + images.length : images.length,
          itemBuilder: (context, index) => Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              if (editing)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: index < netImages.length
                      ? Image(
                          image: widget.vendor.getImageFomId(imageIds[index]))
                      : AssetThumb(
                          asset: images[index - netImages.length],
                          width: 150,
                          height: 150,
                        ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AssetThumb(
                    asset: images[index],
                    width: 150,
                    height: 150,
                  ),
                ),
              Positioned(
                top: 0,
                right: 0,
                height: 30,
                width: 30,
                child: InkResponse(
                  onTap: () {
                    setState(() {
                      if (index < imageIds.length) {
                        imageIdsToBeRemoved.add(imageIds[index]);
                        print(imageIds[index]);
                        imageIds.removeAt(index);
                        netImages.removeAt(index);
                      } else if (index < images.length + imageIds.length) {
                        images.removeAt(imageIds.length - index);
                      }
                    });
                  },
                  child: CircleAvatar(
                    child: Icon(Icons.close),
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          scrollDirection: Axis.horizontal,
        ),
      );
    }
  }

  Future<Container> tagsSuggestions(String query) async {
    suggestions.clear();
    if (query.isNotEmpty) {
      query = query.toLowerCase();
      for (var item in allTags) {
        //print(item);
        if (item.toLowerCase().contains(query)) {
          suggestions.add(item);
          // print('item $item');
          // print('query $query');
        }
      }
      for (var item in suggestions) {
        print('item $item');
      }
    }
    return Container(
      color: Theme.of(context).cardColor,
      // height: 200,
      // width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: suggestions.map((e) {
          return ListTile(
            title: Center(child: Text(e)),
            onTap: () {
              if (!tags.contains(e)) tags.add(e);
              setState(() {
                addTagController.clear();
                suggestions.clear();
                tagsSuggestionsOverlay = emptyContainer;
              });
            },
          );
        }).toList(),
      ),
    );
  }

//https://api.flutter.dev/flutter/material/Chip/onDeleted.html
//https://www.youtube.com/watch?time_continue=413&v=TF-TBsgIErY&feature=emb_logo
  Iterable<Widget> get tagWidgets sync* {
    for (final String tag in tags) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: InputChip(
          label: Text(tag),
          onDeleted: () =>
              setState(() => tags.removeWhere((String entry) => entry == tag)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return loading
        ? Loading(data: loadingText)
        : Scaffold(
            //backgroundColor: Colors.brown[50],
            appBar: AppBar(title: Text('Add Vendor'), elevation: 0.0),
            body: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      //name:
                      SizedBox(height: 20.0),
                      TextFormField(
                          initialValue: name,
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Vendor Name'),
                          validator: (val) =>
                              val.isEmpty ? 'Enter a name' : null,
                          onChanged: (val) => setState(() => name = val)),
                      //map:
                      SizedBox(
                        height: 300.0,
                        width: 350.0,
                        child: FlutterMap(
                          mapController: controller,
                          options: MapOptions(
                            nePanBoundary: _mapBounds.northEast,
                            swPanBoundary: _mapBounds.southWest,
                            //bounds: HardcoreMath.toBounds(userLoc),
                            zoom: 18.45, center: vendor.coordinates,
                            onTap: _putMarkerOnMap,
                            //center: new LatLng(userLoc.latitude, userLoc.longitude),
                          ),
                          layers: [
                            TileLayerOptions(
                                urlTemplate:
                                    "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style=dark&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}",
                                additionalOptions: {
                                  'subscriptionKey':
                                      '6QKwOYYBryorrSaUj2ZqHEdWd3b4Ey_8ZFo6VOj_7xw'
                                }),
                            MarkerLayerOptions(markers: markers),
                          ],
                        ),
                      ),
                      //address
                      SizedBox(height: 20.0),
                      TextFormField(
                          controller: addressController,
                          //initialValue: address,
                          decoration:
                              textInputDecoration.copyWith(hintText: 'Address'),
                          validator: (val) =>
                              val.isEmpty ? 'Enter address' : null,
                          onChanged: (val) => setState(() => address = val)),
                      //add images
                      SizedBox(height: 20.0),
                      RaisedButton(
                        color: Colors.pink[400],
                        child: Text(
                          'Upload Images',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: loadAssets,
                      ),
                      previewImages(),
                      //description
                      SizedBox(height: 20.0),
                      TextFormField(
                          initialValue: description,
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Vendor description'),
                          validator: (val) =>
                              val.isEmpty ? 'Enter description' : null,
                          onChanged: (val) =>
                              setState(() => description = val)),
                      //tags:
                      SizedBox(height: 20.0),
                      TextFormField(
                          controller: addTagController,
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Enter tags'),
                          validator: (val) => val.isEmpty && tags.isEmpty
                              ? 'Enter atleast 1 tag'
                              : null,
                          onChanged: (val) async {
                            tagsSuggestionsOverlay = await tagsSuggestions(val);
                            setState(() {});
                          }),
                      tagsSuggestionsOverlay,
                      //add tag button:
                      SizedBox(height: 20.0),
                      RaisedButton(
                        color: Colors.pink[400],
                        child: Text(
                          'Add tag',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (addTagController.text.isNotEmpty) {
                            tags.add(addTagController.text);
                            setState(() => addTagController.clear());
                          }
                        },
                      ),
                      //show tags
                      Wrap(children: tagWidgets.toList()),
                      //submit button:
                      SizedBox(height: 20.0),
                      RaisedButton(
                        color: Colors.pink[400],
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          //validation
                          if (_formKey.currentState.validate() &&
                              vendorLatLng != null &&
                              (images.length != 0 || imageIds.length != 0)) {
                            setState(() => loading = true);

                            for (var tag in tags) {
                              if (filter.hasProfanity(tag)) tags.remove(tag);
                            }
                            name = filter.censor(name);
                            description = filter.censor(description);
                            address = filter.censor(address);
                            http.Response result;
                            if (editing)
                              result = await VendorDBService.updateVendor(
                                await user.getIdToken(),
                                widget.vendor.id,
                                name,
                                vendorLatLng,
                                tags,
                                imageIds,
                                imageIdsToBeRemoved,
                                images,
                                description,
                                address,
                              );
                            else
                              result = await VendorDBService.addVendor(
                                name,
                                vendorLatLng,
                                tags,
                                images,
                                description,
                                await user.getIdToken(),
                                address,
                              );

                            setState(() => loading = false);

                            if (result.statusCode != 200)
                              setState(() {
                                print(result.statusCode);
                                error = 'could not add vendor';
                              });
                            else {
                              Map<String,dynamic> object=jsonDecode(result.body);
                              if(object.containsKey("limitExceeded"))
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(object['limitExceeded'])));
                              }
                              else
                              {
                                Vendor vendor =
                                  Vendor.fromJson(jsonDecode(result.body));
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        VendorDetails(vendor: vendor)));
                              }
                            }
                          }
                        },
                      ),
                      //error text:
                      SizedBox(height: 12.0),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
