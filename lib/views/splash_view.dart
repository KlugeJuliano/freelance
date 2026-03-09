import 'package:flutter/material.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _verificar();
  }

  Future<void> _verificar() async {
    final auth = context.read<AuthProvider>();
    await auth.verificarLogin();

    if (!mounted) return;

    if (auth.isLogado) {
      switch (auth.role) {
        case 'gerente':
          context.go('/manager/gerente');
          break;
        case 'rh':
          context.go('/rh/fila_pedidos');
          break;
        case 'diretoria':
          context.go('/direcao/diretoria');
          break;
        default:
          context.go('/login');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
