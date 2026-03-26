import 'package:flutter/material.dart';

class ValidationResult {
  final String status; // 'valid', 'already_used', 'invalid', 'error'
  final String reason;
  final String? ticketId;
  final String? attendeeName;
  final String? ticketType;
  final String? usedAt;
  final DateTime timestamp;

  ValidationResult({
    required this.status,
    required this.reason,
    this.ticketId,
    this.attendeeName,
    this.ticketType,
    this.usedAt,
    required this.timestamp,
  });

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    return ValidationResult(
      status: json['status'] ?? 'error',
      reason: json['reason'] ?? 'unknown',
      ticketId: json['ticket_id'],
      attendeeName: json['attendee_name'],
      ticketType: json['ticket_type'],
      usedAt: json['used_at'],
      timestamp: DateTime.now(),
    );
  }

  bool get isValid => status == 'valid';
  bool get isAlreadyUsed => status == 'already_used';
  bool get isInvalid => status == 'invalid' || status == 'error';

  Color get statusColor {
    if (isValid) return Colors.green;
    if (isAlreadyUsed) return Colors.orange;
    return Colors.red;
  }

  String get statusMessage {
    switch (status) {
      case 'valid':
        return '✅ Entrada Válida';
      case 'already_used':
        return '⚠️  Já Utilizado';
      case 'invalid':
        return '❌ Inválido';
      default:
        return '❌ Erro';
    }
  }

  String get reasonMessage {
    switch (reason) {
      case 'invalid_signature':
        return 'Assinatura inválida';
      case 'ticket_not_found':
        return 'Ticket não encontrado';
      case 'already_used':
        return 'Ticket já foi utilizado';
      case 'invalid_signature':
        return 'Assinatura criptográfica inválida';
      case 'database_error':
        return 'Erro na base de dados';
      default:
        return reason;
    }
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'staff', 'admin'
  final String? deviceId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.deviceId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'staff',
      deviceId: json['device_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'device_id': deviceId,
      };
}

class Event {
  final String id;
  final String name;
  final String date;
  final String location;
  final String status;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.status,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'active',
    );
  }
}

class Stats {
  final String eventId;
  final int totalTickets;
  final int usedTickets;
  final int validTickets;

  Stats({
    required this.eventId,
    required this.totalTickets,
    required this.usedTickets,
    required this.validTickets,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      eventId: json['event_id'] ?? '',
      totalTickets: json['total_tickets'] ?? 0,
      usedTickets: json['used_tickets'] ?? 0,
      validTickets: json['valid_tickets'] ?? 0,
    );
  }

  double get usagePercentage {
    if (totalTickets == 0) return 0;
    return (usedTickets / totalTickets) * 100;
  }
}
