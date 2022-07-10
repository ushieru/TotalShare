import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:total_share/controller/client_socket_controller.dart';
import 'package:total_share/controller/server_socket_controller.dart';

class MainRoute extends GetResponsiveView {
  static const String routeName = '/main';
  final TextEditingController _nameController = TextEditingController(
      text: 'Device - ${DateTime.now().millisecondsSinceEpoch}');

  final _clientController = Get.find<ClientSocketController>();
  final _serverController = Get.find<ServerSocketController>();

  MainRoute({Key? key}) : super(key: key);

  @override
  Widget phone() {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(label: Text('IP')),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Obx(() {
            if (_serverController.address.value.isEmpty) {
              return const SizedBox();
            }
            return InkWell(
                onTap: () {
                  final rawData = _serverController.address.value.split(':');
                  final ip = rawData[0];
                  final port = rawData[1];
                  Get.defaultDialog(
                      title: 'Manual connection',
                      middleText: 'IP: $ip\nPORT: $port');
                },
                child: QrImage(
                    data: _serverController.address.value,
                    version: QrVersions.auto,
                    size: 120));
          }),
          const SizedBox(width: 20),
          Expanded(
              child: Column(children: [
            ElevatedButton(
                onPressed: () => BarcodeScanner.scan().then((value) =>
                    _clientController.connect(
                        value.rawContent, _nameController.text)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Sync'),
                      Icon(Icons.leak_add),
                    ])),
            ElevatedButton(
                onPressed: () async {
                  if (_serverController.appDirectory.isEmpty) return;
                  await launch(
                      'file:' + path.join(_serverController.appDirectory));
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Ver archivos'),
                      Icon(Icons.folder_open),
                    ]))
          ]))
        ]),
        const SizedBox(height: 20),
        const Text('Sync devices:', style: TextStyle(fontSize: 20)),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Obx(() => ListView.separated(
                      itemCount: _serverController.connectedSockets.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: Colors.black),
                      itemBuilder: (context, index) {
                        return ListTile(
                            title: Text(_serverController
                                .connectedSockets.entries
                                .toList()[index]
                                .key));
                      },
                    ))))
      ]),
    )));
  }
}
