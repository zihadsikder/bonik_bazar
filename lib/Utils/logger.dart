
import 'package:flutter/foundation.dart';

/// For development only
/// visibleForTesting
class Logger {


  static error(dynamic error, {String? name = "LOG"}) {
    if (kDebugMode) {



    }
  }

  static impornant(dynamic value, {String? name}) {

  }

  static throwTestError() {
    throw "Test Exeption";
  }
}




class Log {
  void printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern
        .allMatches(text)
        .forEach((RegExpMatch match) => print(match.group(0)));
  }
}
