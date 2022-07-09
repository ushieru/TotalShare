import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:total_share/bin/wrap_server_socket.dart';

class ServerSocketController extends GetxController {
  RxString address = ''.obs;
  RxMap<String, Socket> connectedSockets = <String, Socket>{}.obs;
  String appDirectory = '';

  @override
  void onInit() {
    getApplicationDocumentsDirectory().then((appDocDir) {
      appDirectory = path.join(appDocDir.path, 'TotalShare');
      final directory = Directory(appDirectory);
      if (!directory.existsSync()) directory.create();
    });

    WrapServerSocket.create().then((wrapServerSocket) {
      address.value = wrapServerSocket.address;
      wrapServerSocket
        ..addHandler('register', (socket, payload, {meta}) async {
          final clientName = String.fromCharCodes(payload);
          connectedSockets[clientName] = socket;
          Get.snackbar(
            'New Connecion 📡',
            '$clientName connected!',
            margin: const EdgeInsets.only(top: 10),
            duration: const Duration(seconds: 2),
          );
        })
        ..addHandler('file', (_socket, payload, {meta}) async {
          final String fileName = '${meta['name']}.${meta['ext']}';
          final String filePath = path.join(appDirectory, fileName);
          File(filePath).writeAsBytesSync(payload, mode: FileMode.append);
        });
    });
    super.onInit();
  }

  void snackBottom(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.only(bottom: 10, left: 30, right: 30),
      duration: const Duration(seconds: 2),
    );
  }
}
