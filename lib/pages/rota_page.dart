import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


class RotaPage extends StatefulWidget{


  late double latitudeInicial;
  late double longitudeInicial;

  late double latitudeFinal;
  late double longitudeFinal;


  RotaPage({
    Key? key,
    required this.latitudeInicial,
    required this.longitudeInicial,
    required this.latitudeFinal,
    required this.longitudeFinal,
  }) : super(key: key);

  @override
  _RotaPageState createState() => _RotaPageState();

}

class _RotaPageState extends State<RotaPage> {

  String key = 'AIzaSyBtRq3EnksVyE7UxZ3Z7e4R_8732b9vyRs';
  Set<Marker> markers = Set();
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();

  final _controller = Completer<GoogleMapController>();
  double distancia = 0.0;

  @override
  void initState() {
    markers.add(
      Marker(
        markerId: MarkerId('1'),
        position: LatLng(widget.latitudeInicial, widget.longitudeInicial),
        infoWindow: InfoWindow(
          title: 'Localização Atual',
        ),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('2'),
        position: LatLng(widget.latitudeFinal, widget.longitudeFinal),
        infoWindow: InfoWindow(
          title: 'Ponto',
        ),
      ),
    );

    getDirections();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Rota'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    markers: markers,
                    polylines: Set<Polyline>.of(polylines.values),
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.latitudeFinal, widget.longitudeFinal),
                      zoom: 15,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    myLocationEnabled: true,
                  ),
                  Positioned(
                      bottom: 200,
                      left: 50,
                      child: Container(
                          child: Card(
                            child: Container(
                                padding: EdgeInsets.all(20),
                                child: Text("Total Distance: " + distancia.toStringAsFixed(2) + " KM",
                                    style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold))
                            ),
                          )
                      )
                  )
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





  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      key,
      PointLatLng(widget.latitudeInicial, widget.longitudeInicial),
      PointLatLng(widget.latitudeFinal, widget.longitudeFinal),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    double distanciaTotal = 0;
    for(var i = 0; i < polylineCoordinates.length-1; i++){
      distanciaTotal += calcularDistancia(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i+1].latitude,
          polylineCoordinates[i+1].longitude);
    }
    print(distanciaTotal);

    setState(() {
      distancia = distanciaTotal;
    });

    addPolyLine(polylineCoordinates);
  }

  double calcularDistancia(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }
}