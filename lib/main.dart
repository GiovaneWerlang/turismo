import 'package:flutter/material.dart';
import 'package:turismo/pages/filtro_page.dart';
import 'package:turismo/pages/lista_pontos_page.dart';
import 'package:turismo/pages/ponto_form_page.dart';

void main() {
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
      home: ListaPontosPage(),
      routes: {
        FiltroPage.ROUTE_NAME: (BuildContext context) => FiltroPage(),
      },
    );
  }
}