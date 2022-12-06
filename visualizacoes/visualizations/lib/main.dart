import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:visualizations/screens/adb.dart';
import 'package:visualizations/screens/bar.dart';
import 'package:visualizations/screens/line.dart';
import 'package:visualizations/screens/word_cloud.dart';

void main() async {
  runApp(MyApp());
}

void connect() async {
  final socket = await Socket.connect("localhost", 4561);
  socket.write("");
  socket.listen((data) async {
    final object = String.fromCharCodes(data);
    print(object);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(children: [
                  Bar(),
                  SizedBox(
                    width: 12,
                  ),
                  //WordCloudExample()
                ]),
                SizedBox(
                  height: 12,
                ),
                //Text("Ola")
                Line()
              ],
            ),
          ),
        )); //WordCloudExample());
  }
}
