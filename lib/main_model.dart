import 'dart:convert';
import 'package:api100ms_test/data.dart';
import 'package:api100ms_test/native_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class MainModel extends ChangeNotifier
    implements HMSUpdateListener, HMSActionResultListener {
  // ***************************** INJECTED VARS *************************** //

  final Logger _log;
  final NativeWrapper _native;

  // ********************************* VARS ******************************** //

  final _userId = const Uuid().v4();

  HMSSDK? _hmsSdk;

  HMSSDK? get hmsSdk => _hmsSdk;

  set hmsSdk(HMSSDK? value) {
    if (value != _hmsSdk) {
      _hmsSdk = value;
      notifyListeners();
    }
  }

  bool _isScreenShareActive = false;

  bool get isScreenShareActive => _isScreenShareActive;

  set isScreenShareActive(bool value) {
    if (value != _isScreenShareActive) {
      _isScreenShareActive = value;
      notifyListeners();
    }
  }

  // ****************************** CONSTANTS ****************************** //

  MainModel(this._log, this._native) {
    _native.nativeStream.listen((event) {
      if (event.method == NativeWrapper.dartEventScreenShareReady) {
        notifyListeners();
      }
    });
  }

  //***************************** PUBLIC METHODS *************************** //

  Future<void> joinRoom() async {
    try {
      // Get auth token
      final response = await http.post(
        Uri.parse(
          url,
        ),
        headers: {
          'subdomain': subdomain,
        },
        body: {
          'code': code,
          'room_id': roomId,
          'user_id': _userId,
          'role': 'streamer',
        },
      );

      if (response.statusCode >= 400) {
        throw Exception('Get token error: ${response.body}');
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      final token = body['token'] as String;

      // Create config
      final config = HMSConfig(authToken: token, userName: 'user_streamer');

      // Join room
      hmsSdk = HMSSDK();
      hmsSdk?.build();
      hmsSdk?.addUpdateListener(listener: this);
      hmsSdk?.join(config: config);
    } catch (e) {
      _log.e(e.toString());
    }
  }

  @override
  void onJoin({required HMSRoom room}) {
    _log.i('Joined to room ${room.name}');
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    _log.i('Room update');
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    _log.i('Peer update');
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    _log.i('Track update');

    if (trackUpdate == HMSTrackUpdate.trackAdded &&
        peer.name == 'user_streamer') {
      isScreenShareActive = true;
    } else if (trackUpdate == HMSTrackUpdate.trackRemoved &&
        peer.name == 'user_streamer') {
      isScreenShareActive = false;
    }
  }

  @override
  void onError({required HMSException error}) {
    _log.e('Error: ${error.message}');
  }

  @override
  void onMessage({required HMSMessage message}) {
    _log.i('Message: ${message.message}');
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {
    _log.i('Role change request');
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    _log.i('Update speakers');
  }

  @override
  void onReconnecting() {
    _log.i('Reconnecting...');
  }

  @override
  void onReconnected() {
    _log.i('Successfully reconnected');
  }

  @override
  void onChangeTrackStateRequest({
    required HMSTrackChangeRequest hmsTrackChangeRequest,
  }) {
    _log.i('Change track state request');
  }

  @override
  void onRemovedFromRoom({
    required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer,
  }) {
    _log.i('Removed from room');
  }

  void leaveRoom() {
    _hmsSdk?.leave();
    hmsSdk = null;
  }

  Future<void> startScreenShare() async {
    _hmsSdk?.startScreenShare();
  }

  Future<void> stopScreenShare() async {
    _hmsSdk?.stopScreenShare();
  }

  @override
  void onException({
    HMSActionResultListenerMethod? methodType,
    Map<String, dynamic>? arguments,
    required HMSException hmsException,
  }) {
    _log.e('Error when screen sharing: ${hmsException.message}');
  }

  @override
  void onSuccess({
    HMSActionResultListenerMethod? methodType,
    Map<String, dynamic>? arguments,
  }) {
    _log.i('Screen Share started');
  }
}
