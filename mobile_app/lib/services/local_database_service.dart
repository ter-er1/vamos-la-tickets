import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

/// Serviço de base de dados local (SQLite)
class LocalDatabaseService {
  static const String _dbName = 'vamos_la_tickets.db';
  static const int _version = 1;

  Database? _database;

  /// Obter instância do banco
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializar banco de dados
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _createDatabase,
    );
  }

  /// Criar tabelas
  Future<void> _createDatabase(Database db, int version) async {
    // Tabela de validações locais (cache)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_validations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticket_id TEXT NOT NULL,
        event_id TEXT NOT NULL,
        status TEXT NOT NULL,
        attendee_name TEXT,
        ticket_type TEXT,
        validated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Tabela de tickets em cache
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cached_tickets (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        ticket_type TEXT,
        attendee_name TEXT,
        status TEXT,
        downloaded_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabela de eventos
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cached_events (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        date TEXT,
        location TEXT,
        downloaded_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabela de preferências de usuário
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  /// Armazenar validação local
  Future<void> saveLocalValidation(
    String ticketId,
    String eventId,
    String status,
    String? attendeeName,
    String? ticketType,
  ) async {
    final db = await database;
    await db.insert(
      'local_validations',
      {
        'ticket_id': ticketId,
        'event_id': eventId,
        'status': status,
        'attendee_name': attendeeName,
        'ticket_type': ticketType,
      },
    );
  }

  /// Obter validações não sincronizadas
  Future<List<Map<String, dynamic>>> getUnsyncedValidations() async {
    final db = await database;
    return await db.query(
      'local_validations',
      where: 'synced = 0',
      orderBy: 'validated_at ASC',
    );
  }

  /// Marcar como sincronizado
  Future<void> markValidationAsSynced(int id) async {
    final db = await database;
    await db.update(
      'local_validations',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Armazenar tickets em cache
  Future<void> cacheTickets(List<Map<String, dynamic>> tickets) async {
    final db = await database;
    for (final ticket in tickets) {
      await db.insert(
        'cached_tickets',
        {
          'id': ticket['id'],
          'event_id': ticket['event_id'],
          'ticket_type': ticket['ticket_type'],
          'attendee_name': ticket['attendee_name'],
          'status': ticket['status'] ?? 'valid',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Buscar ticket em cache
  Future<Map<String, dynamic>?> getCachedTicket(
    String ticketId,
    String eventId,
  ) async {
    final db = await database;
    final result = await db.query(
      'cached_tickets',
      where: 'id = ? AND event_id = ?',
      whereArgs: [ticketId, eventId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Limpar cache de tickets
  Future<void> clearTicketCache(String eventId) async {
    final db = await database;
    await db.delete(
      'cached_tickets',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
  }

  /// Armazenar preferência
  Future<void> setPreference(String key, String value) async {
    final db = await database;
    await db.insert(
      'user_preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obter preferência
  Future<String?> getPreference(String key) async {
    final db = await database;
    final result = await db.query(
      'user_preferences',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  /// Fechar banco
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
