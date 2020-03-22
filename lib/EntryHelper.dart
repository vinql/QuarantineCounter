import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

Future<File> getFile() async {
  Directory directory = await getApplicationDocumentsDirectory();
  return File("${directory.path}/appdata.json");
}

Future<File> writeData(List data) async {
  final file = await getFile();
  return file.writeAsString(json.encode(data));
}

Future<String> readData() async {
  final file = await getFile();
  return file.readAsString();
}

Future<void> deleteFile() async {
  final File file = await getFile();
  file.delete();
}