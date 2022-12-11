import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turismo/pages/filtro_page.dart';
import 'package:turismo/pages/lista_pontos_page.dart';
import 'package:turismo/pages/ponto_form_page.dart';

import '../model/ponto.dart';

class RouteGenerator{
  static Route<dynamic> generateRoute(RouteSettings settings){
    final args = settings.arguments;

    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (context) => ListaPontosPage());
      case '/filtro':
        return MaterialPageRoute(builder: (context) => FiltroPage());
      case '/ponto':
        int? id;
        String detalhe = '';
        String descricao = '';
        String diferencial = '';
        DateTime? data_inclusao;
        double latitude = 0;
        double longitude = 0;
        String cep = '';
        String cidade = '';
        String uf = '';

        if(args != null){
          dynamic dados = settings.arguments;
          id = dados['id'];
          detalhe = dados['detalhe'];
          descricao = dados['descricao'];
          diferencial = dados['diferencial'];
          //data_inclusao = DateTime.parse(dados['data_inclusao']);
          data_inclusao = dados['data_inclusao'];
          latitude = dados['latitude'];
          longitude = dados['longitude'];
          cep = dados['cep'];
          cidade = dados['cidade'];
          uf = dados['uf'];
        }
        return MaterialPageRoute(builder: (context) => PontoFormPage(
          //ponto: args,

          ponto:  Ponto(
              id: id,
              detalhe: detalhe,
              descricao: descricao,
              diferencial: diferencial,
              data_inclusao: data_inclusao,
              latitude: latitude,
              longitude: longitude,
              cep: cep,
              cidade: cidade,
              uf: uf,
            ),

        ));
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute(){
    return MaterialPageRoute(builder: (context){
      return Scaffold(
        appBar: AppBar(
          title: Text('ERRO 404'),
          centerTitle: true,
        ),
        body: Center(
          child: Text('Página não encontrada!'),
        ),
      );
    });
  }
}