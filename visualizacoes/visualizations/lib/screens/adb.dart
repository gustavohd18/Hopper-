import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';

import '../data.dart';

class WordCloudExample1 extends StatefulWidget {
  @override
  State<WordCloudExample1> createState() => _WordCloudExample1State();
}

class _WordCloudExample1State extends State<WordCloudExample1> {
  Map<String, dynamic> valuesMap = Map();
  List<Widget> widgets = <Widget>[];
  List<Color> colors = [
    FlutterColors.yellow,
    FlutterColors.gray600,
    FlutterColors.blue600,
    FlutterColors.gray,
    FlutterColors.blue400,
    FlutterColors.blue400,
    FlutterColors.gray600,
    FlutterColors.blue
  ];
  void connect() async {
    final socket = await Socket.connect("localhost", 4560);
    socket.write("visualization");
    List<FlutterHashtag> hashtags = [];
    socket.listen((data) async {
      final object = String.fromCharCodes(data);
      setState(() {
        try {
          var rng = Random();
          final color = rng.nextInt(8);
          valuesMap = json.decode(object);
          // valuesMap.keys.forEach((element) {
          //   print(element);
          // });
          //widgets = [];
          //hashtags = [];
          late FlutterHashtag hashtag;
          valuesMap.forEach((key, value) {
            hashtags.add(FlutterHashtag(key, colors[color], value, false));
          });

          for (var i = 0; i < hashtags.length; i++) {
            widgets.add(ScatterItem(hashtags[i]));
          }
        } catch (e) {
          print("Deu error $e");
        }
      });
    });
  }

  @override
  void initState() {
    connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final ratio = screenSize.width / screenSize.height;

    return Center(
      child: FittedBox(
        child: Scatter(
          fillGaps: true,
          delegate: ArchimedeanSpiralScatterDelegate(ratio: ratio),
          children: widgets,
        ),
      ),
    );
  }
}

class ScatterItem extends StatelessWidget {
  ScatterItem(this.hashtag);
  final FlutterHashtag hashtag;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontSize: hashtag.size.toDouble(),
      color: hashtag.color,
    );
    return RotatedBox(
      quarterTurns: hashtag.rotated ? 1 : 0,
      child: Text(
        hashtag.hashtag,
        style: style,
      ),
    );
  }
}
