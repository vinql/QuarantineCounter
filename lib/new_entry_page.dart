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
        title: Text("Day x"),
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
              newEntry["timestamp"] = "19";

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