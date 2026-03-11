import 'package:flutter/material.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/escalacao_provider.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/loja_provider.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:freelance/views/direcao/relatorios_consolidados_view.dart';
import 'package:freelance/views/login_view.dart';
import 'package:freelance/views/manager/new_request_view.dart';
import 'package:freelance/views/manager/jornada_view.dart';
import 'package:freelance/views/manager/requests_view.dart';
import 'package:freelance/views/rh/cadastros/colaboradores_view.dart';
import 'package:freelance/views/rh/cadastros/funcoes_view.dart';
import 'package:freelance/views/rh/escalacao_view.dart';
import 'package:freelance/views/rh/fila_pedidos_view.dart';
import 'package:freelance/views/splash_view.dart';
import 'package:go_router/go_router.dart';
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

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashView()),
    GoRoute(path: '/login', builder: (context, state) => const LoginView()),
    GoRoute(
      path: '/manager/gerente',
      builder: (context, state) => const RequestsView(),
    ),
    GoRoute(
      path: '/manager/new_request',
      builder: (context, state) => const NovaSolicitacao(),
    ),
    GoRoute(
      path: '/manager/jornada_view/:pedidoId',
      builder: (context, state) {
        final pedidoId = state.pathParameters['pedidoId']!;
        return JornadaView(pedidoId: pedidoId);
      },
    ),
    GoRoute(
      path: '/rh/fila_pedidos',
      builder: (context, state) => FilaPedidosView(),
    ),
    GoRoute(
      path: '/rh/escala_pedidos/:id',
      builder: (context, state) =>
          EscalacaoView(pedido: state.extra as PedidoModel),
    ),
    GoRoute(
      path: '/direcao/diretoria',
      builder: (context, state) => const RelatoriosConsolidadosView(),
    ),
    GoRoute(
      path: '/rh/cadastros/cadastro_funcoes',
      builder: (context, state) => const CadastroFuncoes(),
    ),
    GoRoute(
      path: '/rh/cadastros/cadastro_colaboradores',
      builder: (context, state) => const CadastroColaboradores(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Freelance App',
      theme: AppTheme.data,
      routerConfig: _router,
    );
  }
}
