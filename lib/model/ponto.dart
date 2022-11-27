import 'package:intl/intl.dart';

class Ponto{

  static const CAMPO_ID = 'id';
  static const CAMPO_DETALHE = 'detalhe';
  static const CAMPO_DESCRICAO = 'descricao';
  static const CAMPO_DIFERENCIAL = 'diferencial';
  static const CAMPO_DATA_INCLUSAO = 'data_inclusao';
  static const CAMPO_LATITUDE = 'latitude';
  static const CAMPO_LONGITUDE = 'longitude';
  static const CAMPO_TIPO_IMAGEM = 'tipo_imagem';
  static const CAMPO_CAMINHO_IMAGEM = 'caminho_imagem';
  static const CAMPO_CAMINHO_VIDEO = 'caminho_video';
  static const TIPO_IMAGEM_NETWORK = 'network';
  static const TIPO_IMAGEM_ASSETS = 'assets';
  static const TIPO_IMAGEM_FILE = 'file';
  static const TIPOS_PERMITIDOS = [
    TIPO_IMAGEM_NETWORK,
    TIPO_IMAGEM_ASSETS,
    TIPO_IMAGEM_FILE,
  ];
  static const NOME_TABELA = 'ponto';


  int? id;
  String detalhe;
  String descricao;
  String diferencial;
  DateTime? data_inclusao;
  double latitude;
  double longitude;
  String? _tipoImagem;
  String? caminhoImagem;
  String? caminhoVideo;

  Ponto({
    this.id,
    required this.detalhe,
    required this.descricao,
    required this.diferencial,
    required this.data_inclusao,
    required this.latitude,
    required this.longitude,
    String? tipoImagem,
    this.caminhoImagem,
    this.caminhoVideo,
  }) : _tipoImagem = tipoImagem;

  String get tipoImagem => _tipoImagem ?? TIPO_IMAGEM_ASSETS;

  set tipoImagem(String tipoImagem) => _tipoImagem =
  (TIPOS_PERMITIDOS.contains(tipoImagem) ? tipoImagem : TIPO_IMAGEM_ASSETS);

  String get dataInclusaoFormatada{
    if(data_inclusao == null){
      return '';
    }
    return DateFormat('dd/MM/yyyy').format(data_inclusao!);
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    CAMPO_ID: id,
    CAMPO_DETALHE: detalhe,
    CAMPO_DESCRICAO: descricao,
    CAMPO_DIFERENCIAL: diferencial,
    CAMPO_DATA_INCLUSAO: DateFormat('yyyy-MM-dd').format(data_inclusao!),
    CAMPO_LATITUDE: latitude,
    CAMPO_LONGITUDE: longitude,
  };

  Map<String, dynamic> routeMap() => <String, dynamic>{
    CAMPO_ID: id,
    CAMPO_DETALHE: detalhe,
    CAMPO_DESCRICAO: descricao,
    CAMPO_DIFERENCIAL: diferencial,
    CAMPO_DATA_INCLUSAO: data_inclusao!,
    CAMPO_LATITUDE: latitude,
    CAMPO_LONGITUDE: longitude,
  };

  factory Ponto.fromMap(Map<String, dynamic> map) => Ponto(
    id: map[CAMPO_ID] is int ? map[CAMPO_ID] : null,
    detalhe: map[CAMPO_DETALHE] is String ? map[CAMPO_DETALHE] : '',
    descricao: map[CAMPO_DESCRICAO] is String ? map[CAMPO_DESCRICAO] : '',
    diferencial: map[CAMPO_DIFERENCIAL] is String ? map[CAMPO_DIFERENCIAL] : '',
    data_inclusao: map[CAMPO_DATA_INCLUSAO] is String ? DateFormat("yyyy-MM-dd").parse(map[CAMPO_DATA_INCLUSAO]) : null,
    latitude: map[CAMPO_LATITUDE] is double ? map[CAMPO_LATITUDE] : 0,
    longitude: map[CAMPO_LONGITUDE] is double ? map[CAMPO_LONGITUDE] : 0,
    tipoImagem: map[CAMPO_TIPO_IMAGEM] is String ? map[CAMPO_TIPO_IMAGEM] : '',
    caminhoImagem:
    map[CAMPO_CAMINHO_IMAGEM] is String ? map[CAMPO_CAMINHO_IMAGEM] : null,
    caminhoVideo:
    map[CAMPO_CAMINHO_VIDEO] is String ? map[CAMPO_CAMINHO_VIDEO] : null,
  );

  static String getTipoImagemLabel(String tipoImagem) {
    switch (tipoImagem) {
      case TIPO_IMAGEM_NETWORK:
        return 'Da internet';
      case TIPO_IMAGEM_ASSETS:
        return 'Arquivo interno';
      case TIPO_IMAGEM_FILE:
        return 'Arquivo externo';
      default:
        return 'Desconhecido';
    }
  }
}