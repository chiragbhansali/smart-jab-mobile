import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorage {
  Future<File> get _storageFile async {
    final directory = await getApplicationDocumentsDirectory();

    return File("${directory.path}/storage.txt");
  }

  Future<dynamic> setItem(String key, dynamic data) async {
    final file = await _storageFile;
    String dataString = await file.readAsString();
    var storage = jsonDecode(dataString);
    storage[key] = data;
    await file.writeAsString(jsonEncode(storage));
    return data;
  }

  Future<dynamic> getItem(String key) async {
    final file = await _storageFile;
    String dataString = await file.readAsString();
    var storage = jsonDecode(dataString);
    return storage[key];
  }

  Future<dynamic> initIfEmpty() async {
    try {
      final file = await _storageFile;
      String dataString = await file.readAsString();
      print(dataString);
    } catch (e) {
      final file = await _storageFile;
      await file.writeAsString("{}");
    }
  }
}
