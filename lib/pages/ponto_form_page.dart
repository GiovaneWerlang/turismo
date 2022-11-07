import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:turismo/model/ponto.dart';

import '../dao/ponto_dao.dart';
import '../model/ponto.dart';
import 'mapa_page.dart';

class PontoFormPage extends StatefulWidget{

  static const ROUTE_NAME = '/ponto';

  Ponto ponto; //a forma correta é salvar no banco e puxar


  PontoFormPage({
    Key? key,
    required this.ponto
  }) : super(key: key);

  @override
  _PontoFormPageState createState() => _PontoFormPageState();
}

class _PontoFormPageState extends State<PontoFormPage>{

  final _formKey = GlobalKey<FormState>();
  final _detalheController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _diferencialController = TextEditingController();

  final _dataController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  final _dao = PontoDao();

  bool _alterouValores = false;

  Position? _localizacaoAtual;
  final _controller = TextEditingController();

  String get _textoLocalizacao => _localizacaoAtual == null ? '' : 'Latidude: ${_localizacaoAtual!.latitude}   |  Longitude: ${_localizacaoAtual!.longitude}';


  void initState(){
    super.initState();
    if(widget.ponto != null){
      _detalheController.text = widget.ponto!.detalhe;
      _descricaoController.text = widget.ponto!.descricao;
      _diferencialController.text = widget.ponto!.diferencial;
      _dataController.text = widget.ponto!.data_inclusao.toString();
      _latitudeController.text = widget.ponto!.latitude.toString();
      _longitudeController.text = widget.ponto!.longitude.toString();
    }
    _addData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.ponto.id == null ? 'Novo Ponto Turístico' : 'Alterar Ponto ${widget.ponto.id}'),
        ),
        body: _criarBody(),
      ),
      onWillPop: _onVoltarClick,
    );
  }

  Widget _criarBody() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
                controller: _detalheController,
                decoration: InputDecoration(
                    labelText: 'Detalhes'
                ),
                validator: (String? valor){
                  if(valor == null || valor.trim().isEmpty){
                    return "Informe os detalhes";
                  }
                  return null;
                }),
            TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (String? valor){
                  if(valor == null || valor.trim().isEmpty){
                    return "Informe a descrição";
                  }
                  return null;
                }),
            TextFormField(
                controller: _diferencialController,
                decoration: InputDecoration(labelText: 'Diferenciais'),
                validator: (String? valor){
                  if(valor == null || valor.trim().isEmpty){
                    return "Informe os diferenciais";
                  }
                  return null;
                }),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _obterLocalizacaoAtual();
                      },
                      child: Text(widget.ponto.id == null ? 'Inserir Localização' : 'Alterar Localização'),
                    ),
                  ),
                ]
            ),
            if(_textoLocalizacao != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children:[
                Flexible(
                  //padding: const EdgeInsets.symmetric(horizontal: 10),
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(_textoLocalizacao),
                      ),
                      ElevatedButton(
                          onPressed: _abriNoMapaInterno,
                          child: const Icon(Icons.map))
                    ],
                  ),
                ),
                ]
            ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children:[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                          labelText: 'Endereço ou ponto de referência',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.map),
                            tooltip: 'Abrir no Mapa',
                            onPressed: _abrirNoMapaExterno,
                          )
                    ),
                  ),
                )
              ]
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if(_formKey.currentState != null && dadosValidos()) {
                        if (novoPonto.longitude == 0 &&
                            novoPonto.latitude == 0) {
                          _mostrarMensagem(
                              'É necessário incluir a localização.');
                        } else {
                          setState(() {
                            _dao.salvar(novoPonto).then((success) =>
                            {
                              if(success){
                                _alterouValores = true,
                                _mostrarMensagem(widget.ponto.id == null
                                    ? 'Ponto incluído com sucesso.'
                                    : 'Ponto alterado com sucesso.'),
                                Navigator.of(context).pop(_alterouValores)
                              }
                            });
                          });
                        }
                      }
                    },
                    child: const Text('Confirmar'),
                  ),
                ),
              ],
            ),
          ],
        )
      )
    );
  }

  Future<bool> _onVoltarClick() async {
    Navigator.of(context).pop(_alterouValores);
    return true;
  }

  _addData(){
    final dataFormatada = _dataController.text;
    DateTime data = DateTime.now();
    if(dataFormatada.isNotEmpty && dataFormatada != "null"){
      data = DateFormat('yyyy-MM-dd').parse(dataFormatada);
    }
    _dataController.text = _dateFormat.format(data);
  }

  _addCoordenadas(){
    _obterLocalizacaoAtual();
  }

  void _obterUltimaLocalizacao() async {
    bool permissoesPermitidas = await _permissoesPermitidas();
    if (!permissoesPermitidas) {
      return;
    }
    _localizacaoAtual = await Geolocator.getLastKnownPosition();
        _latitudeController.text = _localizacaoAtual != null ? _localizacaoAtual!.latitude.toString() : '0';
        _longitudeController.text = _localizacaoAtual != null ? _localizacaoAtual!.longitude.toString() : '0';
    setState(() {

    });
  }


  void _obterLocalizacaoAtual() async {
    bool servicoHabilitado = await _servicoHabilitado();
    if (!servicoHabilitado) {
      return;
    }
    bool permissoesPermitidas = await _permissoesPermitidas();
    if (!permissoesPermitidas) {
      return;
    }
    _localizacaoAtual = await Geolocator.getCurrentPosition();
    _latitudeController.text = _localizacaoAtual!.latitude.toString();
    _longitudeController.text = _localizacaoAtual!.longitude.toString();
    setState(() {

    });
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

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensagem),
    ));
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

  bool dadosValidos() => _formKey.currentState?.validate() == true;

  Ponto get novoPonto => Ponto(
    id: widget.ponto?.id,
    detalhe: _detalheController.text,
    descricao: _descricaoController.text,
    diferencial: _diferencialController.text,
    data_inclusao: _dataController.text.isEmpty ? null : _dateFormat.parse(_dataController.text),
    latitude: _latitudeController.text.isEmpty ? 0 : double.parse(_latitudeController.text),
    longitude: _longitudeController.text.isEmpty ? 0 : double.parse(_longitudeController.text),
  );

  void _abriNoMapaInterno(){
    if(_localizacaoAtual == null){
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(
          builder: (BuildContext context) => MapaPage(
            latitude: _localizacaoAtual!.latitude,
            longitude: _localizacaoAtual!.longitude,
          ),
        ));
  }

  void _abrirCoordenadasNoMapa(){
    if(_localizacaoAtual == null){
      return;
    }
    MapsLauncher.launchCoordinates(
      _localizacaoAtual!.latitude,
      _localizacaoAtual!.longitude,
    );
  }

  void _abrirNoMapaExterno (){
    if(_controller.text.trim().isEmpty){
      return;
    }
    MapsLauncher.launchQuery(_controller.text);
  }
}