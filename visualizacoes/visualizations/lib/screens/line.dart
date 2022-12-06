import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class Line extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  Line({Key? key}) : super(key: key);

  @override
  _LineState createState() => _LineState();
}

class _LineState extends State<Line> {
  late TooltipBehavior _tooltipBehavior;
  List<SalesData> data1 = [];
  Map<String, dynamic> valuesMap = Map();
  @override
  void initState() {
    // TODO: implement initState
    connect();
    super.initState();
  }

  void connect() async {
    final socket = await Socket.connect("localhost", 4563);
    socket.write("visualization");
    socket.listen((data) async {
      final object = String.fromCharCodes(data);
      setState(() {
        try {
          valuesMap = json.decode(object);
          data1 = [];
          late SalesData chartData;
          valuesMap.forEach((key, value) {
            chartData = SalesData(DateTime.parse(key), value);
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
    final List<SalesData> chartData = [
      SalesData(DateTime(2010), 35),
      SalesData(DateTime(2011), 28),
      SalesData(DateTime(2012), 34),
      SalesData(DateTime(2013), 32),
      SalesData(DateTime(2014), 40)
    ];

    return Container(
        child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(),
            series: <ChartSeries>[
          // Renders line chart
          LineSeries<SalesData, DateTime>(
              dataSource: data1,
              xValueMapper: (SalesData sales, _) => sales.year,
              yValueMapper: (SalesData sales, _) => sales.sales)
        ]));
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final DateTime year;
  final int sales;
}
