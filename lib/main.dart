import 'package:doomsday_register/new_entry_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'EntryHelper.dart' as helper;

void main() => runApp(MaterialApp(home: HomePage()));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _listOfEntries = [];
  DateTime _firstEntryDate;

  @override
  void initState() {
    super.initState();

    helper.readData().then((value) {
      setState(() {
        _listOfEntries = json.decode(value);
      });

      if (_listOfEntries != null && _listOfEntries.length > 0)
        _firstEntryDate = DateTime.fromMicrosecondsSinceEpoch(
            int.parse(_listOfEntries[0]["timestamp"].toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_listOfEntries.length > 0
              ? "Day " +
                  ((DateTime.fromMicrosecondsSinceEpoch(DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day)
                                          .microsecondsSinceEpoch -
                                      int.parse(_listOfEntries[0]["timestamp"]
                                          .toString()))
                                  .microsecondsSinceEpoch /
                              8.64e10)
                          .floor())
                      .toString() +
                  " of quarantine"
              : "Covid-19 outbreak"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.bug_report),
              onPressed: () async {
                print(await helper.readData());
              },
            ),
            IconButton(
              icon: Icon(Icons.restore_from_trash),
              onPressed: () async {
                helper.deleteFile();
                _listOfEntries = List();
                setState(() {});
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewEntryPage(_listOfEntries)))
                  .then((value) => setState(() => null)),
            ),
            FutureBuilder(
                future: helper.readData(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      return _getBody();
                  }
                }),
          ],
        ));
  }

  Widget _getBody() {
    return _listOfEntries.length == 0
        ? RaisedButton(
            onPressed: () async {
              Map<String, dynamic> firstEntry = Map();
              DateTime initialDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(DateTime.now().year,
                      DateTime.now().month, DateTime.now().day),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day));

              firstEntry["timestamp"] =
                  initialDate.microsecondsSinceEpoch.toString();
              firstEntry["data"] = "Quarantine started.";

              _listOfEntries.add(firstEntry);
              helper.writeData(_listOfEntries);

              setState(() {});

              print(firstEntry.toString());
            },
            child: Text("When did your quarantine started?"),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemCount: _listOfEntries.length,
            reverse: true,
            itemBuilder: (context, index) {
              print("Index = $index");
              print("Diff  = ${this._getDayCountAsString(index)}");

              DateTime date = DateTime.fromMicrosecondsSinceEpoch(
                  int.parse(_listOfEntries[index]["timestamp"].toString()));

              int timespan = ((date.microsecondsSinceEpoch -
                          DateTime.fromMicrosecondsSinceEpoch(int.parse(
                                  _listOfEntries[0]["timestamp"].toString()))
                              .microsecondsSinceEpoch) /
                      8.64e10)
                  .floor();
              return Container(
                margin: EdgeInsets.only(
                  top: 15,
                ),
                child: Text(_listOfEntries[index].toString()),
              );
            });
  }

  String _getDayCountAsString(int index) {
    if (this._listOfEntries == null || this._listOfEntries.length == 0)
      return null;

    return ((DateTime.fromMicrosecondsSinceEpoch(int.parse(
                            _listOfEntries[index]["timestamp"].toString()) -
                        int.parse(_listOfEntries[0]["timestamp"].toString()))
                    .microsecondsSinceEpoch /
                8.64e10)
            .floor())
        .toString();
  }
}
