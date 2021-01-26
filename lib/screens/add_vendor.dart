import 'dart:convert';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/vendor_details.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/loading.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:dio/dio.dart' as dio;

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
  List<Asset> images = List<Asset>(); // when creating new vendor
  List<NetworkImage> netImages = List();
  MapController controller = new MapController();
  List<String> imageIds = new List<String>();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  List<Marker> markers = [];
  LatLng vendorLatLng;
  String error = '';
  String currentTag;
  List<String> tags = new List<String>();
  TextEditingController addTagController = TextEditingController();
  LatLng userLoc;
  bool editing = false;

  @override
  void initState() {
    super.initState();
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
    if (images.length == 0)
      return Container();
    else {
      return SizedBox(
        height: 150,
        child: ListView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                if (editing)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(
                      image: netImages[index],
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
    //final user = Provider.of<CustomUser>(context);

    String _error = 'No Error Dectected';

    Future<void> loadAssets() async {
      List<Asset> resultList = List<Asset>();
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
        print(images.length);
      });
    }

    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.brown[50],
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
                        print('pressed');
                        print(images.length);
                        //validation
                        if (_formKey.currentState.validate() &&
                            vendorLatLng != null &&
                            imageIds.length != 0) {
                          setState(() => loading = true);
                          print('pressed2');
                          Response result;
                          if (editing) {
                            result = await VendorDBService.updateVendor(
                                widget.vendor.id,
                                name,
                                vendorLatLng,
                                tags,
                                imageIds,
                                description);
                          } else {
                            //uploading images individually
                            //adding their ids to list
                            for (var imgAsset in images) {
                              String path =
                                  await FlutterAbsolutePath.getAbsolutePath(
                                      imgAsset.identifier);

                              dio.Response imgResponse =
                                  await VendorDBService.addImage(path);
                              if (imgResponse.statusCode == 200) {
                                String imgId = imgResponse.data['_id'];
                                imageIds.add(imgId);
                              } else {
                                print(imgResponse.statusCode);
                              }
                            }

                            result = await VendorDBService.addVendor(name,
                                vendorLatLng, tags, imageIds, description);
                          }
                          setState(() => loading = false);

                          if (result.statusCode != 200) {
                            setState(() {
                              print(result.statusCode);
                              error = 'could not add vendor';
                            });
                          } else {
                            //String id = jsonDecode(result.body)['_id'];
                            //print(jsonDecode(result.body));
                            //print(id);
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
