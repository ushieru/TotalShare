import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:total_share/controller/bindings/client_bin.dart';
import 'package:total_share/controller/bindings/server_bin.dart';
import 'package:total_share/routes/client_route.dart';
import 'package:total_share/routes/main_route.dart';
import 'package:total_share/routes/server_route.dart';

void main() => runApp(const TotalShareServer());

class TotalShareServer extends StatelessWidget {
  const TotalShareServer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Total Share',
      initialRoute: '/main',
      getPages: [
        GetPage(
          name: MainRoute.routeName,
          page: () => const MainRoute(),
        ),
        GetPage(
            name: ServerRoute.routeName,
            page: () => const ServerRoute(),
            binding: ServerBin()),
        GetPage(
            name: ClientRoute.routeName,
            page: () => ClientRoute(),
            binding: ClientBin()),
      ],
    );
  }
}
