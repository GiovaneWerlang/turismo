import 'package:intl/intl.dart';

class Ponto{

  static const CAMPO_ID = '_id';
  static const CAMPO_DETALHE = 'detalhe';
  static const CAMPO_DESCRICAO = 'descricao';
  static const CAMPO_DIFERENCIAL = 'diferencial';
  static const CAMPO_DATA_INCLUSAO = 'data_inclusao';

  int id;
  String detalhe;
  String descricao;
  String diferencial;
  DateTime? data_inclusao;

  Ponto({required this.id, required this.detalhe, required this.descricao, required this.diferencial, required this.data_inclusao});

  String get dataInclusaoFormatada{
    if(data_inclusao == null){
      return "";
    }
    return DateFormat('dd/MM/yyyy').format(data_inclusao!);
  }
}