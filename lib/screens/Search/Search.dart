import 'package:flutter/material.dart';
import 'package:test_proj/models/vendorData.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/models/vendor.dart';

import '../vendor_details.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Widget buildSuggestions() {
    //print('enter');
    var selectedIndex;

    return Column(
      children: <Widget>[
        new Expanded(
          child: this.searchResults.length != 0
              ? new ListView.builder(
                  itemCount: this.searchResults.length,
                  itemBuilder: (context, index) {
                    //entered = 'true';
                    Vendor resultList = this.searchResults[index];
                    //print(entered);
                    return ListTile(
                      onTap: () async {
                        selectedIndex = index;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VendorDetails(
                              vendor: resultList,
                            ),
                          ),
                        );
                        //Navigator.pop(context);
                      },
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resultList.name,
                            style: TextStyle(fontSize: 20),
                          ),
                          Row(
                            children: resultList.tags
                                .map((x) => Text(x,
                                    style: TextStyle(color: Colors.grey)))
                                .toList(),
                          ),
                          Divider()
                        ],
                      ),
                    );
                  },
                )
              : Text('Enter tags/name'),
        )
      ],
    );
  }

  //String query;
  List<dynamic> searchResults = [];
  ListView suggestions;
  List<String> tags = ['1', '2,', '3', '4'];
  TextEditingController query = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          controller: query,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.white),
            hintText: "Search...",
            hintStyle: TextStyle(color: Colors.white),
          ),
          onChanged: (value) async {
            List<dynamic> sR = [];
            if (value.length != 0) {
              sR = await VendorDBService().getVendorsSearch(value);
            }
            setState(() {
              this.searchResults = sR;
              //print(this.searchResults.length);
              //var entered = 'false';
              //this.suggestions =
              ///print(suggestions);
            });
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                query.text = '';
                searchResults = [];
              });
            },
          )
        ],
      ),
      body: buildSuggestions(),
      /* Center(
          child: this
              .suggestions /* (searchResults.length != 0)
            ? buildSuggestions()
            : Text('Enter tags/name'), */
          ), */
    );
  }
}
