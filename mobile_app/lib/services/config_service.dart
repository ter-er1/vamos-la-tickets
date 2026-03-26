import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Serviço para gerenciar configurações do app (IP do servidor, etc)
class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  late Database _db;

  factory ConfigService() {
    return _instance;
  }

  ConfigService._internal();

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vamos_la_config.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE config (
            id INTEGER PRIMARY KEY,
            key TEXT UNIQUE,
            value TEXT
          )
        ''');
      },
    );
  }

  Future<String?> getValue(String key) async {
    try {
      final result = await _db.query(
        'config',
        where: 'key = ?',
        whereArgs: [key],
      );
      if (result.isNotEmpty) {
        return result.first['value'] as String?;
      }
    } catch (e) {
      print('Erro ao ler config: $e');
    }
    return null;
  }

  Future<void> setValue(String key, String value) async {
    try {
      await _db.insert(
        'config',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Erro ao salvar config: $e');
    }
  }

  /// Obter IP do servidor (com fallback para valor padrão)
  Future<String> getServerUrl() async {
    final ip = await getValue('server_ip');
    return ip != null ? 'http://$ip:8000' : 'http://192.168.1.100:8000';
  }

  /// Salvar IP do servidor
  Future<void> setServerIp(String ip) async {
    await setValue('server_ip', ip);
  }

  Future<void> close() async {
    await _db.close();
  }
}
