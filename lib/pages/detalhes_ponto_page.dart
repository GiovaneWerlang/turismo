import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/ponto.dart';

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
      padding: EdgeInsets.all(10),
      child: ListView(
        children: [
          Row(
            children: [
              Campo(descricao: 'Código: '),
              Valor(valor: '${widget.ponto.id}'),
            ],
          ),
          Row(
            children: [
              Campo(descricao: 'Detalhe: '),
              Valor(valor: widget.ponto.detalhe),
            ],
          ),
          Row(
            children: [
              Campo(descricao: 'Descrição: '),
              Valor(valor: widget.ponto.descricao),
            ],
          ),
          Row(
            children: [
              Campo(descricao: 'Diferencial: '),
              Valor(valor: widget.ponto.diferencial),
            ],
          ),
          Row(
            children: [
              Campo(descricao: 'Detalhe: '),
              Valor(valor: widget.ponto.dataInclusaoFormatada),
            ],
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