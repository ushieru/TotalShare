import 'package:get/get.dart';
import 'package:total_share/controller/client_socket_controller.dart';

class ClientBin extends Bindings {
  @override
  void dependencies() {
    Get.put(ClientSocketController());
  }
}
