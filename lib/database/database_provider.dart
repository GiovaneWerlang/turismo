import 'package:sqflite/sqflite.dart';
import 'package:turismo/model/ponto.dart';

class DatabaseProvider{

  static const _dbName = 'pontos_turismo.db';
  static const _dbVersion = 1;

  DatabaseProvider._init();
  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

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
        ${Ponto.CAMPO_DATA_INCLUSAO} TEXT
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async{
    switch(oldVersion){

    }
  }

  Future<void> close() async{
    if(_database != null){
      await _database!.close();
    }
  }
}