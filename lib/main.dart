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

  @override
  void initState() {
    super.initState();

    helper.readData().then((value) {
      setState(() {
        _listOfEntries = json.decode(value);
      });
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
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 5, left: 12.0, right: 12.0),
          child: FutureBuilder(
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
        ));
  }

  Widget _getBody() {
    return _listOfEntries.length == 0
        ? Center(
            child: RaisedButton(
              onPressed: () async {
                Map<String, dynamic> firstEntry = Map();
                DateTime initialDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(DateTime.now().year,
                        DateTime.now().month, DateTime.now().day),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(DateTime.now().year,
                        DateTime.now().month, DateTime.now().day));

                firstEntry["timestamp"] =
                    initialDate.microsecondsSinceEpoch.toString();
                firstEntry["text"] = "Quarantine started.";

                _listOfEntries.add(firstEntry);
                helper.writeData(_listOfEntries);

                setState(() {});

                print(firstEntry.toString());
              },
              child: Text("When did your quarantine started?"),
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RaisedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    itemBuilder: (context, index) {
                      print("Index = $index");
                      print(
                          "Diff  = ${this._getDayCountAsString(_listOfEntries.reversed.toList()[index]["timestamp"])}");

                      return Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 2),
                                  blurRadius: 5)
                            ]),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Day ", style: _defaultText(25)),
                                Text(
                                  _getDayCountAsString(_listOfEntries.reversed
                                      .toList()[index]["timestamp"]),
                                  style: _boldText(25),
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                                "${DateTime.fromMicrosecondsSinceEpoch(int.parse(_listOfEntries.reversed.toList()[index]["timestamp"].toString())).day}/${DateTime.fromMicrosecondsSinceEpoch(int.parse(_listOfEntries.reversed.toList()[index]["timestamp"].toString())).month}/${DateTime.fromMicrosecondsSinceEpoch(int.parse(_listOfEntries.reversed.toList()[index]["timestamp"].toString())).year}"),
                            SizedBox(height: 10),
                            Container(
                                child: Text(
                              _listOfEntries.reversed.toList()[index]["text"],
                              style: _defaultText(20),
                            )),
                          ],
                        ),
                      );
                    }),
              ),
            ],
          );
  }

  String _getDayCountAsString(String ts) {
    if (this._listOfEntries == null || this._listOfEntries.length == 0)
      return null;

    return ((DateTime.fromMicrosecondsSinceEpoch(int.parse(ts) -
                        int.parse(_listOfEntries[0]["timestamp"].toString()))
                    .microsecondsSinceEpoch /
                8.64e10)
            .floor())
        .toString();
  }

  TextStyle _defaultText(double fontSize) => TextStyle(
        fontSize: fontSize,
      );

  TextStyle _boldText(double fontSize) =>
      TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold);
}
