import 'package:flutter/material.dart';
import 'package:turismo/model/ponto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FiltroPage extends StatefulWidget{

  static const ROUTE_NAME = '/filtro';
  static const CHAVE_CAMPO_ORDENACAO = 'campoOrdenacao';
  static const CHAVE_USAR_ORDEM_DECRESCENTE = 'usarOrdenacaoDecrescente';
  static const CHAVE_FILTRO_DESCRICAO = 'filtroDescricao';

  @override
  _FiltroPageState createState() => _FiltroPageState();
}

class _FiltroPageState extends State<FiltroPage>{
  final _camposParaOrdenacao = {
    Ponto.CAMPO_ID: 'Código',
    Ponto.CAMPO_DETALHE: 'Detalhe',
    Ponto.CAMPO_DESCRICAO: 'Descrição',
    Ponto.CAMPO_DIFERENCIAL: 'Diferencial',
    Ponto.CAMPO_DATA_INCLUSAO: 'Data de Inclusão'
  };

  late final SharedPreferences _prefs;

  final _descricaoController = TextEditingController();
  String _campoOrdenacao = Ponto.CAMPO_ID;
  bool _usarOrdenacaoDecrescente = false;
  bool _alterouValores = false;

  void initState(){
    super.initState();
    _carregarSharedPreferences();
  }

  void _carregarSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      _campoOrdenacao = _prefs.getString(FiltroPage.CHAVE_CAMPO_ORDENACAO) ?? Ponto.CAMPO_ID;
      _usarOrdenacaoDecrescente =
          _prefs.getBool(FiltroPage.CHAVE_USAR_ORDEM_DECRESCENTE) ?? false;
      _descricaoController.text = _prefs.getString(
          FiltroPage.CHAVE_FILTRO_DESCRICAO) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(title: Text('Filtro e ordenação'),),
        body: _criarBody(),
      ),
      onWillPop: _onVoltarClick,
    );
  }

  Widget _criarBody() {
    return ListView(
      children: [
        Padding(padding: EdgeInsets.only(left: 10, top: 10),
            child: Text('Campos para ordenação')
        ),
        for (final campo in _camposParaOrdenacao.keys)
          Row(
            children: [
              Radio(
                value: campo,
                groupValue: _campoOrdenacao,
                onChanged: _onCampoOrdenacaoChanged,
              ),
              Text(_camposParaOrdenacao[campo]?? ""),
            ],
          ),
        Divider(),
        Row(
          children: [
            Checkbox(
              value: _usarOrdenacaoDecrescente,
              onChanged: _onUsarOrdemDecrescenteChanged,
            ),
            Text('Usar ordem decrescente'),
          ],
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            decoration: InputDecoration(labelText: 'Descrição começa com'),
            controller: _descricaoController,
            onChanged: _onFiltroDescricaoChanged,
          ),
        )

      ],
    );
  }

  Future<bool> _onVoltarClick() async {
    Navigator.of(context).pop(_alterouValores);
    return true;
  }

  void _onCampoOrdenacaoChanged(String? valor){
    _prefs.setString(FiltroPage.CHAVE_CAMPO_ORDENACAO, valor ?? '');
    _alterouValores = true;
    setState(() {
      _campoOrdenacao = valor ?? '';
    });
  }

  void _onUsarOrdemDecrescenteChanged(bool? valor){
    _prefs.setBool(FiltroPage.CHAVE_USAR_ORDEM_DECRESCENTE, valor == true);
    _alterouValores = true;
    setState(() {
      _usarOrdenacaoDecrescente
      = valor == true;
    });
  }

  void _onFiltroDescricaoChanged(String? valor){
    _prefs.setString(FiltroPage.CHAVE_FILTRO_DESCRICAO, valor ?? '');
    _alterouValores = true;
  }

}