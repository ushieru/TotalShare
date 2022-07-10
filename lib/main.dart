import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:total_share/controller/bindings/client_bin.dart';
import 'package:total_share/controller/bindings/server_bin.dart';
import 'package:total_share/routes/main_route.dart';

void main() => runApp(const TotalShareServer());

class TotalShareServer extends StatelessWidget {
  const TotalShareServer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Total Share',
        initialRoute: MainRoute.routeName,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        getPages: [
          GetPage(
              name: MainRoute.routeName,
              page: () => MainRoute(),
              bindings: [ClientBin(), ServerBin()])
        ]);
  }
}
