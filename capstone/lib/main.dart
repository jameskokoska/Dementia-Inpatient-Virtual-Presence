import 'dart:convert';
import 'dart:math';
import 'package:animations/animations.dart';
import 'package:camera/camera.dart';
import 'package:capstone/pages/CallPage.dart';
import 'package:capstone/widgets/CameraView.dart';
import 'package:capstone/pages/Home.dart';
import 'package:capstone/struct/databaseGlobal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone/database/tables.dart';

void main() async {
  database = constructDb();
  entireAppLoaded = false;
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await initializeDatabase();
  await initializeSettings();
  runApp(const PageScaffold());
  // initNotificationListener();
}

Random random = Random();
int randomInt = random.nextInt(100);
late bool entireAppLoaded;
late PackageInfo packageInfoGlobal;
Map<String, dynamic> appStateSettings = {};

//Initialize default values in database
Future<bool> initializeDatabase() async {
  //Initialize default categories (if length is less than 0 we can create some fake users here)
  return true;
}

Future<bool> updateSettings(setting, value,
    {List<int> pagesNeedingRefresh = const [],
    bool updateGlobalState = true}) async {
  final prefs = await SharedPreferences.getInstance();
  appStateSettings[setting] = value;
  await prefs.setString('userSettings', json.encode(appStateSettings));

  // if (updateGlobalState == true) appStateKey.currentState?.refreshAppState();
  // //Refresh any pages listed
  // for (int page in pagesNeedingRefresh) {
  //   if (page == 0) {
  //     homePageStateKey.currentState?.refreshState();
  //   }
  // }

  return true;
}

Map<String, dynamic> getSettingConstants(Map<String, dynamic> userSettings) {
  Map<String, dynamic> themeSetting = {
    "system": ThemeMode.system == ThemeMode.light
        ? Brightness.light
        : Brightness.dark,
    "light": Brightness.light,
    "dark": Brightness.dark,
  };

  Map<String, dynamic> userSettingsNew = {...userSettings};
  userSettingsNew["theme"] = themeSetting[userSettings["theme"]];
  return userSettingsNew;
}

Future<Map<String, dynamic>> getUserSettings() async {
  Map<String, dynamic> userPreferencesDefault = {
    "theme": "system",
    "backend-ip": "http://192.168.2.68:5000",
    "duration-listen": "3500",
    "duration-wait": "10500",
  };

  final prefs = await SharedPreferences.getInstance();
  String? userSettings = prefs.getString('userSettings');

  try {
    if (userSettings == null) {
      throw ("no settings on file");
    }
    debugPrint("Found user settings on file");

    var userSettingsJSON = json.decode(userSettings);
    //Set to defaults if a new setting is added, but no entry saved
    userPreferencesDefault.forEach((key, value) {
      if (userSettingsJSON[key] == null) {
        userSettingsJSON[key] = userPreferencesDefault[key];
      }
    });
    return userSettingsJSON;
  } catch (e) {
    debugPrint("There was an error, settings corrupted");
    await prefs.setString('userSettings', json.encode(userPreferencesDefault));
    return userPreferencesDefault;
  }
}

Future<bool> initializeSettings() async {
  Map<String, dynamic> userSettings = await getUserSettings();

  appStateSettings = userSettings;

  packageInfoGlobal = await PackageInfo.fromPlatform();
  return true;
}

class PageScaffold extends StatelessWidget {
  const PageScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: MediaQuery.of(context).platformBrightness,
      ),
      home: const NavigationStack(),
    );
  }
}

class NavigationStack extends StatefulWidget {
  const NavigationStack({super.key});

  @override
  State<NavigationStack> createState() => _NavigationStackState();
}

class _NavigationStackState extends State<NavigationStack> {
  int currentPageIndex = 0;
  User? user;

  _setUser(User userPassed) {
    setState(() {
      user = userPassed;
    });
    currentPageIndex = 1;
  }

  _setCurrentPageIndex(int indexPassed) {
    setState(() {
      currentPageIndex = indexPassed;
      if (indexPassed == 0) {
        user = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: currentPageIndex,
      children: [
        HomePage(setUser: _setUser),
        CallPage(user: user, setCurrentPageIndex: _setCurrentPageIndex),
      ],
    );
  }
}
