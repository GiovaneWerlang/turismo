import 'package:flutter/material.dart';
import 'package:turismo/model/ponto.dart';
import 'package:turismo/widgets/conteudo_form_dialog.dart';

import 'filtro_page.dart';

class ListaPontosPage extends StatefulWidget{

  @override
  _ListaPontosPageState createState() => _ListaPontosPageState();
}

class _ListaPontosPageState extends State<ListaPontosPage>{

  var _ultimoId = 0;

  static const ACAO_EDITAR = 'editar';
  static const ACAO_EXCLUIR = 'excluir';

  final pontos = <Ponto>[];

  Widget build(BuildContext context){
    return Scaffold(
      appBar: criarAppBar(),
      body: criarBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirForm,
        tooltip: 'Novo Ponto',
        child: Icon(Icons.add),
      ),
    );
  }

  AppBar criarAppBar(){
    return AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0)
        )
      ),
      title: const Text('Pontos Turísticos'),
      actions: [
        IconButton(
        onPressed: _abrirPaginaFiltro,
        icon: Icon(Icons.filter_list),
        )
      ],
    );
  }

  Widget criarBody(){
    if(pontos.isEmpty){
      return const Center(
        child: Text('Nenhum ponto turístico cadastrado!',
        style: TextStyle(fontSize: 20)
        ),);
    }

    return ListView.separated(
      itemCount: pontos.length,
      itemBuilder: (BuildContext context, int index){
        final ponto = pontos[index];
        return PopupMenuButton<String>(
          child: ListTile(
            title: Text('${ponto.detalhe} - ${ponto.id}'),
            isThreeLine: true,
            subtitle: Text('${ponto.descricao}\nData de Inclusão - ${ponto.dataInclusaoFormatada}'),
          ),
          itemBuilder: (BuildContext context) => criarItensMenuPopup(),
          onSelected: (String valor){
            if(valor == ACAO_EDITAR){
              _abrirForm(pontoAtual: ponto, indice: index);
            }else if(valor == ACAO_EXCLUIR){
              _excluir(index);
            }
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }

  void _abrirForm({Ponto? pontoAtual, int? indice}){
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(pontoAtual == null ? 'Novo Ponto Turístico' : 'Alterar Ponto ${pontoAtual.id}'),
          content: ConteudoFormDialog(key: key, pontoAtual: pontoAtual,),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Confirmar'),
              onPressed: (){
                if(key.currentState != null && key.currentState!.dadosValidos()){
                  setState(() {
                    final novoPonto = key.currentState!.novoPonto;
                    if(indice == null){
                      novoPonto.id = ++ _ultimoId;
                      pontos.add(novoPonto);
                    }else{
                      pontos[indice] = novoPonto;
                    }
                  });
                  final snackBar = SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(pontoAtual == null ? 'Ponto incluído com sucesso.' : 'Ponto alterado com sucesso.'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        );
      }
    );
  }

  void _abrirPaginaFiltro(){
    final navigator = Navigator.of(context);
    navigator.pushNamed(FiltroPage.ROUTE_NAME).then((_alterouValores) =>
    {
      if(_alterouValores == true){
        //Todo
      }
    });
  }

  List<PopupMenuEntry<String>> criarItensMenuPopup(){
    return [
      PopupMenuItem<String>(
        value: ACAO_EDITAR,
        child: Row(
          children: const [
            Icon(Icons.edit, color: Colors.amber),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Editar'),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: ACAO_EXCLUIR,
        child: Row(
          children: const [
            Icon(Icons.delete, color: Colors.redAccent),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Excluir'),
            )
          ],
        ),
      )
    ];
  }

  void _excluir(int index){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Atenção'),
              )
            ],
          ),
          content: const Text('Esse ponto turístico será removido permanentemente!'),
          actions: [
            TextButton(
               child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                final snackBar = SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Ponto excluído com sucesso.'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
                setState(() {
                  pontos.removeAt(index);
                });
              }
            )
          ],
        );
      }
    );
  }
}