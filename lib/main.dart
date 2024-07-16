import 'package:flutter/material.dart';
import 'package:sociopolitico/router.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
