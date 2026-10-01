import 'package:shared_preferences/shared_preferences.dart';

class Sharedprefs {
  final SharedPreferences prefs;
  Sharedprefs({required this.prefs});

  // Private generic method for retrieving data from shared preferences
  dynamic _getData(String key) {
    // Retrieve data from shared preferences
    var value = prefs.get(key);

    // Easily log the data that we retrieve from shared preferences

    // Return the data that we retrieve from shared preferences
    return value;
  }

// Private method for saving data to shared preferences
  void _saveData(String key, dynamic value) {
    // Easily log the data that we save to shared preferences

    // Save data to shared preferences
    if (value is String) {
      prefs.setString(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is List<String>) {
      prefs.setStringList(key, value);
    }
  }

//get and set user type
  set userType(bool value) => _saveData('USER_TYPE', value);
  bool get userType => _getData('USER_TYPE') ?? false;
}
