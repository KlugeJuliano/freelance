import 'package:flutter/material.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/escalacao_provider.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/loja_provider.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:freelance/views/cadastro_empresa_view.dart';
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
      ],
      child: const MyApp(),
    ),
  );
}

// Router separado em função para receber o AuthProvider
GoRouter _buildRouter(AuthProvider auth) => GoRouter(
  refreshListenable: auth, // re-avalia redirect quando auth muda
  redirect: (context, state) {
    if (auth.status == AuthStatus.idle || auth.status == AuthStatus.loading)
      return null;

    final logado = auth.autenticado;
    final rotasPublicas = ['/login', '/cadastro_empresa', '/'];
    final naRotaPublica = rotasPublicas.contains(state.matchedLocation);

    if (!logado && !naRotaPublica) return '/login';
    if (logado && naRotaPublica) return '/rh/fila_pedidos';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashView()),
    GoRoute(path: '/login', builder: (_, __) => const LoginView()),
    GoRoute(
      path: '/cadastro_empresa',
      builder: (_, __) => const CadastroEmpresaView(),
    ),
    GoRoute(path: '/manager/gerente', builder: (_, __) => const RequestsView()),
    GoRoute(
      path: '/manager/new_request',
      builder: (_, __) => const NovaSolicitacao(),
    ),
    GoRoute(
      path: '/manager/jornada_view/:pedidoId',
      builder: (context, state) {
        final pedidoId = state.pathParameters['pedidoId']!;
        return JornadaView(pedidoId: pedidoId);
      },
    ),
    GoRoute(path: '/rh/fila_pedidos', builder: (_, __) => FilaPedidosView()),
    GoRoute(
      path: '/rh/escala_pedidos/:id',
      builder: (context, state) =>
          EscalacaoView(pedido: state.extra as PedidoModel),
    ),
    GoRoute(
      path: '/rh/cadastros/cadastro_funcoes',
      builder: (_, __) => const CadastroFuncoes(),
    ),
    GoRoute(
      path: '/direcao/relatorios',
      builder: (_, __) => const RelatoriosView(),
    ),
    GoRoute(
      path: '/rh/cadastros/cadastro_colaboradores',
      builder: (_, __) => const CadastroColaboradores(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Inicializa providers com empresaId assim que autenticar
    if (auth.autenticado && auth.empresaId != null) {
      final id = auth.empresaId!;
      context.read<PessoaProvider>().inicializar(id);
      context.read<FuncaoProvider>().inicializar(id);
      context.read<PedidoProvider>().inicializar(id);
      context.read<EscalacaoProvider>().inicializar(id);
    }

    return MaterialApp.router(
      title: 'Freelance App',
      theme: AppTheme.data,
      routerConfig: _buildRouter(auth),
    );
  }
}
