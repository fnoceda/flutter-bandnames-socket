import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:fl_chart/fl_chart.dart' as fl;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 3),
    Band(id: '3', name: 'Iron Maiden', votes: 2),
    Band(id: '4', name: 'Rammstein', votes: 1),
    Band(id: '5', name: 'Led Zeppelin', votes: 4),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  void _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 20),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _showPieChart()),
          // _showFLChart(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTile(bands[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addNewBand,
      ),
    );
  }

  Widget _showFLChart() {
    List<fl.PieChartSectionData> data = [
      fl.PieChartSectionData(
        color: Colors.blue[300],
        value: 10,
        title: 'A',
      ),
      fl.PieChartSectionData(
        color: Colors.blue[300],
        value: 5,
        title: 'B',
      ),
      fl.PieChartSectionData(
        color: Colors.blue[300],
        value: 3,
        title: 'C',
      ),
    ];

    Map<String, double> dataMap = Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    return fl.PieChart(fl.PieChartData(sections: data));
  }

  Widget _showPieChart() {
    // return Container();
    Map<String, double> dataMap = Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final colorList = <Color>[
      Color(0xfffdcb6e),
      Color(0xff0984e3),
      Color(0xfffd79a8),
      Color(0xffe17055),
      Color(0xff6c5ce7),
    ];

    return Container(
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        // centerText: "HYBRID",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          // legendShape: _BoxShape.circle,
          legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: false,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: true,
          decimalPlaces: 0,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) =>
          socketService.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2).toUpperCase()),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(band.votes.toString()),
        onTap: () {
          // print(band.name);
          socketService.socket.emit('vote-band', {'id': band.id});
        },
      ),
    );
  }

  _addNewBand() {
    final _textController = new TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add new band'),
            content: TextField(
              controller: _textController,
              decoration: InputDecoration(hintText: 'Band name'),
              onChanged: (text) {},
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Save'),
                onPressed: () => addBandToList(_textController.text),
              ),
            ],
          );
        },
      );
    } else {
      return showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text('Add new band'),
                content: CupertinoTextField(
                  controller: _textController,
                  placeholder: 'Band name',
                  onChanged: (text) {},
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Save'),
                    onPressed: () => addBandToList(_textController.text),
                  ),
                ],
              ));
    }
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (name.length > 1) {
      //podems agregar la banda a la lista
      // print(name);
      // bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      socketService.socket.emit('add-band', {'name': name});

      // setState(() {});
    }

    Navigator.of(context).pop();
  }
}
