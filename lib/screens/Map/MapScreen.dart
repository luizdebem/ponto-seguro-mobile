import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import "package:latlong/latlong.dart" as l;
import 'package:ponto_seguro/components/SideMenu.dart';
import 'package:ponto_seguro/services/ReportService.dart';

class MapScreen extends StatefulWidget {
  static final routeName = '/map';

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List reports = [];

  initState() {
    super.initState();
    getReports();
  }

  getReports() async {
    final Response res = await ReportService.listAll();
    final data = jsonDecode(res.body);
    setState(() {
      reports = data['data'];
    });
  }

  List<Marker> markers() {
    final markers = reports
        .map(
          (report) => Marker(
            builder: (ctx) => GestureDetector(
              onTap: () {
                showDetailsModal(report['details']);
              },
              child: Icon(
                Icons.place,
                color: Colors.red,
                size: 30,
              ),
            ),
            height: 50,
            width: 50,
            point: l.LatLng(
              report['geolocation']['latitude'],
              report['geolocation']['longitude'],
            ),
          ),
        )
        .toList();
    return markers;
  }

  Future<void> showDetailsModal(String details) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ocorrência'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Detalhes: $details'),
              ],
            ),
          ),
        );
      },
    );
  }

  // @TODO @luizdebem componente
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar ocorrência aqui'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Formulário adicionar ocorrência'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ponto Seguro',
        ),
      ),
      drawer: SideMenu(),
      body: FlutterMap(
        options: MapOptions(
          center: l.LatLng(-27.557417, -48.512880),
          zoom: 13.0,
          onTap: (l.LatLng s) {
            _showMyDialog();
            print(s);
          },
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: markers(),
          )
        ],
      ),
    );
  }
}
