import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// This service is responsible for talking with the OS to see if anything was
/// shared with the application.
class ShareService {
  void Function(String)? onDataReceived;

  ShareService() {
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        // If sharing causes the app to be resumed, we'll check to see if we got any
        // shared data
        SystemChannels.lifecycle.setMessageHandler((msg) async {
          if (msg?.contains("resumed") ?? false) {
            getSharedData().then((String data) {
              // Nothing was shared with us :(
              if (data.isEmpty || data == "") {
                return;
              }

              // We got something! Inform our listener.
              onDataReceived?.call(data);
            });
          }
          return;
        });
      }
    }
  }

  /// Invoke a method on our platform, telling it to give us any shared data
  /// it has
  Future<String> getSharedData() async {
    // TODO: Add support for iOS
    if (Platform.isAndroid) {
      return await const MethodChannel('com.petersalmon.later_flutter')
              .invokeMethod("getSharedData") ??
          "";
    } else {
      return "";
    }
  }
}
