import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ClientSocketController extends GetxController {
  RxBool isConnected = false.obs;
  Socket? socket;

  Future<void> connect(String serverAddress, String name) async {
    final serverAddressSplit = serverAddress.split(':');
    debugPrint('Try connect to $serverAddressSplit');
    try {
      socket = await Socket.connect(
        serverAddressSplit[0],
        int.parse(serverAddressSplit[1]),
      );
      isConnected.toggle();
      sendPayload('register',
          middleware: (Socket socket) async => socket.write(name));
    } catch (e) {
      debugPrint('Error connect to $serverAddressSplit');
      debugPrint('Error: $e');
    }
  }

  Future<void> sendPayload(
    String action, {
    Future Function(Socket socket)? middleware,
    Map<String, String>? options,
  }) async {
    if (socket == null) return;
    var payload = {
      'key': 'payload',
      'action': action,
    };
    if (options != null) payload.addAll(options);
    socket!.write(json.encode(payload));
    await socket!.flush();
    await Future.delayed(const Duration(milliseconds: 200));
    if (middleware != null) await middleware(socket!);
    await Future.delayed(const Duration(milliseconds: 200));
    await socket!.flush();
    await Future.delayed(const Duration(milliseconds: 200));
    socket!.write('DONE');
  }
}
