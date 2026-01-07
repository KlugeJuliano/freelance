import 'package:sqflite/sqflite.dart';
//import 'package:sqflite_common/sqflite.dart';

class ConfigDatabase {
  static Future<Database> getDatabase() async {
    final String pathDatabase = await getDatabasesPath();
    final String path = '$pathDatabase/app_rh.db';

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE requests(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            gerente TEXT,
            data_solicitacao TEXT,
            data_limite TEXT,
            pessoas_necessarias INTEGER,
            departamento TEXT,
            descricao TEXT,
            status TEXT
          )
        ''');
      },
    );
  }
}
