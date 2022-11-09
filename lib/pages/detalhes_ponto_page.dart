import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import '../model/ponto.dart';
import 'mapa_page.dart';

class DetalhesPontoPage extends StatefulWidget{
  final Ponto ponto;

  const DetalhesPontoPage({Key? key, required this.ponto}) : super(key: key);

  _DetalhesPontoPageState createState() => _DetalhesPontoPageState();
}

class _DetalhesPontoPageState extends State<DetalhesPontoPage>{

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Ponto Turistico'),
      ),
      body: _criarBody(),
    );
  }

  Widget _criarBody(){
    return Padding(
      padding: EdgeInsets.all(20),
      child: ListView(
        children: [
          Container(
            margin: EdgeInsets.only(top:10),
            child:
            Row(
              children: [
                Campo(descricao: 'Código: '),
                Valor(valor: '${widget.ponto.id}'),
              ],
            )
          ),
          Container(
            margin: EdgeInsets.only(top:10),
            child:
            Row(
              children: [
                Campo(descricao: 'Detalhe: '),
                Valor(valor: widget.ponto.detalhe),
              ],
            )
          ),
          Container(
              margin: EdgeInsets.only(top:10),
              child:
              Row(
              children: [
                  Campo(descricao: 'Descrição: '),
                  Valor(valor: widget.ponto.descricao),
                ],
            )
          ),
          Container(
            margin: EdgeInsets.only(top:10),
            child:
            Row(
            children: [
                Campo(descricao: 'Diferencial: '),
                Valor(valor: widget.ponto.diferencial),
              ],
            )
          ),
          Container(
            margin: EdgeInsets.only(top:10),
            child:
            Row(
            children: [
              Campo(descricao: 'Data: '),
              Valor(valor: widget.ponto.dataInclusaoFormatada),
            ],
            )
          ),
          Container(
            margin: EdgeInsets.only(top:10),
            child:
            Row(
            children: [
              Campo(descricao: 'Latitude: '),
              Valor(valor: widget.ponto.latitude.toString()),
            ],
            )
          ),
          Container(
            margin: EdgeInsets.only(top:10),
            child:
            Row(
            children: [
              Campo(descricao: 'Longitude: '),
              Valor(valor: widget.ponto.longitude.toString()),
            ],
          )),
          Container(
            margin: EdgeInsets.only(top: 10),
            child:
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _abrirNoMapaInterno();
                      },
                      child: Text('Abrir no mapa interno'),
                    ),
                  ),
                ]
            ),
          ),
          Container(
            child:
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _abrirNoMapaExterno();
                      },
                      child: Text('Abrir no google maps'),
                    ),
                  ),
                ]
            ),
          )
        ],
      ),
    );
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensagem),
    ));
  }

  void _abrirNoMapaInterno(){
    if(widget.ponto.latitude == null || widget.ponto.longitude == null){
      _mostrarMensagem("O ponto não possui localização.");
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(
          builder: (BuildContext context) => MapaPage(
            latitude: widget.ponto.latitude,
            longitude: widget.ponto.longitude,
          ),
        ));
  }

  void _abrirNoMapaExterno(){
    if(widget.ponto.latitude == null || widget.ponto.longitude == null){
      _mostrarMensagem("O ponto não possui localização.");
      return;
    }
    MapsLauncher.launchCoordinates(
      widget.ponto.latitude,
      widget.ponto.longitude
    );
  }
}

class Campo extends StatelessWidget{
  final String descricao;

  const Campo({Key? key, required this.descricao}) : super(key: key);

  Widget build(BuildContext context){
    return Expanded(
      flex: 1,
      child: Text(
        descricao,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class Valor extends StatelessWidget{
  final String valor;

  const Valor({Key? key, required this.valor}) : super(key: key);

  Widget build(BuildContext context){
    return Expanded(
      flex: 1,
      child: Text(
        valor,

      ),
    );
  }
}