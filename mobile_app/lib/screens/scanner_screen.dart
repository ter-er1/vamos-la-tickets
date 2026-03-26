import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../models/models.dart';
import '../services/app_provider.dart';

/// Tela de scanner de QR Code
class ScannerScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const ScannerScreen({
    Key? key,
    required this.eventId,
    required this.eventName,
  }) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late MobileScannerController cameraController;
  late AudioPlayer _audioPlayer;
  ValidationResult? _lastResult;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    cameraController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Processar QR escaneado
  void _handleQRScan(String qrData) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      // Parse JSON do QR
      final Map<String, dynamic> qrJson = jsonDecode(qrData);

      // Validar estrutura
      if (!_isValidQRData(qrJson)) {
        _playErrorSound();
        _showInvalidQRDialog();
        _isProcessing = false;
        return;
      }

      // Extrair dados
      final ticketId = qrJson['ticket_id'] as String;
      final eventId = qrJson['event_id'] as String;
      final timestamp = qrJson['timestamp'] as int;
      final signature = qrJson['signature'] as String;

      // Validar com servidor
      final provider = context.read<AppProvider>();
      final result = await provider.validateTicket(
        ticketId,
        eventId,
        timestamp,
        signature,
      );

      // Mostrar resultado
      _showValidationResult(result);

      // Reproduzir som apropriado
      if (result.isValid) {
        _playSuccessSound();
      } else {
        _playErrorSound();
      }
    } catch (e) {
      _playErrorSound();
      _showErrorDialog('Erro ao processar QR: $e');
    } finally {
      _isProcessing = false;
      // Parar scanner após resultado (para evitar múltiplos scanners simultâneos)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          cameraController.start();
        }
      });
    }
  }

  /// Validar estrutura do QR
  bool _isValidQRData(Map<String, dynamic> data) {
    return data.containsKey('ticket_id') &&
        data.containsKey('event_id') &&
        data.containsKey('timestamp') &&
        data.containsKey('signature');
  }

  /// Reproduzir som de sucesso
  Future<void> _playSuccessSound() async {
    try {
      // Toca um tom usando just_audio (opcional)
      // Por enquanto, apenas um efeito visual
      await _audioPlayer.seek(Duration.zero);
    } catch (_) {}
  }

  /// Reproduzir som de erro
  Future<void> _playErrorSound() async {
    try {
      // Toca um tom usando just_audio (opcional)
      // Por enquanto, apenas um efeito visual
      await _audioPlayer.seek(Duration.zero);
    } catch (_) {}
  }

  /// Mostrar resultado de validação
  void _showValidationResult(ValidationResult result) {
    _lastResult = result;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status color indicator
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: result.statusColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  result.isValid
                      ? '✅'
                      : result.isAlreadyUsed
                          ? '⚠️'
                          : '❌',
                  style: const TextStyle(fontSize: 50),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Mensagem de status
            Text(
              result.statusMessage,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: result.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Razão
            Text(
              result.reasonMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            // Informações do ticket
            if (result.attendeeName != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Participante',
                      result.attendeeName ?? 'N/A',
                    ),
                    if (result.ticketType != null)
                      _buildInfoRow('Tipo', result.ticketType ?? 'N/A'),
                    if (result.usedAt != null)
                      _buildInfoRow('Usado em', result.usedAt ?? 'N/A'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Botão de continuar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  cameraController.start();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Próximo Ticket',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  /// Mostrar diálogo de QR inválido
  void _showInvalidQRDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ QR Inválido'),
        content: const Text('Este QR Code não contém dados válidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo de erro
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎫 Scanner'),
            Text(
              widget.eventName,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        actions: [
          // Botão de status de conexão
          Consumer<AppProvider>(
            builder: (context, provider, _) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Tooltip(
                  message: provider.isLanConnected
                      ? 'Conectado ao servidor'
                      : 'Offline',
                  child: CircleAvatar(
                    backgroundColor:
                        provider.isLanConnected ? Colors.green : Colors.orange,
                    radius: 8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  cameraController.stop();
                  _handleQRScan(barcode.rawValue!);
                }
              }
            },
          ),
          // Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Aponte a câmera\npara o QR Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<AppProvider>(
        builder: (context, provider, _) => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Status
            FloatingActionButton(
              heroTag: 'status',
              onPressed: () {
                provider.refreshConnectivity();
              },
              backgroundColor:
                  provider.isLanConnected ? Colors.green : Colors.orange,
              tooltip:
                  provider.isLanConnected ? 'Conectado' : 'Offline - Cache',
              child: Icon(
                provider.isLanConnected ? Icons.cloud_done : Icons.cloud_off,
              ),
            ),
            const SizedBox(height: 16),
            // Logout
            FloatingActionButton(
              heroTag: 'logout',
              onPressed: () {
                provider.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              backgroundColor: Colors.red,
              tooltip: 'Sair',
              child: const Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
