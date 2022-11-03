import 'package:intl/intl.dart';

class Ponto{

  static const CAMPO_ID = 'id';
  static const CAMPO_DETALHE = 'detalhe';
  static const CAMPO_DESCRICAO = 'descricao';
  static const CAMPO_DIFERENCIAL = 'diferencial';
  static const CAMPO_DATA_INCLUSAO = 'data_inclusao';
  static const CAMPO_LATITUDE = 'latitude';
  static const CAMPO_LONGITUDE = 'longitude';
  static const NOME_TABELA = 'ponto';

  int? id;
  String detalhe;
  String descricao;
  String diferencial;
  DateTime? data_inclusao;
  double latitude;
  double longitude;

  Ponto({
    this.id,
    required this.detalhe,
    required this.descricao,
    required this.diferencial,
    required this.data_inclusao,
    required this.latitude,
    required this.longitude
  });

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
  );
}