import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turismo/model/ponto.dart';

class ConteudoFormDialog extends StatefulWidget{

  final Ponto? pontoAtual;

  ConteudoFormDialog( {Key? key, this.pontoAtual}) : super(key: key);

  ConteudoFormDialogState createState() => ConteudoFormDialogState();
}

class ConteudoFormDialogState extends State<ConteudoFormDialog>{

  final _formKey = GlobalKey<FormState>();
  final _detalheController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _diferencialController = TextEditingController();
  final _dataController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  void initState(){
    super.initState();
    if(widget.pontoAtual != null){
      _detalheController.text = widget.pontoAtual!.detalhe;
      _descricaoController.text = widget.pontoAtual!.descricao;
      _diferencialController.text = widget.pontoAtual!.diferencial;
      _dataController.text = widget.pontoAtual!.dataInclusaoFormatada;
    }
    _addData();
  }

  Widget build(BuildContext context){
    return Form(
      key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: _detalheController,
                  decoration: InputDecoration(labelText: 'Detalhes'),
                  validator: (String? valor){
                    if(valor == null || valor.isEmpty){
                      return "Informe os detalhes";
                    }
                    return null;
                  }),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (String? valor){
                  if(valor == null || valor.isEmpty){
                    return "Informe a descrição";
                  }
                  return null;
                }),
              TextFormField(
                  controller: _diferencialController,
                  decoration: InputDecoration(labelText: 'Diferenciais'),
                  validator: (String? valor){
                    if(valor == null || valor.isEmpty){
                      return "Informe os diferenciais";
                    }
                    return null;
                  })
            ],
          )
        ),
    );
  }

  _addData(){
    final dataFormatada = _dataController.text;
    DateTime data = DateTime.now();
    if(dataFormatada.isNotEmpty){
      data = _dateFormat.parse(dataFormatada);
    }
    _dataController.text = _dateFormat.format(data);
  }

  bool dadosValidos() => _formKey.currentState?.validate() == true;
  Ponto get novoPonto => Ponto(
    id: widget.pontoAtual?.id ?? 0,
    detalhe: _detalheController.text,
    descricao: _descricaoController.text,
    diferencial: _diferencialController.text,
    data_inclusao: _dataController.text.isEmpty ? null : _dateFormat.parse(_dataController.text)
  );
}