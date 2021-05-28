import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import "package:latlong/latlong.dart" as l;
import 'package:ponto_seguro/components/BottomNavBar/BottomNavBar.dart';
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

  double userLatitude;
  double userLongitude;

  initState() {
    super.initState();
    getReports();
    setUserLocation();
  }

  setUserLocation() async {
    try {
      final position = await _determinePosition();
      setState(() {
        userLatitude = position.latitude;
        userLongitude = position.longitude;
      });
    } catch (e) {
      userLatitude = -27.557417;
      userLongitude = -48.512880;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
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
                showDetailsModal(report);
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

  Future<void> showDetailsModal(dynamic report) async {
    print(jsonEncode(report['when']));
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Ocorrência - ${report['userType'] == 'PEDESTRIAN' ? 'Pedestre' : 'Motorista'}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '${DateFormat.yMd().add_jm().format(DateFormat('yyyy-MM-ddTHH:mm:ssZ').parse(report['when']))}',
                ),
                Text('Tipo de ocorrência: ${report['reportType']}'),
                Text('Detalhes: ${report['details']}'),
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
                    validator: FormBuilderValidators.compose(
                      [FormBuilderValidators.required(context)],
                    ),
                    options: [
                      FormBuilderFieldOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Pedestre"),
                            Icon(Icons.emoji_people_outlined),
                          ],
                        ),
                        value: 'PEDESTRIAN',
                      ),
                      FormBuilderFieldOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Motorista"),
                            Icon(Icons.drive_eta_outlined),
                          ],
                        ),
                        value: 'DRIVER',
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
                    validator: FormBuilderValidators.compose(
                      [FormBuilderValidators.required(context)],
                    ),
                    items: [
                      DropdownMenuItem(
                        child: Text('Furto'),
                        value: 'THEFT',
                      ),
                      DropdownMenuItem(
                        child: Text('Assalto'),
                        value: 'ROBBERY',
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  FormBuilderDateTimePicker(
                    name: 'when',
                    decoration: InputDecoration(
                      labelText: 'Data/hora',
                      border: OutlineInputBorder(),
                    ),
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
                    "userType": _formKey.currentState.value['userType'],
                    "reportType": _formKey.currentState.value['reportType'],
                    "when": _formKey.currentState.value['when'] != null
                        ? _formKey.currentState.value['when'].toIso8601String()
                        : null,
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
    print('asd');
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
        nonRotatedChildren: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 12,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: FormBuilderTextField(
                  style: TextStyle(fontSize: 12),
                  name: 'search',
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: new OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 25,
                      color: Colors.grey,
                    ),
                    labelText: 'Pesquisar um local',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelStyle: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
        options: MapOptions(
          interactiveFlags: InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom |
              InteractiveFlag.flingAnimation,
          center: l.LatLng(userLatitude, userLongitude),
          zoom: 14,
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
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
