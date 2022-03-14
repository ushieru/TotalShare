import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WrapServerSocket {
  late String address;
  final Map<String, Function(Socket socket, Uint8List payload, {dynamic meta})>
      _handlers = {};
  final Map<String, BytesBuilder> _builders = {};

  dynamic _meta;
  String? _currentHandlerName;
  Function(Socket socket, Uint8List payload, {dynamic meta})? _currentHandler;

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
    _builders[socketKey] = BytesBuilder(copy: false);
    socket.listen((payload) {
      final payloadString = String.fromCharCodes(payload);
      if (payloadString.contains('payload')) {
        _setHandler(payloadString);
      } else if (payloadString == 'DONE') {
        _drainPayloadToAHandler(socket, _builders[socketKey]!);
      } else if (_currentHandler != null) {
        _builders[socketKey]!.add(payload);
      }
    });
  }

  _setHandler(String payload) {
    _meta = json.decode(payload);
    final handler = _handlers[_meta['action']];
    if (handler == null) return;
    _currentHandlerName = _meta['action'];
    debugPrint('[SET HANDLER] $_currentHandlerName');
    _currentHandler = handler;
  }

  _drainPayloadToAHandler(Socket socket, BytesBuilder builder) {
    debugPrint('[TRIGGER HANDLER] $_currentHandlerName');
    Uint8List dt = builder.toBytes();
    Uint8List payload = dt.buffer.asUint8List(0, dt.buffer.lengthInBytes);
    _currentHandler!(socket, payload, meta: _meta);
    builder.clear();
    _currentHandler = null;
    _currentHandlerName = null;
    debugPrint('[CLEAR HANDLER]');
  }

  addHandler(String action,
      Function(Socket socket, Uint8List payload, {dynamic meta}) handler) {
    _handlers[action] = handler;
  }
}
