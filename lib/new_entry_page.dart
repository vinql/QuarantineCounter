import 'package:flutter/material.dart';
import 'EntryHelper.dart' as helper;

class NewEntryPage extends StatefulWidget {

  NewEntryPage(this.data);
  final List data;

  @override
  _NewEntryPageState createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report: day " +
                  ((DateTime.fromMicrosecondsSinceEpoch(DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day)
                                          .microsecondsSinceEpoch -
                                      int.parse(widget.data[0]["timestamp"]
                                          .toString()))
                                  .microsecondsSinceEpoch /
                              8.64e10)
                          .floor())
                      .toString() +
                  " of quarantine"),
      ),
      body: SingleChildScrollView(child: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              Map<String, dynamic> newEntry = Map();
              newEntry["text"] = _controller.text;

              DateTime date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
              newEntry["timestamp"] = date.microsecondsSinceEpoch.toString();

              // Avoid two entries at the same day
              // Reason: I don't want to.
              if (widget.data.length > 1 && newEntry["timestamp"] == widget.data.last["timestamp"])
                widget.data.removeLast();

              widget.data.add(newEntry);

              helper.writeData(widget.data);

              Navigator.pop(context);
            },
          )
        ],
      ),),
    );
  }
}