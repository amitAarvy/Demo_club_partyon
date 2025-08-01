import 'package:hive/hive.dart';

class HiveDB {
  static openBox() async => await Hive.openBox('partyOn');

  static getKey(Box box, String keyName) async => await box.get(keyName);

  static putKey(Box box, String keyName, dynamic value) async =>
      await box.put(keyName, value);
}
