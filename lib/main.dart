import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:turismo/generator/route_generator.dart';
import 'package:turismo/pages/filtro_page.dart';
import 'package:turismo/pages/lista_pontos_page.dart';
import 'package:turismo/pages/ponto_form_page.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } catch (e, s) {
    debugPrint('Error: $e');
    debugPrint('Stack: $s');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pontos Turísticos',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}