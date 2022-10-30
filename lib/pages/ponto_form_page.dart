import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:turismo/model/ponto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dao/ponto_dao.dart';

class PontoFormPage extends StatefulWidget{

  Ponto? ponto;

  StreamSubscription<Position>? _subscription;
  Position? _ultimaPosicaoObtida;

  PontoFormPage({Key? key, this.ponto}) : super(key: key);

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

  void initState(){
    super.initState();
    if(widget.ponto != null){
      _detalheController.text = widget.ponto!.detalhe;
      _descricaoController.text = widget.ponto!.descricao;
      _diferencialController.text = widget.ponto!.diferencial;
      _dataController.text = widget.ponto!.dataInclusaoFormatada;
      _latitudeController.text = widget.ponto!.latitude.toString();
      _longitudeController.text = widget.ponto!.longitude.toString();
    }
    _addData();
    _addCoordenadas();
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.ponto == null ? 'Novo Ponto Turístico' : 'Alterar Ponto ${widget.ponto!.id}'),
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
                        _addCoordenadas;
                      },
                      child: Text(widget.ponto == null ? 'Inserir Localização' : 'Alterar Localização'),
                    ),
                  ),
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
                      if(_formKey.currentState != null && dadosValidos()){
                        setState(() {
                          _dao.salvar(novoPonto).then((success) => {
                            //_atualizarLista()
                            _mostrarMensagem(widget.ponto == null ? 'Ponto incluído com sucesso.' : 'Ponto alterado com sucesso.')
                            //Navigator.of(context).pop(),
                          });
                        });
                        // final snackBar = SnackBar(
                        // behavior: SnackBarBehavior.floating,
                        // content: Text(widget.pontoAtual == null ? 'Ponto incluído com sucesso.' : 'Ponto alterado com sucesso.'),
                        // );
                        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        //_mostrarMensagem(widget.pontoAtual == null ? 'Ponto incluído com sucesso.' : 'Ponto alterado com sucesso.');
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Confirmar'),
                  ),
                ),
              ],
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 16.0),
            //   child: ElevatedButton(
            //     onPressed: () => Navigator.of(context).pop(),
            //     child: const Text('Cancelar'),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 16.0),
            //   child: ElevatedButton(
            //     onPressed: () {
            //       if(_formKey.currentState != null && dadosValidos()){
            //         setState(() {
            //           _dao.salvar(novoPonto).then((success) => {
            //             //_atualizarLista()
            //             _mostrarMensagem(widget.ponto == null ? 'Ponto incluído com sucesso.' : 'Ponto alterado com sucesso.')
            //             //Navigator.of(context).pop(),
            //           });
            //         });
            //         // final snackBar = SnackBar(
            //         // behavior: SnackBarBehavior.floating,
            //         // content: Text(widget.pontoAtual == null ? 'Ponto incluído com sucesso.' : 'Ponto alterado com sucesso.'),
            //         // );
            //         // ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //         //_mostrarMensagem(widget.pontoAtual == null ? 'Ponto incluído com sucesso.' : 'Ponto alterado com sucesso.');
            //         Navigator.of(context).pop();
            //       }
            //     },
            //     child: const Text('Confirmar'),
            //   ),
            // ),
          ],
        )
      )
    );
  }

  Future<bool> _onVoltarClick() async {
    Navigator.of(context).pop();
    return true;
  }

  _addData(){
    final dataFormatada = _dataController.text;
    DateTime data = DateTime.now();
    if(dataFormatada.isNotEmpty){
      data = _dateFormat.parse(dataFormatada);
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
    Position? position = await Geolocator.getLastKnownPosition();
        _latitudeController.text = position != null ? position.latitude.toString() : '0';
        _longitudeController.text = position != null ? position.longitude.toString() : '0';
            //'Latitude: ${position.latitude} | Longitude: ${position.longitude}');
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
    Position position = await Geolocator.getCurrentPosition();
    _latitudeController.text = position.latitude.toString();
    _longitudeController.text = position.longitude.toString();
          //'Latitude: ${position.latitude} | Longitude: ${position.longitude}');

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
    latitude: double.parse(_latitudeController.text),
    longitude: double.parse(_longitudeController.text),
  );

}