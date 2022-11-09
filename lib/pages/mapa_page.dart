

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatefulWidget{

  late double latitude;
  late double longitude;

  MapaPage({Key? key, required this.latitude, required this.longitude}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();

}

class _MapaPageState extends State<MapaPage> {

  final _controller = Completer<GoogleMapController>();
  StreamSubscription<Position>? _subscription;

  @override
  void initState() {
    super.initState();
    //_monitorarLocalizacao();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  // markers: {
                  //   Marker(
                  //     markerId: MarkerId('1'),
                  //     position: LatLng(widget.latitude, widget.longitude),
                  //     infoWindow: InfoWindow(
                  //       title: 'Café da Praça',
                  //     ),
                  //   ),
                  // },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.latitude, widget.longitude),
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationEnabled: true,
                  onTap:  (LatLng) => {
                    widget.latitude = LatLng.latitude,
                    widget.longitude = LatLng.longitude,
                  },
                  mapToolbarEnabled: false,
                ),
                mapToolBar()
              ],
            ),
          )
        ],
      )
    );
  }

  Widget mapToolBar() {
    return Row(
      children: [
        FloatingActionButton(
          child: Icon(Icons.map),
          backgroundColor: Colors.blue,
          onPressed: () {
            _mostrarMensagem("Latitude: ${widget.latitude} | Longitude:  ${widget.longitude}");
          },
        ),
      ],
    );
  }

  // void _monitorarLocalizacao() {
  //   final LocationSettings locationSettings = LocationSettings(
  //     accuracy: LocationAccuracy.high,
  //     distanceFilter: 100,
  //     timeLimit: Duration(seconds: 1),
  //   );
  //   _subscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) async {
  //     final controller = await _controller.future;
  //     final zoom = await controller.getZoomLevel();
  //     controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //       target: LatLng(position.latitude, position.longitude),
  //       zoom: zoom,
  //     )));
  //   });
  // }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensagem),
    ));
  }
}