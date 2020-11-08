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

  String createId(String uid) {
    DateTime now = DateTime.now();

    return uid +
        now.year.toString() +
        now.month.toString() +
        now.day.toString() +
        now.hour.toString() +
        now.minute.toString() +
        now.second.toString();
  }

  String name = '';
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    String error = '';
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
                        child: defaultMap(controller, userLoc),
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
                          if (_formKey.currentState.validate()) {
                            setState(() => loading = true);
                            String id = createId(user.uid);
                            dynamic result;
                            try {
                              result = await VendorDatabaseService(id: id)
                                  .updateVendorData(name);
                            } catch (e) {
                              print(e.toString());
                            }
                            if (result == null) {
                              setState(() {
                                error = 'could not add vendor';
                                loading = false;
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
