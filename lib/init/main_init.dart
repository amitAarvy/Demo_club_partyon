import 'package:club/core/app_const/hive_const.dart';
import 'package:club/local_db/hive_db.dart';
import 'package:hive/hive.dart';

class MainInit {
  static Future<bool> checkFirstInstall() async {
    Box box = await HiveDB.openBox();
    bool isFirstInstall =
        await HiveDB.getKey(box, HiveConst.isFirstInstall) ?? true;
    if (isFirstInstall) {
      await HiveDB.putKey(box, HiveConst.isFirstInstall, false);
    }
    return isFirstInstall;
  }

  static Future<bool> isFirstPhylloLaunch() async {
    Box box = await Hive.openBox(HiveConst.phylloBox);
    bool isFirstPhylloLaunch = await box.get(HiveConst.isFirstPhylloInstall) ?? true;
    if (isFirstPhylloLaunch) {
      await box.put(HiveConst.isFirstPhylloInstall, false);
    }
    return isFirstPhylloLaunch;
  }
}
