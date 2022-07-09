import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:total_share/controller/client_socket_controller.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:file_picker/file_picker.dart';

class ClientRoute extends GetView<ClientSocketController> {
  static const String routeName = '/client';
  final TextEditingController ip = TextEditingController();
  final TextEditingController port = TextEditingController();
  final TextEditingController name = TextEditingController(
      text: 'Device - ${DateTime.now().millisecondsSinceEpoch}');

  ClientRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Obx(() {
            if (!controller.isConnected.value) {
              return Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                  children: [
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(label: Text('Name')),
                    ),
                    const SizedBox(height: 20),
                    if (Platform.isAndroid || Platform.isIOS)
                      ElevatedButton(
                        onPressed: () {
                          BarcodeScanner.scan().then((value) =>
                              controller.connect(value.rawContent, name.text));
                        },
                        child: const Text('Scan'),
                      ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: ip,
                      decoration: const InputDecoration(label: Text('IP')),
                    ),
                    TextFormField(
                      controller: port,
                      decoration: const InputDecoration(label: Text('port')),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        controller.connect(
                            '${ip.text}: ${port.text}', name.text);
                      },
                      child: const Text('Connect'),
                    ),
                  ],
                ),
              );
            }

            return ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.blue),
              onPressed: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles();

                PlatformFile platformFile = result!.files.first;
                final file = File(platformFile.path!);
                final fileName = platformFile.name.split('.')[0];
                final fileExt = platformFile.name.split('.')[1];

                await controller.sendPayload('file',
                    options: {'name': fileName, 'ext': fileExt},
                    middleware: (socket) async {
                  if (!file.existsSync()) return;
                  socket.addStream(file.openRead());
                });
              },
              child: const Text('Send Data'),
            );
          }),
        ),
      ),
    );
  }
}
