import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  /// Inicializa la base de datos si aún no se ha creado
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final path = join(await getDatabasesPath(), 'dias_oficina.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE dias_confirmados (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario TEXT,
            fecha TEXT,
            mes TEXT,
            anio INTEGER
          )
        ''');
      },
    );

    return _database!;
  }

  /// Guarda un día confirmado para un usuario
  static Future<void> insertarDia({
    required String usuario,
    required DateTime fecha,
  }) async {
    final db = await getDatabase();

    await db.insert(
      'dias_confirmados',
      {
        'usuario': usuario,
        'fecha': fecha.toIso8601String(),
        'mes': fecha.month.toString().padLeft(2, '0'),
        'anio': fecha.year,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Lee todos los días confirmados por mes y usuario
  static Future<List<DateTime>> obtenerDiasPorMes({
    required String usuario,
    required int mes,
    required int anio,
  }) async {
    final db = await getDatabase();

    final resultado = await db.query(
      'dias_confirmados',
      where: 'usuario = ? AND mes = ? AND anio = ?',
      whereArgs: [usuario, mes.toString().padLeft(2, '0'), anio],
    );

    return resultado
        .map((fila) => DateTime.parse(fila['fecha'] as String))
        .toList();
  }

  /// Elimina todos los días (para pruebas o reinicio)
  static Future<void> borrarTodo() async {
    final db = await getDatabase();
    await db.delete('dias_confirmados');
  }

  static Future<void> eliminarDiasPorMes({
    required String usuario,
    required int mes,
    required int anio,
  }) async {
    final db = await getDatabase();
    await db.delete(
      'dias_confirmados',
      where: 'usuario = ? AND mes = ? AND anio = ?',
      whereArgs: [usuario, mes.toString().padLeft(2, '0'), anio],
    );
  }
}
