import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:total_share/routes/client_route.dart';
import 'package:total_share/routes/server_route.dart';

class MainRoute extends StatelessWidget {
  static const String routeName = '/main';
  const MainRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.blue),
                onPressed: () => Get.toNamed(ServerRoute.routeName),
                child: const Text('Server'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.blue),
                onPressed: () => Get.toNamed(ClientRoute.routeName),
                child: const Text('Client'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
