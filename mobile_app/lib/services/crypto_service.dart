import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// Serviço de criptografia
class CryptoService {
  static const String SECRET_KEY = 'vamos-la-tickets-secret-key-production';

  /// Gerar assinatura HMAC-SHA256
  static String generateSignature(
    String ticketId,
    String eventId,
    int timestamp,
  ) {
    final message = '$ticketId$eventId$timestamp';
    final bytes = utf8.encode(message);
    final key = utf8.encode(SECRET_KEY);
    return Hmac(sha256, key).convert(bytes).toString();
  }

  /// Gerar dados para QR Code
  static Map<String, dynamic> generateQRData(
    String ticketId,
    String eventId,
  ) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final signature = generateSignature(ticketId, eventId, timestamp);

    return {
      'ticket_id': ticketId,
      'event_id': eventId,
      'timestamp': timestamp,
      'signature': signature,
    };
  }

  /// Gerar string JSON para QR Code
  static String generateQRString(String ticketId, String eventId) {
    final data = generateQRData(ticketId, eventId);
    return jsonEncode(data);
  }

  /// Gerar UUID
  static String generateUUID() {
    return const Uuid().v4();
  }

  /// Validar se data JSON é válida
  static bool isValidQRData(Map<String, dynamic> data) {
    return data.containsKey('ticket_id') &&
        data.containsKey('event_id') &&
        data.containsKey('timestamp') &&
        data.containsKey('signature');
  }
}
