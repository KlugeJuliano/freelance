import 'package:flutter/material.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/escalacao_provider.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/usuario_provider.dart';
import 'package:freelance/providers/loja_provider.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:freelance/views/cadastro_empresa_view.dart';
import 'package:freelance/views/direcao/diretoria_home_view.dart';
import 'package:freelance/views/login_view.dart';
import 'package:freelance/views/manager/new_request_view.dart';
import 'package:freelance/views/manager/jornada_view.dart';
import 'package:freelance/views/manager/requests_view.dart';
import 'package:freelance/views/relatorios_view.dart';
import 'package:freelance/views/rh/cadastros/colaboradores_view.dart';
import 'package:freelance/views/rh/cadastros/funcoes_view.dart';
import 'package:freelance/views/rh/escalacao_view.dart';
import 'package:freelance/views/rh/fila_pedidos_view.dart';
import 'package:freelance/views/splash_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await initializeDateFormatting('pt_BR');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
        ChangeNotifierProvider(create: (_) => PessoaProvider()),
        ChangeNotifierProvider(create: (_) => FuncaoProvider()),
        ChangeNotifierProvider(create: (_) => EscalacaoProvider()),
        ChangeNotifierProvider(create: (_) => LojaProvider()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthProvider _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthProvider>();
    _router = GoRouter(
      refreshListenable: _auth,
      redirect: (context, state) {
        final status = _auth.status;

        // Aguarda inicialização
        if (status == AuthStatus.idle || status == AuthStatus.loading) {
          return null;
        }

        final logado = _auth.autenticado;
        final rotasPublicas = ['/', '/login', '/cadastro_empresa'];
        final naRotaPublica = rotasPublicas.contains(state.matchedLocation);

        if (!logado && !naRotaPublica) return '/login';

        if (logado && naRotaPublica) {
          switch (_auth.role) {
            case 'gerente':
              return '/manager/gerente';
            case 'rh':
              return '/rh/fila_pedidos';
            case 'diretoria':
            default:
              return '/direcao/home';
          }
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashView()),
        GoRoute(path: '/login', builder: (_, __) => const LoginView()),
        GoRoute(path: '/cadastro_empresa', builder: (_, __) => const CadastroEmpresaView()),
        GoRoute(path: '/direcao/home', builder: (_, __) => const DiretoriaHomeView()),
        GoRoute(path: '/direcao/relatorios', builder: (_, __) => const RelatoriosView()),
        GoRoute(path: '/manager/gerente', builder: (_, __) => const RequestsView()),
        GoRoute(path: '/manager/new_request', builder: (_, __) => const NovaSolicitacao()),
        GoRoute(
          path: '/manager/jornada_view/:pedidoId',
          builder: (context, state) =>
              JornadaView(pedidoId: state.pathParameters['pedidoId']!),
        ),
        GoRoute(path: '/rh/fila_pedidos', builder: (_, __) => FilaPedidosView()),
        GoRoute(
          path: '/rh/escala_pedidos/:id',
          builder: (context, state) =>
              EscalacaoView(pedido: state.extra as PedidoModel),
        ),
        GoRoute(path: '/rh/cadastros/cadastro_funcoes', builder: (_, __) => const CadastroFuncoes()),
        GoRoute(path: '/rh/cadastros/cadastro_colaboradores', builder: (_, __) => const CadastroColaboradores()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Inicializa providers quando autenticar
    if (auth.autenticado && auth.empresaId != null) {
      final id = auth.empresaId!;
      context.read<PessoaProvider>().inicializar(id);
      context.read<FuncaoProvider>().inicializar(id);
      context.read<PedidoProvider>().inicializar(id);
      context.read<EscalacaoProvider>().inicializar(id);
      context.read<UsuarioProvider>().inicializar(id);
    }

    return MaterialApp.router(
      title: 'Freelance App',
      theme: AppTheme.data,
      routerConfig: _router,
    );
  }
}