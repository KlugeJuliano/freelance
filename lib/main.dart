import 'package:flutter/material.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/providers/pessoa_funcao_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:freelance/views/direcao/relatorios_consolidados_view.dart';
import 'package:freelance/views/home_view.dart';
import 'package:freelance/views/manager/jornada_view.dart';
import 'package:freelance/views/manager/new_request_view.dart';
import 'package:freelance/views/manager/requests_view.dart';
import 'package:freelance/views/rh/cadastros/colaboradores_view.dart';
import 'package:freelance/views/rh/cadastros/funcoes_view.dart';
import 'package:freelance/views/rh/escalacao_view.dart';
import 'package:freelance/views/rh/fila_pedidos_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
        ChangeNotifierProvider(create: (_) => PessoaProvider()),
        ChangeNotifierProvider(create: (_) => FuncaoProvider()),
        ChangeNotifierProvider(create: (_) => PessoaFuncaoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/manager/gerente',
      builder: (context, state) => GerenteView(),
    ),
    GoRoute(
      path: '/manager/new_request',
      builder: (context, state) => NovaSolicitacao(),
    ),
    GoRoute(
      path: '/manager/jornada_view/:pedidoId',
      builder: (context, state) {
        final pedidoId = state.pathParameters['pedidoId']!;
        return DetalhesPedido(pedidoId: pedidoId);
      },
    ),
    GoRoute(
      path: '/rh/fila_pedidos',
      builder: (context, state) => FilaPedidosView(),
    ),
    GoRoute(
      path: '/rh/escala_pedidos/:pedidoId',
      builder: (context, state) {
        final pedidoId = state.pathParameters['pedidoId']!;
        return EscalacaoView(pedidoId: pedidoId);
      },
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
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}
