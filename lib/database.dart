import 'dart:io';
import 'dart:convert';

class FileKVStore {
  final File file;

  FileKVStore(this.file);

  Future<Map<String, dynamic>> load() async {
    try {
      if (await file.exists()) {
        final contents = await file.readAsString();
        return Map<String, dynamic>.from(json.decode(contents));
      }
    } catch (e) {
      // nothing here
    }
    return {};
  }

  Future<void> save(Map<String, dynamic> data) async {
    await file.writeAsString(json.encode(data));
  }
}

void saveDB(data) async {
  final pomodb = FileKVStore(File('pomodb.json'));
  await pomodb.save(data);
}

Future<Map<String, dynamic>> loadDB() async {
  final pomodb = FileKVStore(File('pomodb.json'));
  return pomodb.load();
}
