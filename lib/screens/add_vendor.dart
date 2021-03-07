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

class AddVendor extends StatefulWidget {
  final LatLng userLoc;
  final Vendor vendor;
  AddVendor({this.userLoc, this.vendor});
  @override
  _AddVendorState createState() => _AddVendorState();
}

class _AddVendorState extends State<AddVendor> {
  String description = '';
  String name = '';
  String address = '';
  List<Asset> images = []; // when creating new vendor
  List<NetworkImage> netImages = [];
  MapController controller = new MapController();
  List<String> imageIds = [];
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  List<Marker> markers = [];
  LatLng vendorLatLng;
  String error = '';
  String currentTag;
  List<String> tags = [];
  TextEditingController addTagController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  LatLng userLoc;
  bool editing = false;
  final filter = ProfanityFilter.filterAdditionally(hindiProfanity);

  @override
  void initState() {
    super.initState();
    addressController.text = address;
    if (widget.vendor != null) {
      editing = true;
      Vendor vendor = widget.vendor;
      name = vendor.name;
      userLoc = vendor.coordinates;
      tags = vendor.tags;
      description = vendor.description;
      imageIds = vendor.imageIds;
      netImages = vendor.images;
      _putMarkerOnMap(userLoc);
    } else
      userLoc = widget.userLoc;
  }

  void _putMarkerOnMap(LatLng point) {
    setState(
      () {
        markers = [];
        vendorLatLng = point;
        http
            .get(
          "http://apis.mapmyindia.com/advancedmaps/v1/6vt1tkshzvlqpibaoyklfn4lxiqpit2n/rev_geocode?lat=${point.latitude}&lng=${point.longitude}",
        )
            .then((value) {
          var json = jsonDecode(value.body);
          if ((json['responseCode']) == 200) {
            address = json['results'][0]['formatted_address'];
            addressController.text = address;
          } else
            print(json['responseCode']);
        });
        markers.add(
          Marker(
            width: 45.0,
            height: 45.0,
            point: point,
            builder: (context) => new Container(
              child: IconButton(
                icon: Icon(Icons.location_on),
                iconSize: 80.0,
                onPressed: () {},
              ),
            ),
          ),
        );
      },
    );
  }

  Widget previewImages() {
    if ((editing && netImages.length == 0) || (!editing && images.length == 0))
      return Container();
    else {
      //print(netImages.length);
      return SizedBox(
        height: 150,
        child: ListView.builder(
          itemCount: editing ? netImages.length : images.length,
          itemBuilder: (context, index) {
            return Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                if (editing)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(
                      image: widget.vendor.getImage(index),
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
                        images.removeAt(index);
                      });
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            );
            // String path;
            // FlutterAbsolutePath.getAbsolutePath(images[index].identifier)
            //     .then((value) => path = value);
          },
          scrollDirection: Axis.horizontal,
        ),
      );
    }
  }

//https://api.flutter.dev/flutter/material/Chip/onDeleted.html
//https://www.youtube.com/watch?time_continue=413&v=TF-TBsgIErY&feature=emb_logo
  Iterable<Widget> get tagWidgets sync* {
    for (final String tag in tags) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: InputChip(
          label: Text(tag),
          onDeleted: () {
            setState(() {
              tags.removeWhere((String entry) {
                return entry == tag;
              });
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    String _error = 'No Error Dectected';

    Future<void> loadAssets() async {
      List<Asset> resultList = [];
      //String error = 'No Error Dectected';

      try {
        resultList = await MultiImagePicker.pickImages(
          maxImages: 300,
          enableCamera: true,
          selectedAssets: images,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
            //actionBarColor: "#abcdef",
            actionBarTitle: "Example App",
            allViewTitle: "All Photos",
            useDetailsView: false,
            selectCircleStrokeColor: "#000000",
          ),
        );
      } on Exception catch (e) {
        _error = e.toString();
      }

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      setState(() {
        images = resultList;
        //print(images.length);
      });
    }

    return loading
        ? Loading()
        : Scaffold(
            //backgroundColor: Colors.brown[50],
            appBar: AppBar(
              title: Text('Add Vendor'),
              elevation: 0.0,
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    //name:
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                        initialValue: name,
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Vendor Name'),
                        validator: (val) => val.isEmpty ? 'Enter a name' : null,
                        onChanged: (val) {
                          setState(() => name = val);
                        }),
                    //map:
                    SizedBox(
                      height: 300.0,
                      width: 350.0,
                      child: new FlutterMap(
                        mapController: controller,
                        options: new MapOptions(
                          nePanBoundary:
                              HardcoreMath.toBounds(userLoc).northEast,
                          swPanBoundary:
                              HardcoreMath.toBounds(userLoc).southWest,
                          //bounds: HardcoreMath.toBounds(userLoc),
                          zoom: 18.45, center: userLoc,
                          onTap: _putMarkerOnMap,
                          //center: new LatLng(userLoc.latitude, userLoc.longitude),
                        ),
                        layers: [
                          new TileLayerOptions(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          new MarkerLayerOptions(
                            markers: markers,
                          ),
                        ],
                      ),
                    ),
                    //address
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                        controller: addressController,
                        //initialValue: address,
                        decoration:
                            textInputDecoration.copyWith(hintText: 'Address'),
                        validator: (val) =>
                            val.isEmpty ? 'Enter address' : null,
                        onChanged: (val) {
                          setState(() => address = val);
                        }),
                    //add images
                    SizedBox(
                      height: 20.0,
                    ),
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
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                        initialValue: description,
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Vendor description'),
                        validator: (val) =>
                            val.isEmpty ? 'Enter description' : null,
                        onChanged: (val) {
                          setState(() => description = val);
                        }),
                    //tags:
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                        controller: addTagController,
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Enter tags'),
                        validator: (val) => val.isEmpty && tags.isEmpty
                            ? 'Enter atleast 1 tag'
                            : null,
                        onChanged: (val) {
                          setState(() => currentTag = val);
                        }),
                    //add tag button:
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      color: Colors.pink[400],
                      child: Text(
                        'Add tag',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        addTagController.clear();
                        if (currentTag.isNotEmpty) {
                          tags.add(currentTag);
                          setState(() {
                            // tagChips.add(
                            //   InputChip(
                            //   label: Text(currentTag),
                            //   onDeleted: () {
                            //     setState(() {
                            //       tags.removeWhere(
                            //           (element) => currentTag == element);

                            //     });
                            //   },
                            // ));
                            currentTag = '';
                          });
                        }
                      },
                    ),
                    //show tags
                    Wrap(
                      children: tagWidgets.toList(),
                    ),
                    //submit button:
                    SizedBox(
                      height: 20.0,
                    ),
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
                          if (editing) {
                            result = await VendorDBService.updateVendor(
                              widget.vendor.id,
                              name,
                              vendorLatLng,
                              tags,
                              imageIds,
                              description,
                              address,
                            );
                          } else {
                            result = await VendorDBService.addVendor(
                              name,
                              vendorLatLng,
                              tags,
                              images,
                              description,
                              await user.getIdToken(),
                              address,
                            );
                          }
                          setState(() => loading = false);

                          if (result.statusCode != 200) {
                            setState(() {
                              print(result.statusCode);
                              error = 'could not add vendor';
                            });
                          } else {
                            Vendor vendor =
                                Vendor.fromJson(jsonDecode(result.body));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VendorDetails(vendor: vendor),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    //error text:
                    SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
