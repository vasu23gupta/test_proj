import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:test_proj/models/customUser.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/services/database.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/shared/loading.dart';
import 'package:latlong/latlong.dart';

class AddVendor extends StatefulWidget {
  @override
  _AddVendorState createState() => _AddVendorState();
}

class _AddVendorState extends State<AddVendor> {
  MapController controller = new MapController();
  LatLng userLoc = new LatLng(28.612757, 77.230445);
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  List<Marker> markers = [];
  LatLng vendorLatLng;
  String error = '';

  String createId(String uid) {
    DateTime now = DateTime.now();
    return uid +
        now.year.toString() +
        now.month.toString() +
        now.day.toString() +
        now.hour.toString() +
        now.minute.toString() +
        now.second.toString() +
        now.millisecond.toString();
  }

  String name = '';
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);

    void _handleTap(LatLng point) {
      print(point);
      setState(() {
        markers = [];
        vendorLatLng = point;
        markers.add(Marker(
            width: 45.0,
            height: 45.0,
            point: point,
            builder: (context) => new Container(
                  child: IconButton(
                    icon: Icon(Icons.location_on),
                    iconSize: 80.0,
                    onPressed: () {},
                  ),
                )));
      });
    }

    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.brown[50],
            appBar: AppBar(
              title: Text('Add Vendor'),
              backgroundColor: Colors.brown[400],
              elevation: 0.0,
            ),
            body: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Vendor Name'),
                          validator: (val) =>
                              val.isEmpty ? 'Enter a name' : null,
                          onChanged: (val) {
                            setState(() => name = val);
                          }),
                      SizedBox(
                        height: 300.0,
                        width: 350.0,
                        child: new FlutterMap(
                          mapController: controller,
                          options: new MapOptions(
                            zoom: 13.0, center: userLoc,
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
                          if (_formKey.currentState.validate() &&
                              vendorLatLng != null) {
                            setState(() => loading = true);
                            String id = createId(user.uid);
                            dynamic result;
                            try {
                              result = await VendorDatabaseService(id: id)
                                  .updateVendorData(name, vendorLatLng);
                            } catch (e) {
                              print(e.toString());
                            }
                            setState(() => loading = false);
                            if (result == null) {
                              setState(() {
                                error = 'could not add vendor';
                              });
                            }
                          }
                        },
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                      )
                    ],
                  ),
                )),
          );
  }
}
