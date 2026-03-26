import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/config_service.dart';
import '../services/api_service.dart';

/// Tela de configuração do servidor
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _ipController;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController();
    _loadCurrentIp();
  }

  Future<void> _loadCurrentIp() async {
    final configService = ConfigService();
    final currentUrl = await configService.getServerUrl();

    // Extrai o IP da URL (ex: http://192.168.1.100:8000 → 192.168.1.100)
    final ip = currentUrl.replaceFirst('http://', '').replaceFirst(':8000', '');

    setState(() {
      _ipController.text = ip;
    });
  }

  Future<void> _testConnection() async {
    final ip = _ipController.text.trim();

    if (ip.isEmpty) {
      setState(() {
        _errorMessage = '❌ Digita o IP do servidor!';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Testa a conexão com um simples GET
      final testUrl = 'http://$ip:8000/stats';
      final response = await http
          .get(Uri.parse(testUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Conexão OK - salva o IP
        final configService = ConfigService();
        await configService.setServerIp(ip);

        setState(() {
          _successMessage = '✅ Conectado com sucesso! IP salvo.';
          _errorMessage = null;
          _isLoading = false;
        });

        // Espera 2 segundos e volta
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context, true); // Retorna true indicando sucesso
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            '❌ Erro: Não conseguiu conectar.\nVerifique o IP e tente de novo.';
        _successMessage = null;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Configurações'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ Título
            const Text(
              'IP do Servidor Local',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Digite o IP da máquina onde o servidor está rodando.\nExemplo: 192.168.1.100',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // 📝 Campo de entrada
            TextField(
              controller: _ipController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '192.168.1.100',
                prefixIcon: const Icon(Icons.router),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _ipController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _ipController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // ❌ Mensagem de erro
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 14,
                  ),
                ),
              ),

            // ✅ Mensagem de sucesso
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  _successMessage!,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 14,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // 🔗 Botão de teste
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testConnection,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  _isLoading ? 'Testando...' : 'Testar Conexão',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🏠 Botão voltar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
            ),

            const Spacer(),

            // ℹ️ Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ℹ️ Dica: Se não souber o IP, execute no terminal:\nhostname -I',
                style: TextStyle(fontSize: 13, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
