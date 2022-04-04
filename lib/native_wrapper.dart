import 'dart:async';

import 'package:flutter/services.dart';

class NativeWrapper {
  // ****************************** CONSTANTS ****************************** //

  static const channel = 'com.svprdga.apitest/main';

  static const nativeEventStartScreenShare = 'start_screen_share';

  static const dartEventScreenShareReady = 'screen_share_ready';

  // ********************************* VARS ******************************** //

  final MethodChannel _platform = const MethodChannel(channel);

  final _nativeCallsController = StreamController<MethodCall>();

  late final Stream<MethodCall> nativeStream;

  // ***************************** CONSTRUCTORS **************************** //

  NativeWrapper() {
    nativeStream = _nativeCallsController.stream.asBroadcastStream();
    _platform.setMethodCallHandler(
      (call) async => _nativeCallsController.sink.add(call),
    );
  }

  //***************************** PUBLIC METHODS *************************** //

  Future<void> startScreenShare() async {
    await _platform.invokeMethod(nativeEventStartScreenShare);
  }
}
