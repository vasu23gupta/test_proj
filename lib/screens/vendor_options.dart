import 'package:flutter/material.dart';
import 'package:test_proj/shared/constants.dart';

class Options extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //https://stackoverflow.com/questions/58144948/easiest-way-to-add-3-dot-pop-up-menu-appbar-in-flutter
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'Edit':
            print(value);
            break;
          case 'Report':
            //https://stackoverflow.com/questions/54480641/flutter-how-to-create-forms-in-popup
            showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return Report();
                });
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return {'Edit', 'Report'}.map((String choice) {
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
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  String selectedReport = '';
  List<String> reasons = ['Reason 1', 'Reason 2', 'Reason 3', 'Other'];
  String otherReportString = '';

  void updateReport(String report) {
    setState(() {
      selectedReport = report;
    });
  }

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
                        onPressed: () {
                          if (selectedReport == reasons[3])
                            selectedReport += " " + otherReportString;

                          print(selectedReport);
                        },
                      ),
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
