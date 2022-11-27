import 'package:turismo/database/database_provider.dart';
import '../model/ponto.dart';

class PontoDao{
  final databaseProvider = DatabaseProvider.instance;

  Future<bool> salvar(Ponto ponto) async{

    final database = await databaseProvider.database;
    final valores = ponto.toMap();

    if(ponto.id == null){
      ponto.id = await database.insert(Ponto.NOME_TABELA, valores);
      return true;
    }else{
      final registrosAtualizados = await database.update(
          Ponto.NOME_TABELA,
          valores,
        where: '${Ponto.CAMPO_ID} = ?',
        whereArgs: [ponto.id],
      );
      return registrosAtualizados > 0;
    }
  }

  Future<bool> remover(int id) async{
    final database = await databaseProvider.database;
    final registrosAtualizados = await database.delete(
      Ponto.NOME_TABELA,
      where: '${Ponto.CAMPO_ID} = ?',
      whereArgs: [id],
    );
    return registrosAtualizados > 0;
  }

  Future<List<Ponto>> listar({
    String filtro = '',
    String campoOrdenacao = Ponto.CAMPO_ID,
    bool usarOrdemDecrescente = false,
  }) async{
    String? where;

    if(filtro.isNotEmpty){
      where = "UPPER(${Ponto.CAMPO_DESCRICAO}) LIKE '${filtro.toUpperCase()}%'";
    }

    var orderBy = campoOrdenacao;
    if(usarOrdemDecrescente){
      orderBy += ' DESC';
    }

    final database = await databaseProvider.database;
    final resultado = await database.query(
      Ponto.NOME_TABELA,
      columns: [
        Ponto.CAMPO_ID,
        Ponto.CAMPO_DETALHE,
        Ponto.CAMPO_DESCRICAO,
        Ponto.CAMPO_DIFERENCIAL,
        Ponto.CAMPO_DATA_INCLUSAO,
        Ponto.CAMPO_LATITUDE,
        Ponto.CAMPO_LONGITUDE,
        Ponto.CAMPO_TIPO_IMAGEM,
        Ponto.CAMPO_CAMINHO_IMAGEM,
        Ponto.CAMPO_CAMINHO_VIDEO
      ],
      where: where,
      orderBy: orderBy,
    );
    return resultado.map((m) => Ponto.fromMap(m)).toList();
  }
}