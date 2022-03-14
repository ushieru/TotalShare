import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:total_share/bin/wrap_server_socket.dart';

class ServerSocketController extends GetxController {
  RxString address = ''.obs;
  RxMap<String, Socket> connectedSockets = <String, Socket>{}.obs;
  RxList<MapEntry<String, Socket>> connectedSocketsList =
      <MapEntry<String, Socket>>[].obs;

  @override
  void onInit() {
    getApplicationDocumentsDirectory().then((appDocDir) {
      String appDocPath = appDocDir.path;
      final directory = Directory(appDocPath + '\\TotalShare');
      if (!directory.existsSync()) directory.create();
    });
    WrapServerSocket.create().then((wrapServerSocket) {
      address.value = wrapServerSocket.address;
      wrapServerSocket
        ..addHandler('register', (socket, payload, {meta}) async {
          final clientName = String.fromCharCodes(payload);
          debugPrint(clientName);
          connectedSockets[clientName] = socket;
          Get.snackbar(
            'New Connecion 📡',
            '$clientName connected!',
            margin: const EdgeInsets.only(top: 10),
            duration: const Duration(seconds: 2),
          );
        })
        ..addHandler('file', (socket, payload, {meta}) async {
          Directory appDocDir = await getApplicationDocumentsDirectory();
          String appDocPath = appDocDir.path;
          await File(
                  appDocPath + '\\TotalShare\\${meta['name']}.${meta['ext']}')
              .writeAsBytes(payload, mode: FileMode.append);
          Get.snackbar(
            'New Download 💾',
            '${meta['name']}.${meta['ext']}',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.only(bottom: 10, left: 30, right: 30),
            duration: const Duration(seconds: 2),
          );
        });
    });
    connectedSockets.listen((connectedSockets) =>
        connectedSocketsList.value = connectedSockets.entries.toList());
    super.onInit();
  }
}
