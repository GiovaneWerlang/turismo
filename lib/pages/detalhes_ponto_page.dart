import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:turismo/pages/rota_page.dart';
import '../model/ponto.dart';
import '../widgets/visualizador_de_imagem.dart';
import 'mapa_page.dart';

class DetalhesPontoPage extends StatefulWidget{
  final Ponto ponto;

  const DetalhesPontoPage({Key? key, required this.ponto}) : super(key: key);

  _DetalhesPontoPageState createState() => _DetalhesPontoPageState();
}

class _DetalhesPontoPageState extends State<DetalhesPontoPage>{

  Position? _localizacaoAtual;


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
                  Campo(descricao: 'CEP: '),
                  Valor(valor: widget.ponto.cep.toString()),
                ],
              )
          ),
          Container(
              margin: EdgeInsets.only(top:10),
              child:
              Row(
                children: [
                  Campo(descricao: 'Cidade: '),
                  Valor(valor: widget.ponto.cidade.toString()),
                ],
              )
          ),
          Container(
              margin: EdgeInsets.only(top:10),
              child:
              Row(
                children: [
                  Campo(descricao: 'UF: '),
                  Valor(valor: widget.ponto.uf.toString()),
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
              margin: EdgeInsets.only(top:10),
              child:
              Row(
                children: [
                  Campo(descricao: 'Tipo da imagem: '),
                  Valor(valor: widget.ponto.tipoImagem.toString()),
                ],
              )),
          Container(
              margin: EdgeInsets.only(top:10),
              child:
              Row(
                children: [
                  Campo(descricao: 'Caminho da imagem: '),
                  Valor(valor: widget.ponto.caminhoImagem.toString()),
                ],
              )),
          // VisualizadorImagem(
          //   tipoImagem: widget.ponto.tipoImagem,
          //   caminhoImagem: widget.ponto.caminhoImagem,
          //   size: ((MediaQuery.of(context).size.width) / 0.5),
          // ),
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
                        _calcularDistancia();
                      },
                      child: Text('Calcular distância'),
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
                        _getlocalizacaoAtual();
                        if(_localizacaoAtual != null) {
                          Navigator.of(context).push(
                              MaterialPageRoute( //outra forma de abrir uma page
                                builder: (_) =>
                                    RotaPage(
                                        latitudeInicial:_localizacaoAtual!.latitude,
                                        longitudeInicial:_localizacaoAtual!.longitude,
                                        latitudeFinal: widget.ponto.latitude,
                                        longitudeFinal: widget.ponto.longitude
                                    ),
                              ));
                        }else{
                          _mostrarMensagem("Localização não pode ser obtida.");
                        }
                      },
                      child: Text('Visualizar Rota'),
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

  void _calcularDistancia() async{
    bool servicoHabilitado = await _servicoHabilitado();
    if (!servicoHabilitado) {
      return;
    }
    bool permissoesPermitidas = await _permissoesPermitidas();
    if (!permissoesPermitidas) {
      return;
    }
    _localizacaoAtual = await Geolocator.getCurrentPosition();
    if(_localizacaoAtual != null){

      var p = 0.017453292519943295;
      var a = 0.5 - cos(( widget.ponto.latitude - _localizacaoAtual!.latitude) * p)/2 +
          cos(_localizacaoAtual!.latitude * p) * cos(widget.ponto.latitude * p) *
              (1 - cos((widget.ponto.longitude - _localizacaoAtual!.longitude) * p))/2;
      _mostrarMensagem("Distância: " + (12742 * asin(sqrt(a))).toString() + " metros");

      //_mostrarMensagem("Distância: " + Geolocator.distanceBetween(_localizacaoAtual!.latitude, _localizacaoAtual!.longitude, widget.ponto.latitude, widget.ponto.latitude).toString() + " metros");
    }
  }

  void _getlocalizacaoAtual() async{
    bool servicoHabilitado = await _servicoHabilitado();
    if (!servicoHabilitado) {
      return;
    }
    bool permissoesPermitidas = await _permissoesPermitidas();
    if (!permissoesPermitidas) {
      return;
    }
    _localizacaoAtual = await Geolocator.getCurrentPosition();
  }


  Future<bool> _servicoHabilitado() async {
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      await _mostrarDialogMensagem('Para utilizar esse recurso, você deverá '
          'habilitar o serviço de localização do dispositivo');
      Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  Future<bool> _permissoesPermitidas() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        _mostrarMensagem(
            'Não será possível utilizar o recurso por falta de permissão');
        return false;
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      await _mostrarDialogMensagem(
          'Para utilizar esse recurso, você deverá acessar as configurações '
              'do app e permitir a utilização do serviço de localização');
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  Future<void> _mostrarDialogMensagem(String mensagem) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Atenção'),
        content: Text(mensagem),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
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