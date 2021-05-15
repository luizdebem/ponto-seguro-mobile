import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import "package:latlong/latlong.dart" as l;
import 'package:ponto_seguro/components/SideMenu.dart';
import 'package:ponto_seguro/services/ReportService.dart';
import 'package:toast/toast.dart';

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

  final _formKey = GlobalKey<FormBuilderState>();

  // @TODO @luizdebem componente
  Future<void> _showMyDialog(l.LatLng geolocation) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar ocorrência aqui'),
          content: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'details',
                    keyboardType: TextInputType.multiline,
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.minLength(context, 15),
                      ],
                    ),
                    maxLines: null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Insira mais detalhes',
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('SALVAR'),
              onPressed: () async {
                _formKey.currentState.save();
                if (_formKey.currentState.validate()) {
                  final data = {
                    "geolocation": {
                      "latitude": geolocation.latitude,
                      "longitude": geolocation.longitude,
                    },
                    "details": _formKey.currentState.value['details'],
                    "userID": "25910" // @TODO @luizdebem userID no service
                  };
                  final res = await ReportService.create(data);
                  if (res.statusCode == 200) {
                    getReports();
                    Navigator.of(context).pop();
                    return Toast.show(
                      "Ocorrência salva com sucesso.",
                      context,
                      duration: Toast.LENGTH_LONG,
                      gravity: Toast.BOTTOM,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  }
                } else {
                  return Toast.show(
                    "Verifique os dados do formulário!",
                    context,
                    duration: Toast.LENGTH_LONG,
                    gravity: Toast.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getReports();
          return Toast.show(
            "Mapa atualizado com sucesso.",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        },
        child: Icon(Icons.refresh),
      ),
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
          onTap: (l.LatLng geolocation) {
            _showMyDialog(geolocation);
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
