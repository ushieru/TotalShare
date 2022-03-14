import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:total_share/controller/server_socket_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ServerRoute extends GetView<ServerSocketController> {
  static const String routeName = '/server';
  const ServerRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Row(
          children: [
            SizedBox(
                width: 130,
                child: Center(
                  child: Obx(() {
                    if (controller.address.value.isEmpty) {
                      return const SizedBox();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Total Share',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text(controller.address.value),
                        QrImage(
                          data: controller.address.value,
                          version: QrVersions.auto,
                          size: 120,
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () async {
                            Directory appDocDir =
                                await getApplicationDocumentsDirectory();
                            String appDocPath = appDocDir.path;
                            await launch('file:' + appDocPath + '\\TotalShare');
                          },
                          child: const Text('Ver Carpeta'),
                        )
                      ],
                    );
                  }),
                )),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Obx(
                  () => ListView.builder(
                    itemCount: controller.connectedSockets.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(controller.connectedSocketsList[index].key),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
