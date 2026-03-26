import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../models/models.dart';

/// Serviço de API
class ApiService {
  final String serverUrl;
  final http.Client? httpClient;
  final Dio? dioClient;

  ApiService({
    required this.serverUrl,
    this.httpClient,
    this.dioClient,
  });

  /// Validar ticket
  Future<ValidationResult> validateTicket({
    required String ticketId,
    required String eventId,
    required int timestamp,
    required String signature,
    String? deviceId,
  }) async {
    try {
      final url = Uri.parse('$serverUrl/validate-ticket');

      final payload = {
        'ticket_id': ticketId,
        'event_id': eventId,
        'timestamp': timestamp,
        'signature': signature,
        'device_id': deviceId ?? 'unknown',
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('Timeout na validação'),
          );

      if (response.statusCode == 200) {
        return ValidationResult.fromJson(jsonDecode(response.body));
      } else {
        return ValidationResult(
          status: 'error',
          reason: 'http_error_${response.statusCode}',
          timestamp: DateTime.now(),
        );
      }
    } on TimeoutException catch (_) {
      return ValidationResult(
        status: 'error',
        reason: 'timeout',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return ValidationResult(
        status: 'error',
        reason: 'network_error: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Obter estatísticas do evento
  Future<Stats?> getEventStats(String eventId) async {
    try {
      final url = Uri.parse('$serverUrl/events/$eventId/stats');

      final response = await http.get(url).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        return Stats.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verificar saúde do servidor
  Future<bool> checkServerHealth() async {
    try {
      final url = Uri.parse('$serverUrl/health');

      final response = await http.get(url).timeout(
            const Duration(seconds: 3),
          );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Listar eventos
  Future<List<Event>> getEvents() async {
    try {
      final url = Uri.parse('$serverUrl/events');

      final response = await http.get(url).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}
