import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:turismo/model/ponto.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../dao/ponto_dao.dart';
import '../model/cep.dart';
import '../services/cep_service.dart';
import '../widgets/visualizador_de_imagem.dart';
import 'camera_page.dart';
import 'mapa_page.dart';

class PontoFormPage extends StatefulWidget{
  static const imagem = 'imagem';
  static const video = 'video';

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

  late String _tipoImagem;
  String? _caminhoImagem;
  String? _caminhoVideo;
  final _picker = ImagePicker();
  VideoPlayerController? _videoPlayerController;
  bool _reproduzindoVideo = false;

  final _cepController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();

  final _controller = TextEditingController();

  final _service = CepService();
  final _cepFormatter = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {'#' : RegExp(r'[0-9]')}
  );
  Cep? _cep;
  var _pesquisandoCep = false;

  void initState(){
    super.initState();
    if(widget.ponto != null){
      _detalheController.text = widget.ponto!.detalhe;
      _descricaoController.text = widget.ponto!.descricao;
      _diferencialController.text = widget.ponto!.diferencial;
      _dataController.text = widget.ponto!.data_inclusao.toString();
      _latitudeController.text = widget.ponto!.latitude.toString();
      _longitudeController.text = widget.ponto!.longitude.toString();
      _tipoImagem = widget.ponto!.tipoImagem;
      _caminhoImagem = widget.ponto!.caminhoImagem;
      _caminhoVideo = widget.ponto!.caminhoVideo;
      _cepController.text = widget.ponto!.cep.toString();
      _cidadeController.text = widget.ponto!.cidade.toString();
      _ufController.text = widget.ponto!.uf.toString();
    } else {
      _tipoImagem = Ponto.TIPO_IMAGEM_ASSETS;
      _cidadeController.text = ' ';
      _ufController.text = ' ';
    }
    _inicializarVideoPlayerController();

    _addData();
  }

@override
void dispose() {
  _videoPlayerController?.dispose();
  super.dispose();
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
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
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
                TextFormField(
                    controller: _cepController,
                    decoration: InputDecoration(
                        labelText: 'CEP',
                        suffixIcon: _pesquisandoCep ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ) : IconButton(
                          onPressed: _findCep,
                          icon: const Icon(Icons.search),
                        ),
                    ),
                    inputFormatters: [_cepFormatter],
                    validator: (String? value){
                      if(value == null || value.isEmpty || !_cepFormatter.isFill()){
                        return 'Informe um cep válido';
                      }
                      return null;
                    },
                ),
                TextFormField(
                    controller: _cidadeController,
                    decoration: InputDecoration(labelText: 'Cidade'),
                    // validator: (String? valor){
                    //   if(valor == null || valor.trim().isEmpty){
                    //     return "Informe a cidade";
                    //   }
                    //   return null;
                    // }
                    ),
                TextFormField(
                    controller: _ufController,
                    decoration: InputDecoration(labelText: 'UF'),
                    // validator: (String? valor){
                    //   if(valor == null || valor.trim().isEmpty){
                    //     return "Informe a uf";
                    //   }
                    //   return null;
                    // }
                    ),


                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _obterLocalizacaoAtual();
                    },
                    child: Text(widget.ponto.id == null ? 'Inserir Localização' : 'Alterar Localização'),
                  ),
                ),


                TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        label: Text('Localização incorreta?'),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.map),
                            tooltip: 'Abrir no Mapa',
                            onPressed: _abrirNoMapaExterno,
                          )
                    ),
                ),

                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Text('Tipo da Imagem'),
                ),
                DropdownButton(
                  value: _tipoImagem,
                  items: Ponto.TIPOS_PERMITIDOS
                      .map((tipoImagem) => DropdownMenuItem(
                    value: tipoImagem,
                    child: Text(Ponto.getTipoImagemLabel(tipoImagem)),
                  ))
                      .toList(),
                  isExpanded: true,
                  onChanged: (String? novoValor) {
                    if (novoValor?.isNotEmpty == true) {
                      setState(() {
                        _tipoImagem = novoValor!;
                        if(_tipoImagem ==  Ponto.TIPO_IMAGEM_NETWORK){
                          if(_caminhoImagem == null)
                            _caminhoImagem = 'https://picsum.photos/200?random=${Random().nextInt(100) + 1}';
                        }
                        if(_tipoImagem ==  Ponto.TIPO_IMAGEM_ASSETS){
                          if(_caminhoImagem == null)
                          _caminhoImagem = 'assets/imagem_${Random().nextInt(3) + 1}.jpg';
                        }
                      });
                    }
                  },
                ),
                if (_tipoImagem == Ponto.TIPO_IMAGEM_FILE) ...[
                  ElevatedButton(
                    child: const Text('Obter da Galeria'),
                    onPressed: () => _usarImagePicker(
                        ImageSource.gallery, PontoFormPage.imagem),
                  ),
                  ElevatedButton(
                    child: const Text('Usar câmera interna'),
                    onPressed: () => _usarCamera(PontoFormPage.imagem),
                  ),
                  ElevatedButton(
                    child: const Text('Usar câmera externa'),
                    onPressed: () => _usarImagePicker(
                        ImageSource.camera, PontoFormPage.imagem),
                  ),
                ],
                // VisualizadorImagem(
                //   tipoImagem: _tipoImagem,
                //   caminhoImagem: _caminhoImagem,
                //   size: constraints.maxWidth,
                // ),
                Container(
                width: ((MediaQuery.of(context).size.width) / 0.5),
                height:  ((MediaQuery.of(context).size.width) / 0.5),
                decoration: BoxDecoration(
                image: _criarWidgetImagem(),
                ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Text('Vídeo'),
                ),
                ElevatedButton(
                  child: const Text('Obter da Galeria'),
                  onPressed: () => _usarImagePicker(
                      ImageSource.gallery, PontoFormPage.video),
                ),
                ElevatedButton(
                  child: const Text('Usar câmera interna'),
                  onPressed: () => _usarCamera(PontoFormPage.video),
                ),
                ElevatedButton(
                  child: const Text('Usar câmera externa'),
                  onPressed: () => _usarImagePicker(
                      ImageSource.camera, PontoFormPage.video),
                ),
                _criarWidgetVideo(),
                if (_videoPlayerController != null)
                  ElevatedButton(
                    child: Icon(_videoPlayerController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: _iniciarPararVideo,
                  ),

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
          ),
        );
      },
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
    _mostrarMensagem('Localização incluída com sucesso.');
    _abriNoMapaInterno();
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
    tipoImagem: _tipoImagem,
    caminhoImagem: _caminhoImagem,
    caminhoVideo: _caminhoVideo,
    cep: _cepController.text,
    cidade: _cidadeController.text,
    uf: _ufController.text,
  );

  void _abriNoMapaInterno(){
    if(_localizacaoAtual == null){
      _mostrarMensagem("A localização ainda não foi informada.");
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

  void _abrirNoMapaExterno (){
    if(_controller.text.trim().isEmpty){
      _mostrarMensagem("Informe um endereço ou ponto de referencia.");
      return;
    }
    MapsLauncher.launchQuery(_controller.text);
  }

  Future<void> _usarImagePicker(ImageSource origem, String tipo) async {
    XFile? arquivo;
    if (tipo == PontoFormPage.imagem) {
      arquivo = await _picker.pickImage(source: origem);
    } else {
      arquivo = await _picker.pickVideo(source: origem);
    }
    if (arquivo == null) {
      return;
    }
    return _tratarArquivo(arquivo, tipo);
  }

  Future<void> _tratarArquivo(XFile arquivo, String tipo) async {
    final diretorioBase = await getApplicationDocumentsDirectory();
    final idArquivo = Uuid().v1();
    var caminho = '${diretorioBase.path}/$idArquivo' +
        (tipo == PontoFormPage.imagem ? '.jpg' : '.mp4');
    await arquivo.saveTo(caminho);
    if (tipo == PontoFormPage.imagem) {
      setState(() {
        _caminhoImagem = caminho;
      });
    } else {
      _caminhoVideo = caminho;
      await _inicializarVideoPlayerController();
    }
  }

  Future<void> _usarCamera(String tipo) async {
    final arquivo = await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CameraPage(tipo: tipo),
    ));
    if (arquivo == null) {
      return;
    }
    return _tratarArquivo(arquivo, tipo);
  }

  Future<void> _inicializarVideoPlayerController() async {
    if (_caminhoVideo == null || _caminhoVideo!.isEmpty) {
      return;
    }
    if (_videoPlayerController != null) {
      await _videoPlayerController!.dispose();
      _videoPlayerController = null;
    }
    final arquivoVideo = File(_caminhoVideo!);
    _videoPlayerController = VideoPlayerController.file(arquivoVideo);
    _videoPlayerController!.addListener(() {
      if (_reproduzindoVideo && !_videoPlayerController!.value.isPlaying) {
        setState(() {});
      }
    });
    await _videoPlayerController!.initialize();
    setState(() {});
  }

  Widget _criarWidgetVideo() {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      child: VideoPlayer(_videoPlayerController!),
    );
  }

  void _iniciarPararVideo() {
    setState(() {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
        _reproduzindoVideo = false;
      } else {
        _videoPlayerController!.play();
        _reproduzindoVideo = true;
      }
    });
  }

  Future<void> _findCep() async{
    if(_formKey.currentState == null || !_formKey.currentState!.validate()){
      return;
    }
    setState(() {
      _pesquisandoCep = true;
    });
    try{
      _cep = await _service.findCepAsObject(_cepFormatter.getUnmaskedText());
    } catch(e){
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ocorreu um erro ao consultar o CEP. Tente novamente'),
      ));
    }finally{
      if(_cep != null) {
        _cidadeController.text = _cep!.localidade!;
        _ufController.text = _cep!.uf!;
      }
    }
    setState(() {
      _pesquisandoCep = false;
    });
  }

  DecorationImage? _criarWidgetImagem() {
    var caminho = _caminhoImagem;
    if(caminho == null || caminho.isEmpty){
      caminho = 'assets/imagem_${Random().nextInt(3) + 1}.jpg';
    }
      if (_tipoImagem == Ponto.TIPO_IMAGEM_NETWORK) {
        if(_caminhoImagem == null || _caminhoImagem!.contains('assets')) {
          final random = Random();
          caminho = 'https://picsum.photos/200?random=${random.nextInt(
              100) + 1}';
          _caminhoImagem = caminho;
        }
        return DecorationImage(
          image: NetworkImage(
            caminho,
          ),

        );
      } else if(_tipoImagem == Ponto.TIPO_IMAGEM_FILE) {
        if (_caminhoImagem?.isNotEmpty == true) {
          final file = File(_caminhoImagem!);
          _caminhoImagem = file.path;
          return DecorationImage(
            image: FileImage(file),
          );
        } else {
          return null;
        }
      } else {
        if(_caminhoImagem == null || _caminhoImagem!.contains('picsum')) {
          final random = Random();
          final caminho = 'assets/imagem_${random.nextInt(3) + 1}.jpg';
          _caminhoImagem = caminho;
        }
        return DecorationImage(
          image: AssetImage(caminho),
        );
      }
    }

}