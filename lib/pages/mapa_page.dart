import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatefulWidget{

  late double latitude;
  late double longitude;

  MapaPage({Key? key, required this.latitude, required this.longitude}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();

}

class _MapaPageState extends State<MapaPage> {

  Set<Marker> markers = Set();
  Map<PolylineId, Polyline> polylines = {};
  final _controller = Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                   markers: {
                    Marker(
                      markerId: MarkerId('1'),
                      position: LatLng(widget.latitude, widget.longitude),
                      infoWindow: InfoWindow(
                      title: 'Ponto',
                      ),
                    ),
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.latitude, widget.longitude),
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationEnabled: true,
                ),

              ],
            ),
          )
        ],
      )
    );
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensagem),
    ));
  }

}