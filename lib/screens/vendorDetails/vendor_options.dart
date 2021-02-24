import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/customUser.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/shared/loginPopup.dart';
import '../add_vendor.dart';

class VendorOptions extends StatelessWidget {
  final Vendor vendor;
  VendorOptions({this.vendor});
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    //https://stackoverflow.com/questions/58144948/easiest-way-to-add-3-dot-pop-up-menu-appbar-in-flutter
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'Edit':
            if (user.isAnonymous) {
              showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return LoginPopup(
                      to: "edit a vendor",
                    );
                  });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddVendor(
                    vendor: vendor,
                  ),
                ),
              );
            }
            break;
          case 'Report':
            if (user.isAnonymous) {
              showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return LoginPopup(
                      to: "report a vendor",
                    );
                  });
            } else {
              vendor.reported
                  ? print('reported')
                  : showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Report(vendor: vendor);
                      });
            }
            //https://stackoverflow.com/questions/54480641/flutter-how-to-create-forms-in-popup
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return {'Edit', if (!vendor.reported) 'Report'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }
}

class Report extends StatefulWidget {
  final Vendor vendor;
  Report({this.vendor});
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  String selectedReport = '';
  List<String> reasons = ['Reason 1', 'Reason 2', 'Reason 3', 'Other'];
  String otherReportString = '';
  String alertText = '';

  void updateReport(String report) {
    setState(() {
      selectedReport = report;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
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
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 400,
                  width: 400,
                  child: ListView(
                    children: <Widget>[
                      //1
                      RadioListTile(
                        value: reasons[0],
                        groupValue: selectedReport,
                        title: Text(reasons[0]),
                        onChanged: (report) {
                          updateReport(report);
                        },
                        selected: true,
                      ),
                      //2
                      RadioListTile(
                        value: reasons[1],
                        groupValue: selectedReport,
                        title: Text(reasons[1]),
                        onChanged: (report) {
                          updateReport(report);
                        },
                        selected: true,
                      ),
                      //3
                      RadioListTile(
                        value: reasons[2],
                        groupValue: selectedReport,
                        title: Text(reasons[2]),
                        onChanged: (report) {
                          updateReport(report);
                        },
                        selected: true,
                      ),
                      //other
                      Column(
                        children: [
                          RadioListTile(
                            value: reasons[3],
                            groupValue: selectedReport,
                            title: Text(reasons[3]),
                            onChanged: (report) {
                              updateReport(report);
                            },
                            selected: true,
                          ),
                          if (selectedReport == reasons[3])
                            TextFormField(
                                onChanged: (val) {
                                  setState(() {
                                    otherReportString = val;
                                  });
                                },
                                decoration: textInputDecoration.copyWith(
                                    hintText: "Please enter your issue here"))
                        ],
                      ),
                      RaisedButton(
                        color: Colors.pink[400],
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (selectedReport == reasons[3])
                            selectedReport += " " + otherReportString;

                          if (selectedReport.isNotEmpty) {
                            final response = await VendorDBService.reportVendor(
                                selectedReport,
                                widget.vendor,
                                await user.getIdToken());
                            if (response.statusCode == 200) {
                              setState(() {
                                alertText = "Reported successfully";
                                widget.vendor.reported = true;
                              });
                            } else {
                              setState(() {
                                alertText = "Could not report vendor";
                              });
                            }
                          }
                        },
                      ),
                      Text(alertText),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
