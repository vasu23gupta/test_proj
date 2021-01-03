import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:test_proj/models/customUser.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/vendor_details.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/services/database.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/shared/loading.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:dio/dio.dart' as dio;

class AddVendor extends StatefulWidget {
  final LatLng userLoc;
  AddVendor({this.userLoc});
  @override
  _AddVendorState createState() => _AddVendorState();
}

class _AddVendorState extends State<AddVendor> {
  List<Asset> images = List<Asset>();
  MapController controller = new MapController();
  List<String> imageIds = new List<String>();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  List<Marker> markers = [];
  LatLng vendorLatLng;
  String error = '';
  String currentTag;
  HashSet<String> tags = new HashSet<String>();
  TextEditingController addTagController = TextEditingController();

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

  String name = '';
  @override
  Widget build(BuildContext context) {
    LatLng userLoc = widget.userLoc;
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

    void _handleTap(LatLng point) {
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
                          onTap: _handleTap,
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
                            currentTag = '';
                          });
                        }
                      },
                    ),
                    //submit button:
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      color: Colors.pink[400],
                      child: Text(
                        'ADD',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        //validation
                        if (_formKey.currentState.validate() &&
                            vendorLatLng != null &&
                            tags.isNotEmpty &&
                            images.length != 0) {
                          setState(() => loading = true);
                          VendorDBService vdbs = new VendorDBService();

                          //uploading images individually
                          //adding their ids to list
                          for (var imgAsset in images) {
                            String path =
                                await FlutterAbsolutePath.getAbsolutePath(
                                    imgAsset.identifier);

                            dio.Response imgResponse =
                                await vdbs.addImage(path);
                            if (imgResponse.statusCode == 200) {
                              String imgId = imgResponse.data['_id'];
                              imageIds.add(imgId);
                            } else {
                              print(imgResponse.statusCode);
                            }
                          }
                          for (var pointer in imageIds) {
                            print(pointer);
                          }
                          //String id = createId(user.uid);
                          Response result;
                          result = await vdbs.addVendor(
                              name, vendorLatLng, tags, imageIds);
                          // try {
                          //   // result = await VendorDatabaseService(id: id)
                          //   //     .updateVendorData(name, vendorLatLng, tags);
                          //   result = await VendorDBService()
                          //       .addVendor(name, vendorLatLng, tags);
                          //   print("result: " + result.toString());
                          // } catch (e) {
                          //   print(e.toString());
                          // }
                          setState(() => loading = false);
                          // if (result == null) {
                          //   setState(() {
                          //     error = 'could not add vendor';
                          //   });
                          if (result.statusCode != 200) {
                            setState(() {
                              print(result.statusCode);
                              error = 'could not add vendor';
                            });
                          } else {
                            //String id = jsonDecode(result.body)['_id'];
                            //print(jsonDecode(result.body));
                            //print(id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VendorDetails(
                                  vendor: Vendor.fromJson(
                                    jsonDecode(result.body),
                                  ),
                                ),
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
