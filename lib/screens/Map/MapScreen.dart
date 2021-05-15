import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as l;
import 'package:ponto_seguro/components/SideMenu.dart';

class MapScreen extends StatelessWidget {
  static final routeName = '/map';

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
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }
}
