import 'package:baby_name/pages/app_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';

import 'pages/home.dart';
import 'pages/name_choose.dart';
import 'pages/name_setting.dart';
import 'utils/route.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    debugPaintSizeEnabled = false;
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: MyHomePage(),
        routes: {
          UIRoute.nameChoose: (context) => NameChoosePage(
                type: ModalRoute.of(context).settings.arguments,
              ),
          UIRoute.nameSetting: (context) => NameSettingPage(
                index: ModalRoute.of(context).settings.arguments,
              ),
          UIRoute.appSetting: (_) => AppSettingPage(),
        },
      ),
    );
  }
}
