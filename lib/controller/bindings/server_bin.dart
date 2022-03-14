import 'package:get/get.dart';
import 'package:total_share/controller/server_socket_controller.dart';

class ServerBin extends Bindings {
  @override
  void dependencies() {
    Get.put(ServerSocketController());
  }
}
