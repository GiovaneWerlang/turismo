import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turismo/dao/ponto_dao.dart';
import 'package:turismo/model/ponto.dart';
import 'package:turismo/widgets/conteudo_form_dialog.dart';

import 'detalhes_ponto_page.dart';
import 'filtro_page.dart';

class ListaPontosPage extends StatefulWidget{

  @override
  _ListaPontosPageState createState() => _ListaPontosPageState();
}

class _ListaPontosPageState extends State<ListaPontosPage>{

  static const ACAO_EDITAR = 'editar';
  static const ACAO_EXCLUIR = 'excluir';
  static const ACAO_DETALHAR = 'detalhar';

  final _pontos = <Ponto>[];
  final _dao = PontoDao();
  var _carregando = false;

  @override
  void initState(){
    super.initState();
    _atualizarLista();
  }

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
        tooltip: 'Filtro e Ordenação',
        icon: Icon(Icons.filter_list),
        )
      ],
    );
  }

  Widget criarBody(){
    if(_carregando){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.center,
            child: CircularProgressIndicator(),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('Carregando tarefas',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green
                ),
              ),
            ),
          )
        ],

      );
    }
    if(_pontos.isEmpty){
      return const Center(
        child: Text('Nenhum ponto turístico cadastrado!',
        style: TextStyle(fontSize: 20)
        ),);
    }

    return ListView.separated(
      itemCount: _pontos.length,
      itemBuilder: (BuildContext context, int index){
        final ponto = _pontos[index];
        return PopupMenuButton<String>(
          child: ListTile(
            title: Text('${ponto.detalhe} - ${ponto.id}'),
            isThreeLine: true,
            subtitle: Text('${ponto.descricao}\nData de Inclusão - ${ponto.dataInclusaoFormatada}'),
          ),
          itemBuilder: (BuildContext context) => criarItensMenuPopup(),
          onSelected: (String valor){
            if(valor == ACAO_EDITAR){
              _abrirForm(pontoAtual: ponto);
            }else if(valor == ACAO_EXCLUIR){
              _excluir(ponto);
            }else if(valor == ACAO_DETALHAR){
              Navigator.of(context).push(MaterialPageRoute(//outra forma de abrir uma page
                builder: (_) => DetalhesPontoPage(ponto: ponto),
              ));
            }
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }

  void _abrirForm({Ponto? pontoAtual}){
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
                    _dao.salvar(novoPonto).then((success) => {
                      _atualizarLista()
                    });
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

  Future<void> _abrirPaginaFiltro() async {
    final navigator = Navigator.of(context);
    navigator.pushNamed(FiltroPage.ROUTE_NAME).then((_alterouValores) =>
    {
      if(_alterouValores == true){
        _atualizarLista()
      }
    });
  }

  Future<void> _atualizarLista() async{
    setState(() {
      _carregando = true;
    });
    await Future.delayed(Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final campoOrdenacao = prefs.getString(FiltroPage.CHAVE_CAMPO_ORDENACAO) ?? Ponto.CAMPO_ID;
    final usarOrdemDecrescente = prefs.getBool(FiltroPage.CHAVE_USAR_ORDEM_DECRESCENTE) == true;
    final filtroDescricao = prefs.getString(FiltroPage.CHAVE_FILTRO_DESCRICAO) ?? '';

    final pontos = await _dao.listar(
      filtro: filtroDescricao,
      campoOrdenacao: campoOrdenacao,
      usarOrdemDecrescente: usarOrdemDecrescente,
    );
    setState(() {
      _pontos.clear();
      if(pontos.isNotEmpty){
        _pontos.addAll(pontos);
      }
      _carregando = false;
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
      ),
      PopupMenuItem<String>(
        value: ACAO_DETALHAR,
        child: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.purple),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Detalhar'),
            ),
          ],
        ),
      ),
    ];
  }

  void _excluir(Ponto ponto){
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
                if(ponto.id == null){
                  return;
                }
                _dao.remover(ponto.id!).then((success) => {
                  if(success){
                    _atualizarLista()
                  }
                });
              },
            )
          ],
        );
      }
    );
  }
}