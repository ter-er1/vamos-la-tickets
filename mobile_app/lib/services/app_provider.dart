import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/models.dart';
import 'api_service.dart';

/// Provider de estado da aplicação
class AppProvider extends ChangeNotifier {
  // Estado de conectividade
  bool _isOnline = true;
  bool _isLanConnected = false;

  // Usuário logado
  User? _currentUser;

  // Evento selecionado
  Event? _currentEvent;

  // Último resultado de validação
  ValidationResult? _lastValidationResult;

  // Serviços
  final ApiService apiService;
  final Connectivity connectivity;

  AppProvider({
    required this.apiService,
    required this.connectivity,
  }) {
    _initializeConnectivity();
  }

  // Getters
  bool get isOnline => _isOnline;
  bool get isLanConnected => _isLanConnected;
  User? get currentUser => _currentUser;
  Event? get currentEvent => _currentEvent;
  ValidationResult? get lastValidationResult => _lastValidationResult;

  /// Inicializar monitoramento de conectividade
  void _initializeConnectivity() {
    connectivity.onConnectivityChanged.listen((result) {
      _checkConnectivity(result);
    });
    // Check initial state
    connectivity.checkConnectivity().then(_checkConnectivity);
  }

  /// Verificar status de conectividade
  void _checkConnectivity(ConnectivityResult result) {
    _isOnline = result != ConnectivityResult.none;

    // Se online, tentar conectar ao servidor LAN
    if (_isOnline) {
      checkLanConnection();
    } else {
      _isLanConnected = false;
    }

    notifyListeners();
  }

  /// Verificar conexão com servidor LAN
  Future<void> checkLanConnection() async {
    try {
      _isLanConnected = await apiService.checkServerHealth();
      notifyListeners();
    } catch (e) {
      _isLanConnected = false;
      notifyListeners();
    }
  }

  /// Login
  void login(String name, String email) {
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: 'staff',
      deviceId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    notifyListeners();
  }

  /// Logout
  void logout() {
    _currentUser = null;
    _currentEvent = null;
    _lastValidationResult = null;
    notifyListeners();
  }

  /// Definir evento
  void setCurrentEvent(Event event) {
    _currentEvent = event;
    notifyListeners();
  }

  /// Validar ticket
  Future<ValidationResult> validateTicket(
    String ticketId,
    String eventId,
    int timestamp,
    String signature,
  ) async {
    try {
      final result = await apiService.validateTicket(
        ticketId: ticketId,
        eventId: eventId,
        timestamp: timestamp,
        signature: signature,
        deviceId: _currentUser?.deviceId,
      );

      _lastValidationResult = result;
      notifyListeners();
      return result;
    } catch (e) {
      final result = ValidationResult(
        status: 'error',
        reason: 'provider_error: $e',
        timestamp: DateTime.now(),
      );
      _lastValidationResult = result;
      notifyListeners();
      return result;
    }
  }

  /// Obter estatísticas
  Future<Stats?> getEventStats(String eventId) async {
    return await apiService.getEventStats(eventId);
  }

  /// Forçar sincronização de conectividade
  Future<void> refreshConnectivity() async {
    final result = await connectivity.checkConnectivity();
    _checkConnectivity(result);
  }
}
