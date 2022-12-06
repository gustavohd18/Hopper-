import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

class Bar extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  Bar({Key? key}) : super(key: key);

  @override
  _BarState createState() => _BarState();
}

class _BarState extends State<Bar> {
  late List<_ChartData> data1;
  late TooltipBehavior _tooltip;
  double numberMax = 40;
  double interval = 10;
  Map<String, dynamic> valuesMap = Map();

  @override
  void initState() {
    data1 = [];

    _tooltip = TooltipBehavior(enable: true);
    connect();
    super.initState();
  }

  void connect() async {
    final socket = await Socket.connect("localhost", 4561);
    socket.write("visualization");
    socket.listen((data) async {
      final object = String.fromCharCodes(data);
      setState(() {
        try {
          valuesMap = json.decode(object);
          data1 = [];
          late _ChartData chartData;
          List<int> listOfValue =
              valuesMap.values.toList().map((e) => e as int).toList();
          final maxValue = listOfValue.reduce(max);
          numberMax = maxValue.toDouble() + 10;
          if (numberMax < 100) {
            interval = 10;
          } else if (numberMax >= 1000) {
            interval = 100;
          } else if (numberMax >= 10000) {
            interval = 1000;
          }
          valuesMap.forEach((key, value) {
            chartData = _ChartData(key, value);
            data1.add(chartData);
          });
        } catch (e) {
          print("Deu error $e");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1200,
        height: 700,
        child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis:
                NumericAxis(minimum: 0, maximum: numberMax, interval: interval),
            tooltipBehavior: _tooltip,
            series: <ChartSeries<_ChartData, String>>[
              BarSeries<_ChartData, String>(
                  dataSource: data1,
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y,
                  name: 'Gold',
                  color: const Color.fromRGBO(8, 142, 255, 1))
            ]));
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final int y;
}
