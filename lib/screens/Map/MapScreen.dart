import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import "package:latlong/latlong.dart" as l;
import 'package:ponto_seguro/services/AuthService.dart';
import 'package:ponto_seguro/services/ReportService.dart';
import 'package:toast/toast.dart';

class MapScreen extends StatefulWidget {
  static final routeName = '/map';

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List reports = [];
  bool mapLocked = true;

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
              child: Image.asset('assets/pin.png'),
            ),
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
          title: Text(
            'Criar ocorrência',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  FormBuilderRadioGroup(
                    name: 'userType',
                    options: [
                      FormBuilderFieldOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Pedestre"),
                            Icon(Icons.emoji_people_outlined),
                          ],
                        ),
                        value: 'pedestrian',
                      ),
                      FormBuilderFieldOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Motorista"),
                            Icon(Icons.drive_eta_outlined),
                          ],
                        ),
                        value: 'driver',
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  FormBuilderDropdown(
                    name: 'reportType',
                    decoration: InputDecoration(
                      labelText: 'Ocorrência',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        child: Text('test'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: FormBuilderDropdown(
                          name: 'date',
                          decoration: InputDecoration(
                            labelText: 'DD/MM/AA',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              child: Text('test'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 1,
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: FormBuilderDropdown(
                          name: 'time',
                          decoration: InputDecoration(
                            labelText: 'Horário',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              child: Text('test'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  FormBuilderTextField(
                    name: 'details',
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Detalhes (opcional)',
                    ),
                  ),
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
                    "userID": AuthService.USER_ID
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
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: IconButton(
        icon: Image.asset(
            mapLocked ? 'assets/click-btn-locked.png' : 'assets/click-btn.png'),
        iconSize: 100,
        onPressed: () {
          setState(() {
            mapLocked = !mapLocked;
          });
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   // @TODO @luizdebem - alterar o local de atualizar o mapa;
      //   // onPressed: () {
      //   //   getReports();
      //   //   return Toast.show(
      //   //     "Mapa atualizado com sucesso.",
      //   //     context,
      //   //     duration: Toast.LENGTH_LONG,
      //   //     gravity: Toast.CENTER,
      //   //     backgroundColor: Colors.green,
      //   //     textColor: Colors.white,
      //   //   );
      //   // },
      //   onPressed: () {
      //     setState(() {});
      //   },
      //   child: Icon(Icons.add_circle_outline, size: 50),
      // ),
      body: FlutterMap(
        options: MapOptions(
          interactiveFlags: InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom |
              InteractiveFlag.flingAnimation,
          center: l.LatLng(-27.557417, -48.512880),
          zoom: 13.0,
          onTap: (l.LatLng geolocation) {
            if (!mapLocked) _showMyDialog(geolocation);
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
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromRGBO(0, 150, 199, 1),
        unselectedItemColor: Color.fromRGBO(198, 198, 198, 1),
        backgroundColor: Color.fromRGBO(252, 252, 252, 1),
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Ocorrências',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: Color.fromRGBO(252, 252, 252, 1),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Opções',
          ),
        ],
      ),
    );
  }
}
