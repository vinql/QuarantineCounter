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
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                List l = List();
                Map<String, dynamic> m = Map();

                m["timestamp"] = DateTime(DateTime.now().year,
                        DateTime.now().month, DateTime.now().day)
                    .microsecondsSinceEpoch
                    .toString();

                for (int i = 0; i < 10; i++) {
                  m["text"] = "Entry no. $i";
                  l.add(m);
                }

                _listOfEntries = l;

                helper.writeData(l).then((value) => setState(() => null));
              },
            ),
          ],
        ),
        body: FutureBuilder(
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
            }));
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
              firstEntry["text"] = "Quarantine started.";

              _listOfEntries.add(firstEntry);
              helper.writeData(_listOfEntries);

              setState(() {});

              print(firstEntry.toString());
            },
            child: Text("When did your quarantine started?"),
          )
        : Column(
            children: <Widget>[
              RaisedButton(
                child: Row(
                  children: <Widget>[Icon(Icons.add), Text("New entry")],
                ),
                onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewEntryPage(_listOfEntries)))
                    .then((value) => setState(() => null)),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: _listOfEntries.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      print("Index = $index");
                      print("Diff  = ${this._getDayCountAsString(index)}");

                      DateTime date = DateTime.fromMicrosecondsSinceEpoch(
                          int.parse(
                              _listOfEntries[index]["timestamp"].toString()));

                      int timespan = ((date.microsecondsSinceEpoch -
                                  DateTime.fromMicrosecondsSinceEpoch(int.parse(
                                          _listOfEntries[0]["timestamp"]
                                              .toString()))
                                      .microsecondsSinceEpoch) /
                              8.64e10)
                          .floor();
                      return Container(
                        height: 50,
                        margin: EdgeInsets.only(
                          top: 15,
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(_listOfEntries[index]["text"])
                          ],
                        ),
                      );
                    }),
              ),
            ],
          );
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
