import 'dart:math';
import 'dart:io';
import 'package:turismo/model/ponto.dart';
import 'package:flutter/material.dart';

typedef void StringCallback(String val);
class VisualizadorImagem extends StatefulWidget {
  final String tipoImagem;
  late  String? caminhoImagem;
  final double size;

   VisualizadorImagem({
    Key? key,
    required this.tipoImagem,
    this.caminhoImagem,
    this.size = 50,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VisualizadorImagemState();

}

class _VisualizadorImagemState extends State<VisualizadorImagem> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        image: _criarWidgetImagem(),
      ),
    );
  }

  DecorationImage? _criarWidgetImagem() {
    var caminho = widget.caminhoImagem;
    if(caminho == null) caminho = 'assets/imagem_${Random().nextInt(3) + 1}.jpg';
    if (widget.tipoImagem == Ponto.TIPO_IMAGEM_NETWORK) {
      if(widget.caminhoImagem == null || widget.caminhoImagem!.contains('assets')) {
        final random = Random();
        caminho = 'https://picsum.photos/200?random=${random.nextInt(
            100) + 1}';
        widget.caminhoImagem = caminho;
      }
      return DecorationImage(
        image: NetworkImage(
          caminho,
        ),

      );
    } else if (widget.tipoImagem == Ponto.TIPO_IMAGEM_FILE) {
      if (widget.caminhoImagem?.isNotEmpty == true) {
        final file = File(widget.caminhoImagem!);
        widget.caminhoImagem = file.path;
        return DecorationImage(
          image: FileImage(file),
        );
      } else {
        return null;
      }
    } else {
      if(widget.caminhoImagem == null || widget.caminhoImagem!.contains('picsum')) {
        final random = Random();
        final caminho = 'assets/imagem_${random.nextInt(3) + 1}.jpg';
        widget.caminhoImagem = caminho;
      }
      return DecorationImage(
        image: AssetImage(caminho),
      );
    }
  }

}