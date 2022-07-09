import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WrapServerSocket {
  late String address;

  /// key -> handlerName
  /// value -> handler function
  final Map<String, Function(Socket socket, Uint8List payload, {dynamic meta})>
      _handlers = {};

  /// key -> socketKey
  /// value -> current handlerName
  final Map<String, String> _workers = {};

  /// key -> socketKey
  /// value -> current metadata
  final Map<String, dynamic> _metadata = {};

  WrapServerSocket._(callback) {
    ServerSocket.bind(InternetAddress.anyIPv4, 0).then((serverSocket) {
      NetworkInfo().getWifiIP().then((wifiIP) {
        address = '$wifiIP:${serverSocket.port}';
        serverSocket.listen(_handlerSocket);
        callback(this);
      });
    });
  }

  static Future<WrapServerSocket> create() async {
    Completer<WrapServerSocket> completer = Completer();
    WrapServerSocket._((WrapServerSocket wrapServerSocket) {
      completer.complete(wrapServerSocket);
    });
    return completer.future;
  }

  _handlerSocket(Socket socket) {
    final socketKey = socket.remoteAddress.toString();
    socket.listen((payload) {
      final payloadString = String.fromCharCodes(payload);
      if (payloadString.contains('payload')) {
        debugPrint('[GET ACTION AND METADATA]');
        final payloadJson = json.decode(payloadString);
        final handlerName = payloadJson['action'] as String;
        if (!_handlers.containsKey(handlerName)) return;
        _workers[socketKey] = handlerName;
        _metadata[socketKey] = payloadJson;
        debugPrint('[SET HANDLER] $handlerName');
      } else if (payloadString == 'DONE') {
        _workers.remove(socketKey);
        _metadata.remove(socketKey);
        debugPrint('[CLEAR HANDLER]');
      } else if (_workers.containsKey(socketKey)) {
        debugPrint('[RECEIVE PAYLOAD]');
        _handlers[_workers[socketKey]]!(socket, payload,
            meta: _metadata[socketKey]);
      }
    });
  }

  addHandler(String action,
      Function(Socket socket, Uint8List payload, {dynamic meta}) handler) {
    _handlers[action] = handler;
  }
}
