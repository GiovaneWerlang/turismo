import 'package:sqflite/sqflite.dart';
import 'package:turismo/model/ponto.dart';

class DatabaseProvider{

  static const _dbName = 'pontos_turismo.db';
  static const _dbVersion = 4;

  DatabaseProvider._init();
  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;

  Future<Database> get database async {
    if(_database == null){
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<Database> _initDatabase() async{
    final databasesPath = await getDatabasesPath();
    final dbPath = '$databasesPath/$_dbName';

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async{
    await db.execute('''
      CREATE TABLE ${Ponto.NOME_TABELA}(
        ${Ponto.CAMPO_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Ponto.CAMPO_DETALHE} TEXT NOT NULL,
        ${Ponto.CAMPO_DESCRICAO} TEXT, 
        ${Ponto.CAMPO_DIFERENCIAL} TEXT, 
        ${Ponto.CAMPO_DATA_INCLUSAO} TEXT,
        ${Ponto.CAMPO_LATITUDE} REAL NOT NULL DEFAULT 0,
        ${Ponto.CAMPO_LONGITUDE} REAL NOT NULL DEFAULT 0,
        ${Ponto.CAMPO_TIPO_IMAGEM} TEXT NOT NULL DEFAULT ' ',
        ${Ponto.CAMPO_CAMINHO_IMAGEM} TEXT,
        ${Ponto.CAMPO_CAMINHO_VIDEO} TEXT,
        ${Ponto.CAMPO_CEP} TEXT,
        ${Ponto.CAMPO_CIDADE} TEXT,
        ${Ponto.CAMPO_UF} TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async{
    switch(oldVersion){
      case 1:
        await db.execute('''
          ALTER TABLE ${Ponto.NOME_TABELA} ADD ${Ponto.CAMPO_LATITUDE} REAL NOT NULL DEFAULT 0;
        ''');
        await db.execute('''
          ALTER TABLE ${Ponto.NOME_TABELA} ADD ${Ponto.CAMPO_LONGITUDE} REAL NOT NULL DEFAULT 0;
        ''');
        break;
      case 2:
        await db.execute('''
          ALTER TABLE ${Ponto.NOME_TABELA} ADD ${Ponto.CAMPO_TIPO_IMAGEM} TEXT NOT NULL DEFAULT ' '
        ''');
        await db.execute('''
          ALTER TABLE ${Ponto.NOME_TABELA} ADD ${Ponto.CAMPO_CAMINHO_IMAGEM} TEXT
        ''');
        await db.execute('''
          ALTER TABLE ${Ponto.NOME_TABELA} ADD ${Ponto.CAMPO_CAMINHO_VIDEO} TEXT
        ''');
        break;
      case 3:
        await db.execute('''
          ALTER TABLE ${Ponto.NOME_TABELA} ADD ${Ponto.CAMPO_CEP} TEXT
        ''');
        await db.execute('''
          ALTER TABLE ${Ponto.NOME_TABELA} ADD ${Ponto.CAMPO_CIDADE} TEXT
        ''');
        await db.execute('''
          ALTER TABLE ${Ponto.NOME_TABELA} ADD ${Ponto.CAMPO_UF} TEXT
        ''');
        break;
    }
  }

  Future<void> close() async{
    if(_database != null){
      await _database!.close();
    }
  }
}