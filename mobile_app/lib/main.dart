import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'services/api_service.dart';
import 'services/app_provider.dart';
import 'services/config_service.dart';
import 'screens/login_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ Inicializa o serviço de configuração
  final configService = ConfigService();
  await configService.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> _serverUrlFuture;

  @override
  void initState() {
    super.initState();
    // ⭐ Carrega o IP do servidor de forma assíncrona (sem bloquear a UI)
    _serverUrlFuture = ConfigService().getServerUrl();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _serverUrlFuture,
      builder: (context, snapshot) {
        final serverUrl = snapshot.data ?? 'http://192.168.1.100:8000';

        return MultiProvider(
          providers: [
            Provider<ApiService>(
              create: (_) => ApiService(serverUrl: serverUrl),
            ),
            Provider<Connectivity>(
              create: (_) => Connectivity(),
            ),
            ChangeNotifierProvider<AppProvider>(
              create: (context) => AppProvider(
                apiService: context.read<ApiService>(),
                connectivity: context.read<Connectivity>(),
              ),
            ),
          ],
          child: MaterialApp(
            title: '🎫 VAMOS LÁ TICKETS',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blue.shade800,
                elevation: 0,
              ),
            ),
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/scanner': (context) {
                final provider = context.read<AppProvider>();
                return ScannerScreen(
                  eventId: 'EVT001',
                  eventName: 'Evento Demo',
                );
              },
            },
          ),
        );
      },
    );
  }
}
